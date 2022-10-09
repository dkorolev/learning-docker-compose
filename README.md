# `learning-docker-compose`

## Outline

This is to serve as a cheatsheet / reference, for myself and possibly others, covering:

- [x] Basic `docker-compose.yml` syntax and run commands.
- [x] Graceful termination (`SIGTERM` it is).
- [x] Build and run C++.
- [x] Pass environmental variables to `docker compose`.
- [x] Multiple containers witihn one `docker-compose.yml`.
- [x] Exposing ports from within `docker compose`.
- [x] Containers communicating via each other within a "local" network.
- [ ] Sharing volumes, both with the host machine and among containers.
- [ ] Startup order, keepalives, delayed keepalives.

## Setup

I'm using `docker compose`, not `docker-compose`. Version seems to matter. Here's mine:

```
$ docker --version
Docker version 20.10.18, build b40c2f6
```

```
$ docker version
Client: Docker Engine - Community
 Version:           20.10.18
 API version:       1.41
 Go version:        go1.18.6
 Git commit:        b40c2f6
 Built:             Thu Sep  8 23:11:43 2022
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.18
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.18.6
  Git commit:       e42327a
  Built:            Thu Sep  8 23:09:30 2022
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.8
  GitCommit:        9cd3357b7fd7218e4aec3eae239db1f68a5a6ec6
 runc:
  Version:          1.1.4
  GitCommit:        v1.1.4-0-g5fd4c4d
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

Installation instructions that I followed: https://docs.docker.com/engine/install/ubuntu/. To keep things simple:

```
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
