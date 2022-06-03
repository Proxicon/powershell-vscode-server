FROM ghcr.io/linuxserver/code-server

USER root

# PowerShell args
ARG PS_VERSION=7.3.0
ARG PS_PACKAGE=powershell-preview_${PS_VERSION}-preview.4-1.deb_amd64.deb
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}

# PowerShell extension args
ARG PS_EXTENSION_VERSION=2022.5.1
ARG PS_EXTENSION_PACKAGE=powershell-${PS_EXTENSION_VERSION}.vsix
ARG PS_EXTENSION_PACKAGE_URL=https://github.com/PowerShell/vscode-powershell/releases/download/v${PS_EXTENSION_VERSION}/${PS_EXTENSION_PACKAGE}

# Download the Linux package of PowerShell and the PowerShell extension
ADD ${PS_PACKAGE_URL} /tmp/powershell.deb
ADD ${PS_EXTENSION_PACKAGE_URL} /tmp/vscode-powershell.zip

# Define ENVs for Localization/Globalization
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    # Set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

RUN echo "PowerShell version: ${PS_VERSION} PowerShell extension version: ${PS_EXTENSION_VERSION}" \
    && apt-get update \
    # Install PowerShell
    && apt-get install -y /tmp/powershell.deb \
    # Install PowerShell's dependencies
    && apt-get install -y \
    # less is required for help in PowerShell
        less \
    # Required for SSL
        ca-certificates \
        gss-ntlmssp \
    && apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Cleanup PowerShell package
    && rm /tmp/powershell.deb \
    && pwsh -NoLogo -NoProfile -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        #
        # Intialize powershell module cache
        #
        while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) { \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
        } ; \
        #
        # Extract and move PowerShell extension to the correct place, then cleanup
        #
        Expand-Archive /tmp/vscode-powershell.zip /tmp/vscode-powershell/ ; \
        \$null = New-Item -Force -ItemType Directory ~/.local/share/code-server/extensions/ ; \
        Move-Item /tmp/vscode-powershell/extension ~/.local/share/code-server/extensions/ms-vscode.powershell-${PS_EXTENSION_VERSION} ; \
        Remove-Item -Recurse -Force /tmp/vscode-powershell/ ; \
        "

ARG VCS_REF="none"
ARG IMAGE_NAME=ktjaden/codeserver:latest

LABEL maintainer="Proxicon https://github.com/Proxicon" \
      readme.md="https://github.com/Proxicon/powershell-vscode-server/blob/main/README.md" \
      description="Coder.com's code-server, PowerShell, and the PowerShell extension for vscode - all in one container." \
      org.label-schema.url="https://github.com/Proxicon/powershell-vscode-server" \
      org.label-schema.vcs-url="https://github.com/Proxicon/powershell-vscode-server" \
      org.label-schema.name="Proxicon" \
      org.label-schema.vendor="Proxicon" \
      org.label-schema.version=${PS_EXTENSION_VERSION} \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.docker.cmd="docker run -t -p 127.0.0.1:8443:8443 -v '\${PWD}:/root/project' ${IMAGE_NAME} code-server --allow-http --no-auth"