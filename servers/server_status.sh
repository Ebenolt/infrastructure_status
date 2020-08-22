#!/bin/bash
time=$(date +%s)


mysql_host="#mysql_host#"
mysql_user="#mysql_user#"
mysql_pass="#mysql_pass#"

clear

#Reading all lines from status DB
mysql -BNr -h $mysql_host -u $mysql_user --password=$mysql_pass -D services_status -e "SELECT * FROM status" | while IFS=$'\t' read id name port lastseen servicelastseen public; do
#        printf "Testing $name [$id]"
	if [[ $(ping $id -c 1| grep received | awk '{print $4}') = "1" ]] #Check if can get data from this port
	then
#		printf "\e[32m OK \e[0m \n"
		if [ $port != "0" ]
		then
			mysql -h $mysql_host -u $mysql_user --password=$mysql_pass -D services_status -e "UPDATE status SET lastseen = $time WHERE id='$id'" #Update DB
		else
			mysql -h $mysql_host -u $mysql_user --password=$mysql_pass -D services_status -e "UPDATE status SET lastseen = $time WHERE id='$id'; UPDATE status SET servicelastseen = $time WHERE id='$id'" #Update DB
		fi
#	else
#		printf "\e[31m KO \e[0m \n"
	fi
done;
