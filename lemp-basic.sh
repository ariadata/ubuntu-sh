#!/bin/sh
set -e
clear
if [[ $EUID = 0 ]]; then
	echo "Please run this script as non-root sudo user"
	exit 1
fi

function get_latest_github_release_number() {
	curl --silent "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Set SSH Port
read -e -p $'Set/Change SSH port : ' -i "22" ssh_port_number
sudo sed -i 's/#Port 22/Port '$ssh_port_number'/g' /etc/ssh/sshd_config
sudo service ssh restart

# Change System timezone
read -e -p $'Change System TimeZone ? : ' -i "Asia/Tehran" system_default_timezone
sudo timedatectl set-timezone $system_default_timezone

read -e -p $'www folder name ? : \n' -i "www" www_folder_name
read -e -p $'Enter domains (seperated by space , exp: test.com www.test.com ) : \n' -i "www" www_domains



# sudo echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo apt --yes install software-properties-common aria2 bzip2 ca-certificates curl git gnupg gosu htop iotop iperf libcap2-bin libpng-dev make gcc nano net-tools nmap chrony openssh-server openssl p7zip poppler-utils apt-transport-https lsb-release python2 sqlite3 supervisor traceroute unar unzip wget zip zsh

# nmtui
# sudo apt --yes install network-manager
# sudo curl -L "https://github.com/ariadata/ubuntu-lemp/raw/main/files/NetworkManager.conf" -o /etc/NetworkManager/NetworkManager.conf
# sudo systemctl enable --now network-manager


# php
sudo add-apt-repository --yes ppa:ondrej/php
sudo apt --yes update
sudo apt --yes install php8.0-cli php8.0-dev php8.0-pgsql php8.0-sqlite3 php8.0-gd php8.0-curl php8.0-memcached php8.0-imap php8.0-mysql php8.0-mbstring php8.0-xml php8.0-zip php8.0-bcmath php8.0-soap php8.0-intl php8.0-readline php8.0-pcov php8.0-msgpack php8.0-igbinary php8.0-ldap php8.0-redis php8.0-swoole php8.0-xdebug
sudo php -r "readfile('http://getcomposer.org/installer');" | sudo php -- --install-dir=/usr/bin/ --filename=composer
sudo apt --yes update && sudo apt -q --yes upgrade
sudo apt --yes autoremove

# docker + docker-compose
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

sudo apt --yes update && sudo apt -q --yes upgrade

# laravel + larave-new command in bash
composer global require laravel/installer --update-with-all-dependencies
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
# source ~/.bashrc
# sudo chown -R $USER:$USER /home/$USER/.config/composer
### sail install alias
echo "alias sail='./vendor/bin/sail'" >> ~/.bash_aliases
echo 'laravel-new(){
	curl -s "https://laravel.build/$1" | bash
	sudo sed -i 's/laravel.test/'"$1"'.test/g' $1/docker-compose.yml
}' >> ~/.bash_aliases
source ~/.bash_aliases

# install portainer
docker pull portainer/portainer-ce:latest
docker run -d -p 9999:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# install phpmyadmin
# docker run --name phpmyadmin --restart=always -d -p 9998:80 -e PMA_HOST=host.docker.internal -e MYSQL_USERNAME=sail -e MYSQL_ROOT_PASSWORD=password phpmyadmin

# install nginx-proxy-manager
# Login : http://IP_ADDR:81
# User  : admin@example.com
# Pass  : changeme
docker run -d -p 80:80 -p 443:443 -p 81:81 --name=nginx-proxy-manager --restart=unless-stopped -e DB_SQLITE_FILE=/data/database.sqlite -e DISABLE_IPV6=true -v /data:/data -v /letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager

sudo apt --yes update && sudo apt -q --yes upgrade
# sudo reboot