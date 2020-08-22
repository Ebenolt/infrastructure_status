import time, mysql.connector, smtplib, datetime
from mysql.connector import Error
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


#VARS
warningtime=125 #Time down to get a warning email
mysql_host='#mysql_host#'
mysql_user='#mysql_user#'
mysql_pass='#mysql_pass#'
#
mysql_db='service_status'
#

#Sender Mail Credentials
mailusername = '#sender@domain.com#'
mailpassword = '#mail_pass#'
mailserver = '#smtp.domain.com#'
mailport = '#mail_port#'

#Cible
email_receiver = '#receiver@domain.com#'
email_subject = 'Infrastructure Status'
email_masquerade = 'Status Bot <#sender@domain.com#>'


devices = []
error = 0
timestamp = int(time.time())
mailcontent="Theses servers are down:\n"


try:
	connection = mysql.connector.connect(host=mysql_host, database=mysql_db, user=mysql_user, password=mysql_pass)

	sql_select_Query = "select * from status"
	cursor = connection.cursor()
	cursor.execute(sql_select_Query)
	records = cursor.fetchall()

	for row in records:
		device= {"ip":row[0], "name":row[1], "lastseen":row[3], "servicelastseen":row[4]}
		devices.append(device)


	for elem in devices:
		if(int(elem["servicelastseen"])< int(time.time())-warningtime):
			error = 1
			mailcontent += "	- "+elem["name"]+" ["+elem['ip']+"]:\n	    "
			if( int(elem["lastseen"])< int(time.time())-warningtime):
				mailcontent += "Service down since "+datetime.datetime.fromtimestamp(elem['servicelastseen']).strftime('%H:%M')+"\n 	    Serveur down since "+datetime.datetime.fromtimestamp(elem['lastseen']).strftime('%H:%M')
			else:
				mailcontent += "Service: "+datetime.datetime.fromtimestamp(elem['servicelastseen']).strftime('%H:%M')
			mailcontent+="\n"

except Error as e:
	error = 1
	mailcontent = "Error, unreacheable host"
finally:
	if 'connection' in locals():
		if(connection.is_connected()):
			connection.close()
			cursor.close()

msg=MIMEMultipart()
msg['From'] = email_masquerade
msg['To'] = email_receiver
msg['Subject'] = email_subject
msg['Subject'] = email_subject


mailbody = mailcontent
msg.attach(MIMEText(mailbody,'text'))

mailcontent=msg.as_string()

if error:
	server = smtplib.SMTP(mailserver, mailport)
	server.starttls()
	server.login(mailusername, mailpassword)
	server.sendmail(mailusername,email_receiver, mailcontent)
	server.quit()

