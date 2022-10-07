# Some useful bash scripts for ubuntu server
[![Build Status](https://files.ariadata.co/file/ariadata_logo.png)](https://ariadata.co)

![](https://img.shields.io/github/stars/ariadata/ubuntu-sh.svg)
![](https://img.shields.io/github/watchers/ariadata/ubuntu-sh.svg)
![](https://img.shields.io/github/forks/ariadata/ubuntu-sh.svg)

## New Version is : [Here](https://github.com/ariadata/dockerhost-sh)

> After Installing , use `sudo reboot` to restart your system

### Ubuntu Server 20.04 focal LTS Download Links:
##### [Direct link of 20.04.4](http://old-releases.ubuntu.com/releases/focal/ubuntu-20.04.4-live-server-amd64.iso)
##### [Latest focal page](https://releases.ubuntu.com/focal/)
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
sudo apt --yes install wget curl git nano lsb-release sqlite3 p7zip gnupg-agent apt-transport-https ca-certificates software-properties-common cron
sudo systemctl enable --now cron
bash <(curl -sSL -fsSL https://get.docker.com)
sudo chmod 666 /var/run/docker.sock
sudo systemctl enable --now docker
sudo apt install -y docker-compose
sudo chmod +x /usr/bin/docker-compose

#### docker-compose alternative way (v2.6.1)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
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
