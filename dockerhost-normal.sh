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

function get_latest_github_release_number() {
	curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# add dockerhub.ir registery
read -e -p $'Add dockerhub.ir mirror to docker registery [y/n]? : ' -i "n" if_dockerhub_ir_registery_add

# extra dns servers , shecan : 185.51.200.2,178.22.122.100  | begzar : 185.55.226.26,185.55.225.25
read -e -p $'Add extra nameservers [y/n]? : ' -i "n" if_set_extra_dns_servers
if [[ $if_set_extra_dns_servers =~ ^([Yy])$ ]]
then
	read -e -p $'Enter NS IPs seperated by "," :\n' new_name_servers
	IFS=',' read -r -a ns_arr <<< "$new_name_servers"
	for element in "${ns_arr[@]}"
	do
		sudo sed -i '1 i\nameserver '"$element" /etc/resolv.conf
	done
fi

# Set Proxy for docker
#read -e -p $'Set Proxy for docker [y/n]? : ' -i "n" if_set_proxy_for_docker
#if [[ $if_set_proxy_for_docker =~ ^([Yy])$ ]]
#then
#	read -e -p $'Proxy Host ? : \n' docker_proxy_host
#	read -e -p $'Proxy Port ? : \n' docker_proxy_port
#	read -e -p $'Proxy Username ? \n' docker_proxy_user
#	read -e -p $'Proxy Password ? \n' docker_proxy_pass
#fi

# Install Portainer
read -e -p $'Install Portainer [y/n]? : ' -i "y" if_install_portainer
if [[ $if_install_portainer =~ ^([Yy])$ ]]
then
	read -e -p $'Set Portainer External Port : ' -i "9999" portainer_external_port
fi

# Install Nginx-Proxy-Manager
read -e -p $'Install Nginx-Proxy-Manager [y/n]? : ' -i "n" if_install_nginx_proxy_manager
if [[ $if_install_nginx_proxy_manager =~ ^([Yy])$ ]]
then
	read -e -p $'Set Nginx-Proxy-Manager External Port : ' -i "8181" nginx_proxy_manager_external_port
fi

# Install PHP-CLI
read -e -p $'Install PHP-CLI + composer [y/n]? : ' -i "n" if_install_php_cli_composer
if [[ $if_install_php_cli_composer =~ ^([Yy])$ ]]
then
	read -e -p $'Version [7.4|8.0]: ' -i "8.0" php_cli_version
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
sudo apt --yes install docker-ce docker-ce-cli containerd.io
docker_compose_latest_version="$(get_latest_github_release_number docker/compose)"
sudo curl -L "https://github.com/docker/compose/releases/download/$docker_compose_latest_version/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
sudo systemctl enable --now docker
## set docker proxy here ???????????????????
############################################

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

# Install Nginx-Proxy-Manager
# Login : http://IP_ADDR:8181
# User  : admin@example.com
# Pass  : changeme
if [[ $if_install_nginx_proxy_manager =~ ^([Yy])$ ]]
then
	docker run -d -p 80:80 -p 443:443 -p $nginx_proxy_manager_external_port:81 --name=nginx-proxy-manager --restart=unless-stopped -e DB_SQLITE_FILE=/data/database.sqlite -e DISABLE_IPV6=true -v /data:/data -v /letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager
fi

# Install PHP-CLI
if [[ $if_install_php_cli_composer =~ ^([Yy])$ ]]
then
	sudo add-apt-repository --yes ppa:ondrej/php
	sudo apt --yes update
	
	# if [[ $php_cli_version = "8.0" || $php_cli_version = "8.1" ]]
	if [[ $php_cli_version = "8.0" ]]
	then
		# install with 8.0
		sudo apt --yes install php8.0-cli php8.0-dev php8.0-pgsql php8.0-sqlite3 php8.0-gd php8.0-curl php8.0-memcached php8.0-imap php8.0-mysql php8.0-mbstring php8.0-xml php8.0-zip php8.0-bcmath php8.0-soap php8.0-intl php8.0-readline php8.0-pcov php8.0-msgpack php8.0-igbinary php8.0-ldap php8.0-redis php8.0-swoole php8.0-apcu php8.0-xdebug php8.0-imagick
	else
		# install with 7.4
		sudo apt --yes install php7.4-cli php7.4-dev php7.4-pgsql php7.4-sqlite3 php7.4-gd php7.4-curl php7.4-memcached php7.4-imap php7.4-mysql php7.4-mbstring php7.4-xml php7.4-zip php7.4-bcmath php7.4-soap php7.4-intl php7.4-readline php7.4-pcov php7.4-msgpack php7.4-igbinary php7.4-ldap php7.4-redis php7.4-swoole php7.4-apcu php7.4-xdebug php7.4-imagick
	fi

	sudo php -r "readfile('http://getcomposer.org/installer');" | sudo php -- --install-dir=/usr/bin/ --filename=composer
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