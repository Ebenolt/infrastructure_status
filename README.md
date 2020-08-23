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

You can now access your status interface from port 8090 😉
## Local Monitoring Device

Copy the servers folder to a local & same network machine and run setup like this:

```bash
sudo ./setup.sh "Device Name" "port to test (0 = no test)" "public (0/1)"
```

This machine will monitor every local machine on his network and send it to web interface

## Add a new device

Copy the servers/new_device.sh to the new device then run

```bash
./new_device.sh "Device Name" "port to test (0 = no test)" "public (0/1)"
```
The monitoring machine and the web interface will automatically opdate through web database
