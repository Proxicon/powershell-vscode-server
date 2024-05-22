FROM ghcr.io/linuxserver/code-server

USER root

# PowerShell args
ARG PS_VERSION=7.4.2
ARG PS_PACKAGE=powershell-lts_${PS_VERSION}-1.deb_amd64.deb
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}

# PowerShell extension args
ARG PS_EXTENSION_VERSION=2024.2.2
ARG PS_EXTENSION_PACKAGE=powershell-${PS_EXTENSION_VERSION}.vsix
ARG PS_EXTENSION_PACKAGE_URL=https://github.com/PowerShell/vscode-powershell/releases/download/v${PS_EXTENSION_VERSION}/${PS_EXTENSION_PACKAGE}

# Download the Linux package of PowerShell
ADD ${PS_PACKAGE_URL} /tmp/powershell.deb

# Define ENVs for Localization/Globalization
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    # Set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

RUN echo "PowerShell version: ${PS_VERSION}" \
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
    && rm /tmp/powershell.deb

# Install VSCode PowerShell extension
RUN curl -L -o /tmp/vscode-powershell.vsix ${PS_EXTENSION_PACKAGE_URL} \
    && mkdir -p /home/abc/.local/share/code-server/extensions \
    && code-server --install-extension /tmp/vscode-powershell.vsix \
    && rm /tmp/vscode-powershell.vsix

# Set permissions
RUN chown -R 1000:1000 /config /home/abc/.local/share/code-server/extensions

# Switch back to user with UID and GID 1000
USER 1000:1000

ARG VCS_REF="none"
ARG IMAGE_NAME=ghcr.io/proxicon/powershell-vscode-server:latest

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
      org.label-schema.docker.cmd="docker run -t -p 8443:8443 -v '\${PWD}:/root/project' ${IMAGE_NAME}"