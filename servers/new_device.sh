#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [-z "$3" ]
then
        printf "\e[31mMissing arguments \e[0m\n"
        printf 'Use like this: sudo ./script.sh "Device Name" "port to test (0 = no test)" "public (0/1)" \n'
	exit 1
fi

clear

ip=$(hostname -I | awk '{print $1}')
currenttime=$(date +%s)
name=$1
port=$2
public=$3

printf "\n\nAdding $name ($ip:$port) into devices: " && mysql -h #mysql_host# -u #mysql_user# --password="#mysql_pass#" -D services_status -e "INSERT INTO status VALUES ('$ip', '$name' , '$port', '$currenttime', '$currenttime', '$public')" >/dev/null 2>&1 && printf "\e[32mOK\e[0m\n"
