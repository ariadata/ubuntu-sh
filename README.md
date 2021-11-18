[![Build Status](https://files.ariadata.co/file/ariadata_logo.png)](https://ariadata.co)

> After Installing , use `sudo reboot` to restart your system

[Download Ubuntu Server 20.04 LTS ](https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso)
---
#### Install DockerHost Basic :
```sh
cd ~ && curl -o dockerhost-basic.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/dockerhost-basic.sh && bash dockerhost-basic.sh
```
#### Install DockerHost :
```sh
cd ~ && curl -o dockerhost.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/dockerhost.sh && bash dockerhost.sh
```
#### Install LEMP :
```sh
cd ~ && curl -o lemp-basic.sh -L https://raw.githubusercontent.com/ariadata/ubuntu-sh/master/lemp-basic.sh && bash lemp-basic.sh
```