# Some useful bash scripts for ubuntu server
[![Build Status](https://files.ariadata.co/file/ariadata_logo.png)](https://ariadata.co)

![](https://img.shields.io/github/stars/ariadata/dc-nginxproxymanager.svg)
![](https://img.shields.io/github/watchers/ariadata/dc-nginxproxymanager.svg)
![](https://img.shields.io/github/forks/ariadata/dc-nginxproxymanager.svg)

> After Installing , use `sudo reboot` to restart your system

[Download Ubuntu Server 20.04 LTS ](https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso)
---
### Install DockerHost Basic :
#### dockerhost + portainer
```sh
bash <(curl -sSL https://git.io/JDM9J)
```
### Install DockerHost Normal :
#### dockerhost + portainer + nginxproxymanager + php-cli + composer
```sh
cd ~ && curl -o dockerhost-normal.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/dockerhost-normal.sh && bash dockerhost-normal.sh
```
### Install DockerHost Full :
#### full
```sh
cd ~ && curl -o dockerhost-full.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/dockerhost-full.sh && bash dockerhost-full.sh
```
### Install LEMP :
```sh
cd ~ && curl -o lemp-basic.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/lemp-basic.sh && bash lemp-basic.sh
```
