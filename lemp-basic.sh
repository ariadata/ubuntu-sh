#!/bin/sh
set -e
clear
if [[ $EUID = 0 ]]; then
	echo "Please run this script as non-root sudo user"
	exit 1
fi

sudo service ssh restart

# Set SSH Port
read -e -p $'Set/Change SSH port : ' -i "22" ssh_port_number
sudo sed -i 's/#Port 22/Port '$ssh_port_number'/g' /etc/ssh/sshd_config
sudo service ssh restart

# Change System timezone
read -e -p $'Change System TimeZone ? : ' -i "Asia/Tehran" system_default_timezone
sudo timedatectl set-timezone $system_default_timezone

read -e -p $'Folder name for domain(s) ? : ' -i "test" domain_folder_name
read -e -p $'Enter domains FQDN (seperated by space , exp: test.com www.test.com ) : \n' www_domains
read -e -p $'Select PHP Version [7.4|8.0]: ' -i "8.0" php_version
read -e -p $'Install Composer [y/n]: ' -i "y" if_install_composer
read -e -p $'DataBase is MySQL8 / Change it to MariaDb-10.6 ? : ' -i "n" if_change_db_to_mariadb
read -e -p $'Enter DataBase root password: \n' database_root_password

read -e -p $'Install PHPMyAdmin on pma folder ? : ' -i "y" if_install_pma
if [[ $if_install_pma =~ ^([Yy])$ ]]
then
	read -e -p $'Enter PHPMyAdmin FQDN: \n' pma_fqdn
fi

read -e -p $'Install Redis ? : ' -i "y" if_install_redis
#############################################################################
sudo apt --yes install software-properties-common aria2 bzip2 ca-certificates curl git gnupg gosu htop iotop iperf libcap2-bin libpng-dev make gcc nano net-tools nmap chrony openssh-server openssl p7zip poppler-utils apt-transport-https lsb-release python2 sqlite3 supervisor traceroute unar unzip wget zip zsh

cd /home/$USER/
mkdir -p www
cd www
mkdir -p $domain_folder_name
sudo add-apt-repository --yes ppa:ondrej/php
sudo apt --yes update

# install php
if [[ $php_version = "8.0" ]]
then
	# install with 8.0
	sudo apt --yes install php8.0-cli php8.0-fpm php8.0-dev php8.0-pgsql php8.0-sqlite3 php8.0-gd php8.0-curl php8.0-memcached php8.0-imap php8.0-mysql php8.0-mbstring php8.0-xml php8.0-zip php8.0-bcmath php8.0-soap php8.0-intl php8.0-readline php8.0-pcov php8.0-msgpack php8.0-igbinary php8.0-ldap php8.0-redis php8.0-swoole php8.0-apcu
else
	# install with 7.4
	sudo apt --yes install php7.4-cli php7.4-fpm php7.4-dev php7.4-pgsql php7.4-sqlite3 php7.4-gd php7.4-curl php7.4-memcached php7.4-imap php7.4-mysql php7.4-mbstring php7.4-xml php7.4-zip php7.4-bcmath php7.4-soap php7.4-intl php7.4-readline php7.4-pcov php7.4-msgpack php7.4-igbinary php7.4-ldap php7.4-redis php7.4-swoole php7.4-apcu
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
	rm -f pma.tgz
	# copy config
fi

# install redis
if [[ $if_install_redis =~ ^([Yy])$ ]]
then
	# install redis
	sudo add-apt-repository --yes ppa:redislabs/redis
	sudo apt --yes update
	sudo apt --yes install redis
fi

# Install MySQL Server based on selection
if [[ $if_change_db_to_mariadb =~ ^([Yy])$ ]]
then
	# install mariadb
	sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
	sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.6/ubuntu $(lsb_release -cs) main"
	sudo apt --yes update
	sudo apt --yes install mariadb-server
else
	# install mysql8
	sudo apt --yes install mysql-server
fi

## change mysql-mariadb root password


if [[ $if_change_db_to_mariadb =~ ^([Yy])$ ]]
then
sudo mysql_secure_installation <<EOF

y
y
$database_root_password
$database_root_password
y
y
y
y
EOF
else
	sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
	sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	sudo mysql -e "DROP DATABASE IF EXISTS test;DELETE FROM mysql.db WHERE db='test' OR db='test_%';"
	sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${database_root_password}';FLUSH PRIVILEGES;"
fi

# install nginx + configuration (nginx+phpfpm)
## php-fpm config
sudo apt --yes install nginx
sudo mv /etc/php/$php_version/fpm/pool.d/www.conf /etc/php/$php_version/fpm/pool.d/www.conf.bak
sudo curl -L "https://github.com/ariadata/ubuntu-sh/raw/master/files/php-fpm-$php_version-www-template.conf" -o /etc/php/$php_version/fpm/pool.d/www.conf
sudo sed -i 's/ubuntu/'$USER'/g' /etc/php/$php_version/fpm/pool.d/www.conf

## default page for site
curl -L "https://github.com/ariadata/ubuntu-sh/raw/master/files/under_cunstruction.html" -o /home/$USER/www/$domain_folder_name/index.html

## nginx config for domains
sudo curl -L "https://github.com/ariadata/ubuntu-sh/raw/master/files/nginx-basic-template.conf" -o /etc/nginx/sites-available/$domain_folder_name
sudo ln -s /etc/nginx/sites-available/$domain_folder_name /etc/nginx/sites-enabled/$domain_folder_name
sudo sed -i "s/##domain_name##/$www_domains/g" /etc/nginx/sites-available/$domain_folder_name
sudo sed -i "s/##folder_path##/\/home\/$USER\/www\/$domain_folder_name/g" /etc/nginx/sites-available/$domain_folder_name
sudo sed -i "s/##php_version##/$php_version/g" /etc/nginx/sites-available/$domain_folder_name

## nginx config for pma
if [[ $if_install_pma =~ ^([Yy])$ ]]
then
	sudo curl -L "https://github.com/ariadata/ubuntu-sh/raw/master/files/nginx-basic-template.conf" -o /etc/nginx/sites-available/phpmyadmin
	sudo ln -s /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/phpmyadmin
	sudo sed -i "s/##domain_name##/$pma_fqdn/g" /etc/nginx/sites-available/phpmyadmin
	sudo sed -i "s/##folder_path##/\/home\/$USER\/www\/pma/g" /etc/nginx/sites-available/phpmyadmin
	sudo sed -i "s/##php_version##/$php_version/g" /etc/nginx/sites-available/phpmyadmin
fi

## nginx change default 
sudo curl -L "https://github.com/ariadata/ubuntu-sh/raw/master/files/nginx-default-template.conf" -o /etc/nginx/sites-available/default

## mysql+mariadb conf
sudo curl -L "https://github.com/ariadata/ubuntu-sh/raw/master/files/mysql-custom-config.cnf" -o /etc/mysql/conf.d/custom.cnf

## create user mariadb-mysql
# sudo mysql -u root -p${database_root_password} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$database_root_password' WITH GRANT OPTION;FLUSH PRIVILEGES;"

## 
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