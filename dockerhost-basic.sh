#!/bin/sh
set -e
clear
if [[ $EUID = 0 ]]; then
	echo "Please run this script as non-root sudo user"
	exit 1
fi

sudo service ssh restart

# Update System First
read -e -p $'Update && Upgrade System first [y/n]? : ' -i "y" if_update_first
if [[ $if_update_first =~ ^([Yy])$ ]]
then
	sudo apt --yes update && sudo apt -q --yes upgrade
fi

# via root user
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# service ssh restart

# add dockerhub.ir registery
read -e -p $'Add dockerhub.ir mirror to docker registery [y/n]? : ' -i "n" if_dockerhub_ir_registery_add

# extra dns servers , shecan : 185.51.200.2,178.22.122.100  | begzar : 185.55.226.26,185.55.225.25
read -e -p $'Add extra nameservers [y/n]? : ' -i "n" if_set_extra_dns_servers
if [[ $if_set_extra_dns_servers =~ ^([Yy])$ ]]
then
	read -e -p $'Enter NS IPs seperated by ","  sample of shecan is default:\n' -i "185.51.200.2,178.22.122.100" new_name_servers
	IFS=',' read -r -a ns_arr <<< "$new_name_servers"
	for element in "${ns_arr[@]}"
	do
		sudo sed -i '1 i\nameserver '"$element" /etc/resolv.conf
	done
fi

# Install Portainer
read -e -p $'Install Portainer [y/n]? : ' -i "n" if_install_portainer
if [[ $if_install_portainer =~ ^([Yy])$ ]]
then
	read -e -p $'Set Portainer External Port : ' -i "9999" portainer_external_port
fi

# sudo echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo apt --yes install software-properties-common aria2 bzip2 ca-certificates curl git gnupg gosu htop iotop iperf libcap2-bin libpng-dev make gcc nano net-tools nmap chrony openssh-server openssl p7zip poppler-utils apt-transport-https lsb-release python2 sqlite3 supervisor traceroute unar unzip wget zip zsh

# for nmtui
# sudo apt --yes install network-manager
# sudo curl -L "https://github.com/ariadata/ubuntu-lemp/raw/main/files/NetworkManager.conf" -o /etc/NetworkManager/NetworkManager.conf
# sudo systemctl enable --now network-manager

## docker + docker-compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt --yes update
sudo apt --yes install docker-ce docker-ce-cli containerd.io docker-compose
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
sudo systemctl enable --now docker

## install dockerhub.ir registery mirror file
if [[ $if_dockerhub_ir_registery_add =~ ^([Yy])$ ]]
then
	sudo curl -L "https://github.com/ariadata/ubuntu-sh/raw/master/files/docker-mirror-daemon.json" -o /etc/docker/daemon.json
	sudo systemctl restart docker
fi

## Install portainer
if [[ $if_install_portainer =~ ^([Yy])$ ]]
then
	docker pull portainer/portainer-ce:latest
	docker run -d -p $portainer_external_port:9000 --name=portainer --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
fi

### Update && Upgrade 
sudo apt --yes update && sudo apt -q --yes upgrade
sudo apt --yes autoremove

clear
### echo system and logins info

## reboot at the end
read -e -p $'Finished, Reboot Now ? : ' -i "y" if_reboot_at_end
if [[ $if_reboot_at_end =~ ^([Yy])$ ]]
then
	sudo reboot
	exit
fi