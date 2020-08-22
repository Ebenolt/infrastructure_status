#!/bin/bash
clear

#Vars
webip='#web_ip#'
mysql_host='#mysql_host#'
mysql_user='#mysql_user#'
mysql_pass='#mysql_pass#'


time=$(date +%s)

#Reading all lines from status DB
mysql -BNr -h $mysql_host -u $mysql_user --password=$mysql_pass -D services_status -e "SELECT * FROM status" | while IFS=$'\t' read id name port lastseen servicelastseen public; do
	if [[ $port != "0" ]] #If checkable port
	then
	        printf "Testing $name [$id:$port]"
		if [[ $(curl -is https://$webip:$port --max-time 5| head -1 | awk '{print $3}') = OK* || $(curl -is http://$webip:$port --max-time 5| head -1 | awk '{print $3}') = OK* ]] #Check if can get data from this port
		then
			printf "\e[32m OK \e[0m \n"
			mysql -h $mysql_host -u $mysql_user --password=$mysql_pass -D services_status -e "UPDATE status SET servicelastseen = $time WHERE id='$id'" #Update DB
		else
			printf "\e[31m KO \e[0m \n"
		fi
	else
	        printf "\e[33mNot Testing $name ($id)\e[0m \n"
	fi

done;
