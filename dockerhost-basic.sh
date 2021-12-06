#!/bin/sh
set -e
clear
if [[ $EUID = 0 ]]; then
	echo "Please run this script as non-root sudo user"
	exit 1
fi

# Update System First
read -e -p $'Update && Upgrade System first [y/n]? : ' -i "y" if_update_first
# Install Portainer
read -e -p $'Install Portainer [y/n]? : ' -i "n" if_install_portainer
if [[ $if_install_portainer =~ ^([Yy])$ ]]
then
	read -e -p $'Set Portainer External Port : ' -i "9999" portainer_external_port
fi

if [[ $if_update_first =~ ^([Yy])$ ]]
then
	sudo apt --yes update && sudo apt -q --yes upgrade
fi
# sudo echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo apt --yes install wget curl git nano lsb-release sqlite3 p7zip

## docker + docker-compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt --yes update
sudo apt --yes install docker-ce docker-ce-cli containerd.io docker-compose
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
sudo systemctl enable --now docker

## Install portainer
if [[ $if_install_portainer =~ ^([Yy])$ ]]
then
	docker pull portainer/portainer-ce:latest
	docker run -d -p $portainer_external_port:9000 --name=portainer --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
fi

## snapd : https://tinyurl.com/y4r2bqh3
sudo apt --yes remove snapd --purge
sudo rm -rf ~/snap /var/snap /var/lib/snapd
sudo apt --yes autoremove

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
