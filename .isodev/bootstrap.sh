#!/bin/bash
#
# Isodev bootstrap
#

webroot="/vagrant/sites"

# Add HHVM source
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | apt-key add -
echo deb http://dl.hhvm.com/ubuntu trusty main | tee /etc/apt/sources.list.d/hhvm.list

# Upgrade Base Packages
echo "Updating packages..."
apt-get update -y
apt-get upgrade -y

# Packages list
packages_to_install=(
  build-essential

  # Goodies
  imagemagick
  subversion
  git-core
  zip
  unzip
  ngrep
  curl
  make
  colordiff
  postfix
  gettext
  graphviz
  memcached
  dos2unix
  libmcrypt4

  # Webserver
  nginx

  # PHP packages
  php5-fpm
  php5-cli
  php5-common
  php5-dev
  php5-imagick
  php5-mcrypt
  php5-imap
  php5-curl
  php-pear
  php5-gd
  php5-xdebug
  php5-apcu
  php5-json
  php5-sqlite
  php5-mysql
  php5-memcached

  # Databases
  mysql-server
  redis-server

  # Queue
  beanstalkd

  # Install node.js
  g++
  npm
  nodejs

  # HHVM
  hhvm
)

# Setup mysql. Sets database root password to root.
echo "MySQL setup"
echo mysql-server mysql-server/root_password password root | debconf-set-selections
echo mysql-server mysql-server/root_password_again password root | debconf-set-selections

# Setup postfix.
echo "Postfix setup"
echo postfix postfix/main_mailer_type select Internet Site | debconf-set-selections
echo postfix postfix/mailname string isodev | debconf-set-selections

# Install all packages in our packages to install list.
echo "Installing apt-get packages..."
for pkg in "${packages_to_install[@]}"; do
  apt-get install -y $pkg
done

# Clean apt-get cache
apt-get clean

# Install xdebug
pecl install xdebug
echo "extension=xdebug.so" >> /etc/php5/fpm/php.ini
echo "xdebug.profiler_enable = 0" >> /etc/php5/fpm/php.ini

# Enable error reporting
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini

# Memory limit
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini

# Date timezone.
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/cli/php.ini

# Install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install PHPUnit
pear config-set auto_discover 1
pear install pear.phpunit.de/phpunit

# Configure beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
/etc/init.d/beanstalkd start

# Link nodejs to node
echo "Linking /usr/bin/nodejs to /usr/bin/node"
ln -s /usr/bin/nodejs /usr/bin/node

# Install grunt
echo "Installing grunt"
npm install -g grunt-cli

# Set start path
cd /vagrant
echo cd \/vagrant > /home/vagrant/.bashrc
rm -rf /etc/motd

# Install Isorock Dashboard
echo "Installing Isorock Dashboard"
mkdir -p /usr/share/isodev/
cp /vagrant/.isodev/default_site/index.html /usr/share/isodev/

# /phpinfo/
echo "Installing phpinfo file"
mkdir -p /usr/share/isodev/phpinfo
echo "<?php phpinfo(); ?>" >> /usr/share/isodev/phpinfo/index.php

# Install phpmyadmin
echo "Installing phpMyAdmin"
mkdir -p /usr/share/isodev/phpmyadmin
wget -q -O phpmyadmin.tar.gz 'http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.2.2/phpMyAdmin-4.2.2-all-languages.tar.gz/download'
tar -xf phpmyadmin.tar.gz
mv phpMyAdmin-4.2.2-all-languages/* /usr/share/isodev/phpmyadmin
rm -r phpMyAdmin-4.2.2-all-languages phpmyadmin.tar.gz

# Install beanstalk console
echo "Installing Beanstalk Console"
mkdir -p /usr/share/isodev/beanstalk-console
git clone https://github.com/ptrofimov/beanstalk_console.git /usr/share/isodev/beanstalk-console
chmod u+w /usr/share/isodev/beanstalk-console/storage.json
chown www-data:www-data /usr/share/isodev/beanstalk-console/storage.json

# Install webgrid
echo "Installing Webgrind"
mkdir -p /usr/share/isodev/webgrind
git clone https://github.com/jokkedk/webgrind.git /usr/share/isodev/webgrind

# Install opcache-status
echo "Installing Opcache Status"
mkdir -p /usr/share/isodev/opcache-status
git clone https://github.com/rlerdorf/opcache-status.git /usr/share/isodev/opcache-status

# Install phpmemcachedadmin
echo "Installing phpMemcachedAdmin"
mkdir -p /usr/share/isodev/phpmemcachedadmin
wget -q -O phpmemcachedadmin.tar.gz http://phpmemcacheadmin.googlecode.com/files/phpMemcachedAdmin-1.2.2-r262.tar.gz
tar -xf phpmemcachedadmin.tar.gz -C /usr/share/isodev/phpmemcachedadmin
rm -r phpmemcachedadmin.tar.gz

# Installing default sites
rm -r /var/www
ln -s $webroot /var/www
chgrp www-data /var/www
chmod 2750 /var/www

# Copying nginx files to nginx.
cp -R /vagrant/.isodev/nginx/* /etc/nginx/sites-enabled

# HHVM
update-rc.d hhvm defaults
/usr/share/hhvm/install_fastcgi.sh
service hhvm restart
service php5-fpm restart
service nginx restart

# Welcome message
echo "  Welcome to Isodev!" >> /etc/motd
echo >> /etc/motd
echo "  Visit http://iso.dev for the dashboard" >> /etc/motd
echo >> /etc/motd