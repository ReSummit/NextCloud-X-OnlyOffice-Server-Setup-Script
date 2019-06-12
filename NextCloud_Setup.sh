#!/bin/bash

if [ "$EUID" -ne 0 ]
then 
	echo "You need to run this script using sudo. This installation script installs packages, which requires sudo"
	exit
fi

echo "Please make sure to read the instructions on the GitHub repository before beginning:"
echo "https://github.com/ReSummit/NextCloud-X-OnlyOffice-Server-Setup-Script/blob/master/README.md"
sleep 3s

echo "This script assumes that you already setup the domain for the server. Are you sure you want to install NextCloud? [N/y]"
read installChoice

# Check if no input was given
if [[ -z $installChoice ]] || [ $installChoice != "y" ];
then
	echo "Make sure you are ready to install NextCloud and OnlyOffice."
	exit
fi

echo "Would you like to install OnlyOffice alongside NextCloud? [N/y]"
read onlyOfficeChoice

if [[ -z $onlyOfficeChoice ]] || [ $onlyOfficeChoice != "y" ];
then
	echo
	echo "OnlyOffice will not be installed."
else
	echo
	echo "OnlyOffice will be installed."
fi

if [ $installChoice == "y" ];
then
	# Step 0: Install required files
	sudo apt --assume-yes install apt-transport-https ca-certificates curl software-properties-common
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
	sudo add-apt-repository -y ppa:certbot/certbot
	sudo apt --assume-yes install make gcc docker-ce vim-gtk3 mysql-server apache2 php7.2 php7.2-gd php7.2-json php7.2-mysql php7.2-curl php7.2-mbstring php7.2-intl php7.2-imagick php7.2-xml php7.2-zip libapache2-mod-php7.2 certbot python-certbot-apache nginx python-certbot-nginx

	# Step 1: Configure MySQL
	echo
	echo "Finished installing required packages."
	echo
	echo "What database username do you want to use?"
	read dataUser
	echo
	echo "Enter the password for the database (You'll need both the database name, user, and password later."
	read dataPass
	echo

	mysql -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
	mysql -e "GRANT ALL ON nextcloud.* TO '$dataUser'@'localhost' IDENTIFIED BY '$dataPass';"
	mysql -e "FLUSH PRIVILEGES;"

	# Open ports for Nginx
	sudo ufw allow 'Nginx Full'

	# Step 2: Install NextCloud
	echo "What is the latest NextCloud version number?"
	read ncVersion
	sudo wget https://download.nextcloud.com/server/releases/nextcloud-$ncVersion.zip -P /tmp
	sudo unzip /tmp/nextcloud-$ncVersion.zip  -d /var/www
	sudo chown -R www-data: /var/www/nextcloud
	rm /tmp/nextcloud-$ncVersion.zip
	
	# Step 3: Configure Apache as backend
	echo "Please fix the ports for Apache2's NextCloud configuration. (Use any ports that are NOT any of the ports given in OnlyOffice's ports from https://helpcenter.onlyoffice.com/server/docker/document/open-ports.aspx so you can install OnlyOffice. Remember this port, you'll need it when configuring OnlyOffice) Press Enter when ready."
	read a
	sudo vim /etc/apache2/ports.conf

	echo
	echo "Please enter the configuration for Apache2's NextCloud configuration. (Use https://felixbreuer.me/tutorial/Setup-NextCloud-FrontEnd-Nginx-SSL-Backend-Apache2.html or the Github Apache2 configuration as the example). Use the same port number as you entered in your Apache2 file. Press Enter when ready."
	read a
	sudo vim /etc/apache2/sites-available/nextcloud.conf

	sudo a2ensite nextcloud
	sudo a2enmod rewrite headers env dir mime
	sudo a2dissite 000-default
	sudo systemctl restart apache2

	# Step 4: Configure Nginx as frontend
	echo "Please create the Nginx configuration for NextCloud. (Use https://felixbreuer.me/tutorial/Setup-NextCloud-FrontEnd-Nginx-SSL-Backend-Apache2.html if you only want NextCloud. If you are running OnlyOffice too, use the Github Nginx configuration.) Make sure you change your ports to the port you indicated before. Press Enter when ready."
	read a
	sudo vim /etc/nginx/sites-available/nextcloud
	
	# Enable NextCloud Nginx site
	sudo ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/
	sudo rm /etc/nginx/sites-enabled/default
	sudo nginx -t
	
	echo "If you want to upload large files, go ahead and change the nginx config. Otherwise, leave it alone."
	sleep 10s
	sudo vim /etc/nginx/nginx.conf
	
	sudo service nginx restart

	# Step 5: Setup SSL
	echo
	echo "Give the domain you want to use for SSL"
	read domain

	sudo certbot --nginx --domains $domain

	echo
	echo "Please enter http://localhost/nextcloud into the browser. Your database name should be nextcloud. Just a gentle reminder of your user and password if you forgot:"
	tr
	echo "User: $dataUser"
	echo "Password: $dataPass"
	sleep 10s
	echo "Press Enter when you are ready."
	read a

	echo
	echo "Put that domain in the listing in the NextCloud config. You'll need it when you access the server through the domain."
	sudo vim /var/www/nextcloud/config/config.php
	
	# Step 5: Install OnlyOffice if wanted
	if [ $onlyOfficeChoice == "y" ];
	then
		curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
		sudo apt-get install --assume-yes postgresql 
		
		echo
		echo "Installing OnlyOffice."
		echo
		echo "Enter the password for the onlyOffice database (You'll need both the database name, user, and password later."
		read onlyOfficePass
		echo

		sudo -i -u postgres psql -c "CREATE DATABASE onlyoffice;"
		sudo -i -u postgres psql -c "CREATE USER onlyoffice WITH password '$onlyOfficePass';"
		sudo -i -u postgres psql -c "GRANT ALL privileges ON DATABASE onlyoffice TO onlyoffice;"

		sudo apt-get install --assume-yes redis-server rabbitmq-server nginx-extras nodejs
		
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
		sudo echo "deb http://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list
		sudo apt-get update

		echo onlyoffice-documentserver onlyoffice/ds-port select 442 | sudo debconf-set-selections
		sudo apt-get install --assume-yes onlyoffice-documentserver
	else
		echo "OnlyOffice will not be installed. To install it later, use the script to install OnlyOffice. (Coming Soon!)"
		sleep 2s
	fi

	echo "The installation is complete! Please go to https://$domain/nextcloud (default) to setup your server."
fi