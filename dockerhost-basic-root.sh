#!/bin/sh
set -e
clear

function get_latest_github_release_number() {
	curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Update System First
read -e -p $'Update && Upgrade System first [y/n]? : ' -i "y" if_update_first

# Install Portainer
read -e -p $'Install Portainer [y/n]? : ' -i "n" if_install_portainer
if [[ $if_install_portainer =~ ^([Yy])$ ]]
then
	read -e -p $'Set Portainer External Port : ' -i "9999" portainer_external_port
fi

# Change System timezone
read -e -p $'Set Default System Timezone : ' -i "Europe/Istanbul" system_default_timezone
timedatectl set-timezone $system_default_timezone

if [[ $if_update_first =~ ^([Yy])$ ]]
then
	apt --yes update && apt -q --yes upgrade
fi

apt --yes install wget curl git nano lsb-release sqlite3 p7zip gnupg-agent apt-transport-https ca-certificates software-properties-common cron
systemctl enable --now cron

## docker + docker-compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt --yes update && apt-cache policy docker-ce
apt --yes install docker-ce docker-ce-cli containerd.io

docker_compose_latest_version="$(get_latest_github_release_number docker/compose)"
curl -L "https://github.com/docker/compose/releases/download/$docker_compose_latest_version/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

chmod 666 /var/run/docker.sock
systemctl enable --now docker

## Install portainer
if [[ $if_install_portainer =~ ^([Yy])$ ]]
then
	docker pull portainer/portainer-ce:latest
	docker run -d -p $portainer_external_port:9000 --name=portainer --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
fi

apt --yes remove snapd --purge
rm -rf ~/snap /var/snap /var/lib/snapd
apt --yes update && apt -q --yes upgrade && apt --yes autoremove

clear
## reboot at the end
read -e -p $'Finished, Reboot Now ? : ' -i "y" if_reboot_at_end
if [[ $if_reboot_at_end =~ ^([Yy])$ ]]
then
	reboot
	exit
fi
