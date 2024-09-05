FROM ghcr.io/linuxserver/code-server

USER root

# Install necessary tools for querying GitHub API
#RUN apt-get update && apt-get install -y curl jq libicu72

# Fetch latest PowerShell version and extension version
RUN PS_VERSION=$(curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest | jq -r '.tag_name' | sed 's/^v//') \
    && PS_EXTENSION_VERSION=$(curl -s https://api.github.com/repos/PowerShell/vscode-powershell/releases/latest | jq -r '.tag_name' | sed 's/^v//') \
    && PS_PACKAGE=powershell-lts_${PS_VERSION}-1.deb_amd64.deb \
    && PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE} \
    && PS_EXTENSION_PACKAGE=powershell-${PS_EXTENSION_VERSION}.vsix \
    && PS_EXTENSION_PACKAGE_URL=https://github.com/PowerShell/vscode-powershell/releases/download/v${PS_EXTENSION_VERSION}/${PS_EXTENSION_PACKAGE} \
    # Download the PowerShell and PowerShell extension
    && curl -L ${PS_PACKAGE_URL} -o /tmp/powershell.deb \
    && curl -L ${PS_EXTENSION_PACKAGE_URL} -o /tmp/vscode-powershell.zip

# Define ENVs for Localization/Globalization
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

# Install PowerShell and dependencies
RUN echo "PowerShell version: ${PS_VERSION} PowerShell extension version: ${PS_EXTENSION_VERSION}" \
    && apt-get update \
    && apt-get install -y /tmp/powershell.deb \
    && apt-get install -y less ca-certificates gss-ntlmssp \
    && apt-get dist-upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm /tmp/powershell.deb \
    && pwsh -NoLogo -NoProfile -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) { \
            Write-Host \"'Waiting for \$env:PSModuleAnalysisCachePath'\" ; \
            Start-Sleep -Seconds 6 ; \
        } ; \
        Expand-Archive /tmp/vscode-powershell.zip /tmp/vscode-powershell/ ; \
        \$null = New-Item -Force -ItemType Directory ~/.local/share/code-server/extensions/ ; \
        Move-Item /tmp/vscode-powershell/extension ~/.local/share/code-server/extensions/ms-vscode.powershell-${PS_EXTENSION_VERSION} ; \
        Remove-Item -Recurse -Force /tmp/vscode-powershell/ ; \
    "

# Metadata
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
