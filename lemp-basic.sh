#!/bin/sh
set -e
clear
if [[ $EUID = 0 ]]; then
	echo "Please run this script as non-root sudo user"
	exit 1
fi

# Set SSH Port
read -e -p $'Set/Change SSH port : ' -i "22" ssh_port_number
sudo sed -i 's/#Port 22/Port '$ssh_port_number'/g' /etc/ssh/sshd_config
sudo service ssh restart

# Change System timezone
read -e -p $'Change System TimeZone ? : ' -i "Asia/Tehran" system_default_timezone
sudo timedatectl set-timezone $system_default_timezone


read -e -p $'Folder name for domain(s) ? : \n' -i "test.com" domain_folder_name
read -e -p $'Enter domains FQDN (seperated by space , exp: test.com www.test.com ) : \n' www_domains
read -e -p $'Select PHP Version [7.4|8.0]: ' -i "8.0" php_version
read -e -p $'Install Composer [y/n]: ' -i "y" if_install_composer
read -e -p $'DataBase is MySQL8 / Change it to MariaDb ? : ' -i "y" if_change_db_to_mariadb
read -e -p $'Enter DataBase root password: \n' database_root_password

read -e -p $'Install PHPMyAdmin on pma folder ? : ' -i "y" if_install_pma
if [[ $if_install_pma =~ ^([Yy])$ ]]
then
	read -e -p $'Enter PHPMyAdmin FQDN: \n' pma_fqdn
fi

read -e -p $'Install Redis ? : ' -i "y" if_install_redis
#############################################################################

sudo apt --yes install software-properties-common aria2 bzip2 ca-certificates curl git gnupg gosu htop iotop iperf libcap2-bin libpng-dev make gcc nano net-tools nmap chrony openssh-server openssl p7zip poppler-utils apt-transport-https lsb-release python2 sqlite3 supervisor traceroute unar unzip wget zip zsh

cd ~
mkdir -p www
cd /home/$USER/www/
mkdir -p $domain_folder_name
sudo add-apt-repository --yes ppa:ondrej/php
sudo apt --yes update

# install php
if [[ $php_version = "8.0" ]]
then
	# install with 8.0
	sudo apt --yes install php8.0-cli php8.0-dev php8.0-pgsql php8.0-sqlite3 php8.0-gd php8.0-curl php8.0-memcached php8.0-imap php8.0-mysql php8.0-mbstring php8.0-xml php8.0-zip php8.0-bcmath php8.0-soap php8.0-intl php8.0-readline php8.0-pcov php8.0-msgpack php8.0-igbinary php8.0-ldap php8.0-redis php8.0-swoole php8.0-xdebug
else
	# install with 7.4
	sudo apt --yes install php7.4-cli php7.4-dev php7.4-pgsql php7.4-sqlite3 php7.4-gd php7.4-curl php7.4-memcached php7.4-imap php7.4-mysql php7.4-mbstring php7.4-xml php7.4-zip php7.4-bcmath php7.4-soap php7.4-intl php7.4-readline php7.4-pcov php7.4-msgpack php7.4-igbinary php7.4-ldap php7.4-redis php7.4-swoole php7.4-xdebug
fi

# install composer
if [[ $if_install_composer =~ ^([Yy])$ ]]
then
	sudo php -r "readfile('http://getcomposer.org/installer');" | sudo php -- --install-dir=/usr/bin/ --filename=composer
fi

# install pma
if [[ $if_install_pma =~ ^([Yy])$ ]]
then
	mkdir -p pma
	curl -L "https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz" -o pma.tgz
	tar -xzf pma.tgz -C pma --strip-components=1
	# copy config
fi

# install redis
if [[ $if_install_redis =~ ^([Yy])$ ]]
then
	# install redis
fi

# Install MySQL Server based on selection
if [[ $if_change_db_to_mariadb =~ ^([Yy])$ ]]
then
	# install mariadb
	sudo apt --yes install 
else
	# install mysql8
	sudo apt --yes install 
fi

## change mysql-mariadb root password
mysql_secure_installation <<EOF

y
y
$database_root_password
$database_root_password
y
y
y
y
EOF

# install nginx + configuration (nginx+phpfpm)



sudo apt --yes update && sudo apt -q --yes upgrade
sudo apt --yes autoremove
clear

## reboot at the end
read -e -p $'Finished, Reboot Now ? : ' -i "y" if_reboot_at_end
if [[ $if_reboot_at_end =~ ^([Yy])$ ]]
then
	sudo reboot
	exit
fi