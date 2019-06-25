#!/bin/bash
# Sources Used: All sources on https://github.com/ReSummit/NextCloud-X-OnlyOffice-Server-Setup-Script/blob/master/README.md

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
	onlyOfficeChoice="N"
else
	echo
	echo "OnlyOffice will be installed."
fi

echo "You have the option to choose whether Nextcloud should run on Apache2 (Beta) or Nginx (Stable). Do you want to run Nextcloud on Apache2? [N/y]"
read betaChoice

if [[ -z $betaChoice ]] || [ $betaChoice != "y" ];
then
	echo
	echo "Nextcloud will run on Nginx."
	betaChoice="N"
else
	echo
	echo "Nextcloud will run on Apache."
fi

echo
echo "You can always change where Nextcloud runs later by switching the configurations and packages installed."
echo

if [ $installChoice == "y" ];
then
	# Step 0: Install required files
	sudo apt --assume-yes install apt-transport-https ca-certificates curl software-properties-common
	sudo add-apt-repository -y ppa:certbot/certbot

	if [ $betaChoice == "y" ];
	then
		sudo apt --assume-yes install make gcc vim-gtk3 mysql-server certbot nginx python-certbot-nginx apache2 php7.2 php7.2-gd php7.2-json php7.2-mysql php7.2-curl php7.2-mbstring php7.2-intl php7.2-imagick php7.2-xml php7.2-zip libapache2-mod-php7.2
	else
		sudo add-apt-repository -y ppa:ondrej/php
		sudo apt --assume-yes install make gcc vim-gtk3 mysql-server certbot nginx python-certbot-nginx php7.3 php7.3-fpm php7.3-mysql php-common php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-readline php7.3-mbstring php7.3-xml php7.3-gd php7.3-curl php-imagick php7.3-zip php7.3-bz2 php7.3-intl
		sudo systemctl start php7.3-fpm
		sudo systemctl enable php7.3-fpm
	fi

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
	ncVersion="$(curl -s https://nextcloud.com/changelog/ | grep -Eo "([0-9]{1,}\.)+[0-9]{1,}+(\.tar){1}" | uniq -d | sed 's/\.tar//' | head -n 1)"
	# ncVersion="$(curl -s https://download.nextcloud.com/server/releases/ | grep -Eo "([0-9]{1,}\.)+[0-9]{1,}" | uniq -d | sort -nr | head -n 1)"
	sudo wget https://download.nextcloud.com/server/releases/nextcloud-$ncVersion.zip -P /tmp
	sudo unzip /tmp/nextcloud-$ncVersion.zip  -d /var/www
	sudo chown -R www-data: /var/www/nextcloud
	rm /tmp/nextcloud-$ncVersion.zip
	
	if [ $betaChoice == "y" ];
	then
		# Step 3a: Configure Apache as backend
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
	fi

	# Step 3b: Configure Nginx as frontend
	if [ $betaChoice == "y" ];
	then
		echo "Please create the Nginx configuration for NextCloud. (Use https://felixbreuer.me/tutorial/Setup-NextCloud-FrontEnd-Nginx-SSL-Backend-Apache2.html if you only want NextCloud. If you are running OnlyOffice too, use the Github Nginx configuration.) Make sure you change your ports to the port you indicated before. Press Enter when ready."
	else
		echo "Please create the Nginx configuration for NextCloud. (Use the Github configuration. Remove the section where it says 'location /onlyoffice/' if you don't want OnlyOffice). Note the comments about SSL! You will edit this file to uncomment the blocks later. Press Enter when ready."
	fi
	read a
	sudo vim /etc/nginx/sites-available/nextcloud
	
	# Enable NextCloud Nginx site
	sudo ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/
	sudo rm /etc/nginx/sites-enabled/default
	sudo nginx -t
	
	echo "If you want to upload large files, go ahead and change the nginx config as stated on https://felixbreuer.me/tutorial/Setup-NextCloud-FrontEnd-Nginx-SSL-Backend-Apache2.html. Otherwise, leave it alone. Press Enter when ready."
	read a
	sudo vim /etc/nginx/nginx.conf
	
	sudo service nginx restart

	# Step 4: Setup SSL
	echo
	echo "Give the domain you want to use for SSL"
	read domain

	sudo certbot --nginx --domains $domain

	if [ $betaChoice != "y" ];
	then
		echo "Edit the nextcloud Nginx configuration again so your server can be accessed. Press Enter when ready."
		read a
		sudo vim /etc/nginx/sites-available/nextcloud
	fi

	echo
	echo "Please enter http://$domain/nextcloud into the browser. Your database name should be nextcloud. Just a gentle reminder of your user and password if you forgot:"
	echo "User: $dataUser"
	echo "Password: $dataPass"
	sleep 10s
	echo "Press Enter when you are ready."
	read a

	echo "Just a note that you can't access your fileserver with \"localhost\". If you want to do that, adjust the Nginx file and change the Nextcloud config in /var/www/nextcloud/config/config.php."
	sleep 10s
	echo
	
	# Step 5: Install OnlyOffice if wanted
	if [ $onlyOfficeChoice == "y" ];
	then
		echo "Alright! Nextcloud is installed! We're not done yet though, as you indicated that you wanted to install OnlyOffice. Let's install that now."
		echo
		sleep 10s;

		curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
		sudo apt-get install --assume-yes postgresql 
		
		echo
		echo "Installing OnlyOffice."
		echo
		echo "Enter the password for the onlyOffice database (You'll need to remember your password for when the document server installs or if you decide to reinstall the document server)."
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

		echo
		echo "... and we're done!"

		if [ $betaChoice != "y" ];
		then
			echo "Since you're using Nginx, go ahead and uncomment the OnlyOffice location block. If you accidentally delete it, look at the configuration given on GitHub (https://github.com/ReSummit/NextCloud-X-OnlyOffice-Server-Setup-Script/blob/master). Press Enter when you're ready."
			read a
			sudo vim /etc/nginx/sites-available/nextcloud
		fi
	else
		echo "OnlyOffice will not be installed. To install it later, use the OnlyOffice guide with the extra Nginx block on GitHub or the script to install OnlyOffice separately. (Coming Soon!)"
		sleep 2s
	fi

	echo "The installation is complete! Your server is at https://$domain/nextcloud. Have fun with your own file server!"
fi