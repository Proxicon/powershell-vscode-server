FROM ghcr.io/linuxserver/code-server:latest

USER root

# Install PowerShell from Microsoft's repository and other dependencies
RUN apt-get update \
    && apt-get install -y curl gnupg apt-transport-https ca-certificates \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-focal-prod focal main" > /etc/apt/sources.list.d/microsoft.list' \
    && apt-get update \
    && apt-get install -y powershell less gss-ntlmssp

# Download and install the PowerShell extension for VSCode
RUN PS_EXTENSION_VERSION=$(curl -s https://api.github.com/repos/PowerShell/vscode-powershell/releases/latest | jq -r '.tag_name' | sed 's/^v//') \
    && curl -L https://github.com/PowerShell/vscode-powershell/releases/download/v${PS_EXTENSION_VERSION}/powershell-${PS_EXTENSION_VERSION}.vsix -o /tmp/vscode-powershell.zip \
    && pwsh -NoLogo -NoProfile -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        Expand-Archive /tmp/vscode-powershell.zip /tmp/vscode-powershell/ ; \
        New-Item -Force -ItemType Directory ~/.local/share/code-server/extensions/ ; \
        Move-Item /tmp/vscode-powershell/extension ~/.local/share/code-server/extensions/ms-vscode.powershell-${PS_EXTENSION_VERSION} ; \
        Remove-Item -Recurse -Force /tmp/vscode-powershell/ ; \
    "

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

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
