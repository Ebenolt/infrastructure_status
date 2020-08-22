# Infrastructure Status Simple Web Interface
Simple and lightweight web interface to show running devices on your infrastructure.

## Installation

Clone the repository:
```bash
git clone https://github.com/Ebenolt/infrastructure_status.git
```

Then install it on a distant web server using:
```bash
sudo ./setup.sh
```


Follow the Instructions:

	* -Database IP : Public IP Where the DB could be accessible
	* -Database username : Username to access the table
	* -Database password : Password to access the table
	* -Web IP : Public IP Where all services can get scrapped

	* -Bot email : Email asdress where alerts email will be sent
	* -Bot pass : Password for that email adress
	* -Mailserver SMTP : Mailserver SMTP address
	* -Mailserver port : Mailserver SMTP port
	* -Receiver email : Adress who will receive alerts

Once it get setup copy your web_if folder to your favourite web server folder and put a domain-name on it ;)😉

## Infrastructure monitoring

Copy the servers/server_status.sh to a local, same network machine and run (check script path):

```bash
sudo apt-get install mysql-common mysql-client && echo "* * * * * /path/to/script.sh" >> /var/spool/cron/crontabs/$(whoami) 
```
