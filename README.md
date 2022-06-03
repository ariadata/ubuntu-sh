# Some useful bash scripts for ubuntu server
[![Build Status](https://files.ariadata.co/file/ariadata_logo.png)](https://ariadata.co)

![](https://img.shields.io/github/stars/ariadata/ubuntu-sh.svg)
![](https://img.shields.io/github/watchers/ariadata/ubuntu-sh.svg)
![](https://img.shields.io/github/forks/ariadata/ubuntu-sh.svg)

> After Installing , use `sudo reboot` to restart your system

[Download Ubuntu Server 20.04 LTS ](https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso)
---
### Install DockerHost Basic :
#### dockerhost + portainer (root-less)
```sh
bash <(curl -sSL https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/dockerhost-basic.sh)
```
#### dockerhost + portainer (root)
```sh
bash <(curl -sSL https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/dockerhost-basic-root.sh)
```
### Install DockerHost Using docker.com script :
```sh
bash <(curl -sSL -fsSL https://get.docker.com)
sudo apt install-y docker-compose
```
---
### Install DockerHost Normal :
#### dockerhost + portainer + nginxproxymanager + php-cli + composer
```sh
cd ~ && curl -o dockerhost-normal.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/dockerhost-normal.sh && bash dockerhost-normal.sh
```
---
### Install DockerHost Full :
#### full
```sh
cd ~ && curl -o dockerhost-full.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/dockerhost-full.sh && bash dockerhost-full.sh
```
---
### Install LEMP :
```sh
cd ~ && curl -o lemp-basic.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/lemp-basic.sh && bash lemp-basic.sh
```
