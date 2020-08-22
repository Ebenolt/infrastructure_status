#!/bin/bash


if [[ $EUID -ne 0 ]]; then
        printf "\e[33m /!\ This script must be run with sudo /!\ \e[0m\n"
        exit 1
fi

clear

username=$(who am i | awk '{print $1}')
working_dir=$(pwd)
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update
apt-get install php7.7 php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-mysql php7.4-zip php7.4-fpm php7.4-mbstring
sudo apt-get install nginx python3 curl mysql-client python3-pip mysql-server apt-transport-https lsb-release ca-certificates && pip3 install mysql-connector
systemctl enable mariadb.service nginx

echo "Database infos:"
read -p " -Database IP: " host_ip
read -p " -Database username: " host_user
read -p " -Database password: " host_pass
read -p " -Web IP: " web_ip

echo ""
echo "Database infos:"
read -p " -Bot email: " sender_email
read -p " -Bot pass: " sender_pass
read -p " -Mailserver SMTP: " sender_smtp
read -p " -Mailserver port: " sender_port
read -p " -Receiver email: " receiver_email

#web/service_status.sh
sed -i "s/#mysql_host#/$host_ip/g" web/service_status.sh
sed -i "s/#mysql_user#/$host_user/g" web/service_status.sh
sed -i "s/#mysql_pass#/$host_pass/g" web/service_status.sh
sed -i "s/#web_ip#/$web_ip/g" web/service_status.sh

#web/mail_status.py
sed -i "s/#mysql_host#/$host_ip/g" web/mail_status.py
sed -i "s/#mysql_user#/$host_user/g" web/mail_status.py
sed -i "s/#mysql_pass#/$host_pass/g" web/mail_status.py

#mails
sed -i "s/#sender@domain.com#/$sender_email/g" web/mail_status.py
sed -i "s/#mail_pass#/$sender_pass/g" web/mail_status.py
sed -i "s/#smtp.domain.com#/$sender_smtp/g" web/mail_status.py
sed -i "s/#mail_port#/$sender_port/g" web/mail_status.py
sed -i "s/#mail_receiver#/$receiver_email/g" web/mail_status.py

#servers/server_status.sh
sed -i "s/#mysql_host#/$host_ip/g" servers/server_status.sh
sed -i "s/#mysql_user#/$host_user/g" servers/server_status.sh
sed -i "s/#mysql_pass#/$host_pass/g" servers/server_status.sh

#web/web_if/vars.php
sed -i "s/#mysql_user#/$host_user/g" web/web_if/vars.php
sed -i "s/#mysql_pass#/$host_pass/g" web/web_if/vars.php


echo "* * * * * $pwd/web/service_status.sh" >> "/var/spool/cron/crontabs/$username"
echo "*/5 * * * * python3 $pwd/web/mail_status.py"  >> "/var/spool/cron/crontabs/$username"

printf "
CREATE DATABASE 'services_status';\n
CREATE USER '$host_user'@'%' IDENTIFIED BY '$host_pass';\n
GRANT ALL PRIVILEGES ON 'services_status'.* TO '$host_user'@'%';\n
FLUSH PRIVILEGES;\n" >> create.sql

mysql < create.sql
rm -f create.sql

echo "bind-address            = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf

sudo systemctl restart mysqld.service mariadb.service

mysql -h $host_ip -u $mysql_user -p$mysql_pass -D services_status < web/dump.sql
