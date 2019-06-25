# Nextcloud and OnlyOffice Setup Script
This is a useful script that helps facilitate the installation of Nextcloud with OnlyOffice on an Linux computer designated as a file server. It is still a work in progress, and may be improved in the future.

# Warning
This script is in development, meaning that there may be some errors when installing NextCloud and OnlyOffice. Thus, I am not responsible if your system / server becomes unstable. Also, I am still working out some kinks in the script working, so more advanced terminal knowledge is necessary. 

# Updates (Even those before I accidentally deleted the repository)
June 25, 2019: Critical overhaul! Sorry for the delay in updating this. In the Nginx config example file, I indicated that it might be replaced with a configuration solely relying on Nginx instead of the Nginx-Apache2 combination. Now you can just use Nextcloud on Nginx! This is MUCH better than the Nginx-Apache2 combination as you can actually update Nextcloud through the Nginx method. (I tried to update through the Nginx-Apache2 combination, but it gave me errors in loading the updater?) Thus, the Nginx install will be prefered in the bash script. If you are feeling adventurous though, you can try the Nginx-Apache2 combination, but don't expect to be able to update Nextcloud until more development is made in that sector. Note that I will not stop developing the Nginx-Apache2 combination as more options are great in deciding what will host the Nextcloud server. In summary, here is what will be added:
* Sources: Sources for the use of Nginx only installation will be included.
* Installation script: An option between Nginx or the Nginx-Apache2 combination will be added, but will default to Nginx
* New Nginx Example Configuration Files: As the title says. These have been tested and are working by me so far.
* Branch to Nginx-Apache2 combination development: Basically the Testing Branch. More development into a working configuration will be done here and merged over to the stable branch. Additional fixes to the script will also be done too.
* Automatic(?) detection of latest NextCloud Version. Let me know if it doesn't work, since it is a work around kind of.
* Personalized guide messages

June 15, 2019: Unsatisfied with the citation of sources, I put which sources were used in the creation of each file. I also added lines regarding "Strict-Transport-Security" to help with the file server's security.

June 12, 2019: Recreated repository. Ran through the script and configuration files to test usability of script and fixed some kinks in the provided Github template configurations. Removed my own password and domain from the previous commit (because its a password I use).

June 11, 2019: Updated general guideline in how the script works and what packages it installs. Posting sources and instructions before actually posting my script on Github (because attributions should be given before showing the code). Also deleted repository :/

June 9, 2019: Creation of the repository. Script was created, but not uploaded yet. Guide to using the script will follow later.

# Sources Used in Creating Script

## Nginx Front and Backend Sources Used:

