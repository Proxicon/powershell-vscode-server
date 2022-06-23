# PowerShell code-server

A complete PowerShell developer experience - all in a Docker container!

![screenshot](https://user-images.githubusercontent.com/2644648/55316260-dd4dde80-5422-11e9-9dd2-7303b5f21532.png)

This container image contains:
* Coder.com's [code-server](https://github.com/codercom/code-server)
* [PowerShell](https://github.com/PowerShell/PowerShell) 7.2.5
* The [PowerShell extension for vscode](https://github.com/PowerShell/vscode-powershell) which works with code-server (2022.6.1)

Based on the popular LinuxServer.io image ghcr.io/linuxserver/code-server

You can find the Dockerfile for this container image [on GitHub](https://github.com/Proxicon/powershell-vscode-server)
You can find the container image [on Dockerhub](https://hub.docker.com/repository/docker/ktjaden/codeserver)
## Let's go!

1. `docker pull docker pull ktjaden/codeserver:latest`
2. `docker run -t -p 127.0.0.1:8443:8443 -v "${PWD}:/root/project" docker pull ktjaden/codeserver:latest code-server --allow-http --no-auth`
3. Open `http://localhost:8443` in your browser of choice

> The second command will start the container on port `8443` and mount whatever is in `PWD` allowing you to actually modify the files on your host OS from within the container.

## Tags

* *latest:* contains the latest version of the PowerShell extension 2022.6.1 and PowerShell 7.2.5
