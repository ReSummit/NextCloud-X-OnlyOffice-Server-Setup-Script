# Nextcloud and OnlyOffice Setup Script
This is a useful script that helps facilitate the installation of Nextcloud with OnlyOffice on an Linux computer designated as a file server. It is still a work in progress, and may be improved in the future.

# Warning
This script is in development, meaning that there may be some errors when installing NextCloud and OnlyOffice. Thus, I am not responsible if your system / server becomes unstable. Also, I am still working out some kinks in the script working, so more advanced terminal knowledge is necessary. 

# Updates (Even those before I accidentally deleted the repository)
June 12, 2019: Recreated repository. Ran through the script and configuration files to test usability of script and fixed some kinks in the provided Github template configurations. Removed my own password and domain from the previous commit (because its a password I use).

June 11, 2019: Updated general guideline in how the script works and what packages it installs. Posting sources and instructions before actually posting my script on Github (because attributions should be given before showing the code). Also deleted repository :/

June 9, 2019: Creation of the repository. Script was created, but not uploaded yet. Guide to using the script will follow later.

# Sources Used in Creating Script
1. Guide on Installing Nextcloud using Apache as backend and Nginx as frontend:
https://felixbreuer.me/tutorial/Setup-NextCloud-FrontEnd-Nginx-SSL-Backend-Apache2.html
2. Reverse Proxy Nginx Configuration for NextCloud:
https://docs.nextcloud.com/server/15/admin_manual/configuration_server/reverse_proxy_configuration.html
3. Method to install OnlyOffice Document Server:
https://helpcenter.onlyoffice.com/server/linux/document/linux-installation.aspx
4. Reverse Proxy Used for OnlyOffice integration (Nginx Common Scenario Used):
https://helpcenter.onlyoffice.com/server/document/document-server-proxy.aspx
5. OnlyOffice Ports Used:
https://helpcenter.onlyoffice.com/server/docker/document/open-ports.aspx
6. How to install MySQL:
https://linuxize.com/post/how-to-install-mysql-on-ubuntu-18-04/

# Summary
As a user who uses cloud services everyday (Google Drive, OneDrive, etc.), I found the data quota limited outside of the documents that I create with the services. I turned to Nextcloud to find a way to host my own server. However, there are a multitude of guides and installation methods that just didn't work out for me. Nextcloud Docker can be used, but if I wanted to incorporate another server alongside it in a website, say a media server, I can't easily access the Apache2 configuration files to add a site. I found the same for the Snap distribution as well. While both are viable solutions for file hosting only, I wanted to provide an easy way for users to create their own file server, but without being constrained to the containers that make it difficult to access the files for user customization.

# Before Getting Started
In using the script, it assumes that you already have a domain. Don't have one? You can just use a dynamic DNS (DDNS) as your domain instead! I've used No-IP and it works fine. The only issue that I find is that your server must always be running to connect your DDNS to your server. You can find other DDNS domains or others that are either free or unpaid. Just make sure the domain redirects to your server.
Also, make sure you 

# Packages Automatically Installed
The following packages are installed once confirmation for the server installed is certified:
* apt-transport-https
* ca-certificates
* curl (To add the certbot repository)
* software-properties-common
* certbot (If SSL certification is desired)
* apache2 (Backend for Nextcloud)
* python-certbot-apache (*Will be removed later due to Nginx handling SSL*)
* nginx (Frontend for Nextcloud and other sites)
* python-certbot-nginx
* make
* gcc 
* docker-ce (Added by repository to create OnlyOffice document server)
* vim-gtk3 (You will need this to edit the configurations for reverse proxying sites)
* mysql-server (Manages the file database for your cloud files)
* php7.2 Packages (php7.2, php7.2-gd, php7.2-json, php7.2-mysql, php7.2-curl, php7.2-mbstring, php7.2-intl, php7.2-imagick, php7.2-xml, php7.2-zip, and libapache2-mod-php7.2)

More development into deciding which packages to install for installing NextCloud only or with OnlyOffice will be added later.

# Bugs to Note
1. Some instructions may be confusing, or may not reflect what actions to do at a certain step. Send all those issues in clarifying what steps should be taken please!
2. Currently, the script asks the user for the latest version of NextCloud they wish to download. No fix is given for an empty input.
3. Speaking of empty input, there are NO checks for that. More fixes in empty input coming soon.
4. Rechecking user's input would be nice, as you only get one shot in inputting the desired domain.
5. There is a lot of bad code styling going on, but I can't seem to find out how to make new lines for the instructions yet...

# How to Use Script
Simply download all the files and "chmod u+x" the script to execute it. Confirm if you want to install the server and then the script will run with guided instructions. Use the provided files in the "Configuration Files" folder for an example in what you should add to your Apache2 and Nginx settings.

# General Steps Script Goes Through
0. Install required packages.
1. Configure MySQL Database with your own password and database user (needed for NextCloud setup).
2. Install NextCloud.
3. Configure the Apache2 ports and sites files to allow Nextcloud to run.
4. Configure Nginx to run as the front end for websites.
5. Setup SSL for Nginx.
6. Install OnlyOffice as an additional server.

All of the steps above are done automatically, but I will update the install with more user choices in mind (whether the user wants to use SSL, OnlyOffice, etc. It may also be possible to use MariaDB instead if that is the database of choice.)
