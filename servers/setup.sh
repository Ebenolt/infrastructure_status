#!/bin/bash
if [[ $EUID -ne 0 ]]
then
        printf "\e[33m /!\ This script must be run with sudo /!\  \e[Om\n"
        exit 1
fi


if [ -z "$1" ] || [ -z "$2" ] || [-z "$3" ]
then
        printf "\e[31mMissing arguments \e[0m\n"
        printf 'Use like this: sudo ./script.sh "Device Name" "port to test (0 = no test)" "public (0/1)" \n'
	exit 1
fi

clear

sudo apt-get update
printf "Installing MySQL Client: "
sudo apt-get install mysql-common mysql-client && echo "* * * * * $(pwd)/servers_status.sh" >> /var/spool/cron/crontabs/$(who am i | awk '{print $1}') && printf "\e[32mOK\e[0m" || printf "\e[31mError\e[0m"


ip=$(hostname -I | awk '{print $1}')
currenttime=$(date +%s)
name=$1
port=$2
public=$3
