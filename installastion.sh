#!/bin/bash

# Update the system
echo "Updating the system..."
apt update
apt upgrade -y

# Install necessary packages
echo "Installing necessary packages..."

# Install Node.js
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt install -y nodejs
rm nodesource_setup.sh

# Install MariaDB
echo "Installing MariaDB..."
apt install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb

# Create the database and user
echo "Creating database and user..."
mysql -u root -p=motion2025 
CREATE DATABASE motion;
CREATE USER usrmotion@localhost IDENTIFIED BY 'motion2025';
GRANT ALL PRIVILEGES ON motion.* TO usrmotion@localhost;
FLUSH PRIVILEGES;
exit

# Install php 8.4
echo "Installing php 8.4..."
wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update
apt-get install -y php8.4 php8.4-cli php8.4-fpm php8.4-intl php8.4-gd php8.4-mysql \
                   php8.4-opcache php8.4-curl php8.4-xml php8.4-mbstring php8.4-zip php8.4-iconv

# Install Apache
echo "Installing Apache..."
apt install -y apache2 libapache2-mod-php8.4
systemctl start apache2
systemctl enable apache2

# Install git 
echo "Installing git..."
apt install -y git

# Install curl
apt install -y curl

# Install Motion Tools
echo "Installing Motion..."
cd /var/www/html
rm index.html
git clone https://github.com/CatoTH/antragsgruen.git
mv antragsgruen/* .
mv antragsgruen/.* .
rm -rf antragsgruen
curl -sS https://getcomposer.org/installer | php
chmod -R 777 /var/www/html
sudo -u usrmotion git config --global --add safe.directory /var/www/html
sudo -u usrmotion ./composer.phar install --prefer-dist
npm install
npm run build
cd config
touch INSTALLING
chmod -R 777 /var/www/html