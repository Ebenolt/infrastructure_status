#!/bin/bash


if [[ $EUID -ne 0 ]]; then
        printf "\e[33m /!\ This script must be run with sudo /!\ \e[0m\n"
        exit 1
fi

clear

username=$(who am i | awk '{print $1}')
working_dir=$(pwd)


echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update >> /dev/null 2>&1
printf "Installing webserver, sql server & utilities: "
apt-get install nginx python3 curl mysql-client python3-pip mysql-server apt-transport-https lsb-release ca-certificates -y >> /dev/null 2>&1 && printf "\e[32mOK\e[0m" || printf "\e[31mError\e[0m"
echo "bind-address            = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
apt-get update >> /dev/null 2>&1

printf "\nInstalling PHP: "
apt-get install php7.4 php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-mysql php7.4-zip php7.4-fpm php7.4-mbstring -y --allow-unauthenticated>> /dev/null 2>&1 && printf "\e[32mOK\e[0m" || printf "\e[31mError\e[0m"
apt-get update >> /dev/null 2>&1

printf "\nInstalling pip mysql-connector: "
pip3 install mysql-connector >> /dev/null 2>&1 && printf "\e[32mOK\e[0m" || printf "\e[31mError\e[0m"
printf "\n\n"

systemctl enable mariadb.service nginx >> /dev/null 2>&1

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

#web/create.sql
sed -i "s/#mysql_user#/$host_user/g" web/create.sql
sed -i "s/#mysql_pass#/$host_pass/g" web/create.sql


echo "* * * * * $working_dir/web/service_status.sh" >> "/var/spool/cron/crontabs/$username"
echo "*/5 * * * * python3 $working_dir/web/mail_status.py"  >> "/var/spool/cron/crontabs/$username"

mysql < web/create.sql

mysql -h $host_ip -u $host_user -p$host_pass -D services_status < web/dump.sql

mv web/nginx_host /etc/nginx/sites-available/status && ln -s /etc/nginx/sites-available/status /etc/nginx/sites-enabled/status

mv web/web_if /var/www/status

chown -R $username:www-data /var/www/status
chmod -R 775 /var/www/status


sudo systemctl restart mysqld.service mariadb.service nginx.service
