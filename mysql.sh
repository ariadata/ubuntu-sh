#!/bin/bash
db_root_password="Lnkfile_3"

sudo mysql -e "DELETE FROM mysql.user WHERE user='';"
sudo mysql -e "DELETE FROM mysql.user WHERE user='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DROP DATABASE IF EXISTS test;DELETE FROM mysql.db WHERE db='test' OR db='test_%';"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}';FLUSH PRIVILEGES;"
