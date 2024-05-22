# PowerShell code-server

A complete PowerShell developer experience - all in a Docker container!

![screenshot](https://user-images.githubusercontent.com/2644648/55316260-dd4dde80-5422-11e9-9dd2-7303b5f21532.png)

This container image contains:
* Coder.com's [code-server](https://github.com/codercom/code-server)
* [PowerShell](https://github.com/PowerShell/PowerShell) 7.4.2
* The [PowerShell extension for vscode](https://github.com/PowerShell/vscode-powershell) which works with code-server (2024.2.2)

Based on the popular LinuxServer.io image ghcr.io/linuxserver/code-server

You can find the Dockerfile for this container image [on GitHub](https://github.com/Proxicon/powershell-vscode-server)
You can find the container image [on Dockerhub](https://hub.docker.com/repository/docker/ktjaden/codeserver)

## Let's go!

1. `docker pull ghcr.io/proxicon/powershell-vscode-server:latest`
2. `docker run -t -p 8443:8443 -v "${PWD}:/root/project" ghcr.io/proxicon/powershell-vscode-server:latest code-server`
3. Open `http://localhost:8443` in your browser of choice

> The second command will start the container on port `8443` and mount whatever is in `PWD` allowing you to actually modify the files on your host OS from within the container.

## Tags

* *latest:* contains the latest version of the PowerShell extension 2024.2.2 and PowerShell 7.4.2

## Code server with Traefik deployment

Here's a sample docker-compose configuration for deploying the PowerShell code-server with Traefik:

```yaml
version: '3.4'

networks:
  skynet:
    external: true

services:
  vscode:
    image: ghcr.io/proxicon/powershell-vscode-server:latest
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Africa/Johannesburg
      - PASSWORD=yourpassword # optional
      #- HASHED_PASSWORD= # optional
      #- SUDO_PASSWORD=password # optional
      #- SUDO_PASSWORD_HASH= # optional
      - PROXY_DOMAIN=yourdomain.com # optional
      - DEFAULT_WORKSPACE=/config/workspace # optional
    deploy:
      labels:
        - traefik.enable=true
        - traefik.docker.network=skynet
        
        # 80 Router
        - traefik.http.routers.vscode-http.entrypoints=web
        - traefik.http.routers.vscode-http.rule=Host(`yourdomain.com`)
        - traefik.http.routers.vscode-http.middlewares=vscode-https-redirect
        
        # 443 Redirect
        - traefik.http.middlewares.vscode-https-redirect.redirectscheme.scheme=https
        - traefik.http.middlewares.vscode-https-redirect.redirectscheme.permanent=true 
        
        # Middleware Auth: Authelia
        - traefik.http.routers.vscode-https.middlewares=authelia@swarm        
        
        # 443 Router
        - traefik.http.routers.vscode-https.entrypoints=websecure
        - traefik.http.routers.vscode-https.rule=Host(`yourdomain.com`)
        - traefik.http.routers.vscode-https.tls=true
        - traefik.http.routers.vscode-https.tls.certResolver=letsencrypt
        
        # LB
        - traefik.http.services.vscode-https.loadbalancer.server.port=8443
    volumes:
      - /mnt/code:/config
    ports:
      - "8443:8443"
    networks:
      - skynet