* Guide on how to install PHP 7.3 and integrating it in Nginx:

   (https://draculaservers.com/tutorials/install-linux-nginx-mariadb-php-lemp-stack-on-an-ubuntu-18-04-vps/)

* Guide on how to use Nginx only with Nextcloud:

   (https://draculaservers.com/tutorials/install-nextcloud-nginx-ubuntu/)

* NextCloud Given Nginx Configuration (for version 16):

   (https://docs.nextcloud.com/server/16/admin_manual/installation/nginx.html)

## Nginx Frontend, Apache2 Backend Sources Used:

* Guide on Installing Nextcloud using Apache as backend and Nginx as frontend:

   (https://felixbreuer.me/tutorial/Setup-NextCloud-FrontEnd-Nginx-SSL-Backend-Apache2.html)
   
* Reverse Proxy Nginx Configuration for NextCloud:
   
   (https://docs.nextcloud.com/server/15/admin_manual/configuration_server/reverse_proxy_configuration.html)

* Method to install OnlyOffice Document Server:
   
   (https://helpcenter.onlyoffice.com/server/linux/document/linux-installation.aspx)

* Reverse Proxy Used for OnlyOffice integration (Nginx Common Scenario Used):
   
   (https://helpcenter.onlyoffice.com/server/document/document-server-proxy.aspx)

## OnlyOffice Install Sources Used:

* OnlyOffice Ports Used:
   
   (https://helpcenter.onlyoffice.com/server/docker/document/open-ports.aspx)

* How to install MySQL:
   
   (https://linuxize.com/post/how-to-install-mysql-on-ubuntu-18-04/)

# Summary
As a user who uses cloud services everyday (Google Drive, OneDrive, etc.), I found the data quota limited outside of the documents that I create with the services. I turned to Nextcloud to find a way to host my own server. However, there are a multitude of guides and installation methods that just didn't work out for me. Nextcloud Docker can be used, but if I wanted to incorporate another server alongside it in a website, say a media server, I can't easily access the Apache2 configuration files to add a site. I found the same for the Snap distribution as well. While both are viable solutions for file hosting only, I wanted to provide an easy way for users to create their own file server, but without being constrained to the containers that make it difficult to access the files for user customization.

# Before Getting Started
In using the script, it assumes that you already have a domain. Don't have one? You can just use a dynamic DNS (DDNS) as your domain instead! I've used No-IP and it works fine. The only issue that I find is that your server must always be running to connect your DDNS to your server. You can find other DDNS domains or others that are either free or unpaid. Just make sure the domain redirects to your server.

# Packages Automatically Installed
The following are installed automatically between both types of installations:
* apt-transport-https
* ca-certificates
* curl (To add the certbot repository)
* software-properties-common
* certbot (If SSL certification is desired)
* make
* gcc
* vim-gtk3 (You will need this to edit the configurations for reverse proxying sites)
* mysql-server (Manages the file database for your cloud files)

These additional packages are included if the Nginx install is used:
* nginx (Frontend for Nextcloud and other sites)
* python-certbot-nginx
* PHP 7.3 Packages (php7.3 php7.3-fpm php7.3-mysql php-common php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-readline php7.3-mbstring php7.3-xml php7.3-gd php7.3-curl php-imagick php7.3-zip php7.3-bz2 php7.3-intl)

These packages are added instead if the Nginx-Apache2 combination is chosen:

* apache2 (Backend for Nextcloud)
* nginx (Frontend for Nextcloud and other sites)
* python-certbot-nginx
* docker-ce (*Will be removed due to installing document server directly*)
* PHP 7.2 Packages (php7.2, php7.2-gd, php7.2-json, php7.2-mysql, php7.2-curl, php7.2-mbstring, php7.2-intl, php7.2-imagick, php7.2-xml, php7.2-zip, and libapache2-mod-php7.2)

More development into deciding which packages to install for installing NextCloud only or with OnlyOffice will be added later.

**NOTE:** There is a difference between using PHP 7.3 and 7.2 between the two. In the future, I hope to make PHP 7.3 the standard, unless other circumstances arise.

# Bugs to Note
1. Some instructions may be confusing, or may not reflect what actions to do at a certain step. Send all those issues in clarifying what steps should be taken please!
2. Currently, the script asks the user for the latest version of NextCloud they wish to download. No fix is given for an empty input.
3. Speaking of empty input, there are NO checks for that. More fixes in empty input coming soon.
4. Rechecking user's input would be nice, as you only get one shot in inputting the desired domain.
5. There is a lot of bad code styling going on, but I can't seem to find out how to make new lines for the instructions yet...
6. (Critical) In the Nginx-Apache2 installation method, after installation, **there is no way to upgrade Nextcloud to another version.** 

# How to Use Script
Simply download all the files and "chmod u+x" the script to execute it. Confirm if you want to install the server and then the script will run with guided instructions. Use the provided files in the "Configuration Files" folder for an example in what you should add to your Apache2 and Nginx settings.

# General Steps Script Goes Through
0. Install required packages.
1. Configure MySQL Database with your own password and database user (needed for NextCloud setup).
2. Install NextCloud.
3. (Nginx-Apache2) Configure the Apache2 ports and sites files to allow Nextcloud to run, with Nginx as the frontend.
  
   (Nginx) Configure Nginx to handle Nextcloud both in backend and frontend.
5. Setup SSL for Nginx.
6. Install OnlyOffice as an additional server.

All of the steps above are done automatically, but I will update the install with more user choices in mind (whether the user wants to use SSL, OnlyOffice, etc. It may also be possible to use MariaDB instead if that is the database of choice.)
