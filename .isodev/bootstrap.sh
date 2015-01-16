#!/bin/bash
#
# Isodev bootstrap
#

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
  htop

  # Webserver
  nginx

  # Databases
  mariadb-server
  redis-server

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
  php5-mysqlnd
  php5-memcached
  php5-redis

  # Queue
  beanstalkd

  # Install node.js
  g++
  npm
  nodejs
  
  # HHVM
  hhvm

  # Locale
  language-pack-sv
)

# Adding HHVM source
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | apt-key add -
echo deb http://dl.hhvm.com/ubuntu trusty main | tee /etc/apt/sources.list.d/hhvm.list

# Add MariaDB source
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
echo "deb http://ftp.ddg.lth.se/mariadb/repo/10.0/ubuntu trusty main" >> /etc/apt/sources.list.d/mariadb.list
echo "deb-src http://ftp.ddg.lth.se/mariadb/repo/10.0/ubuntu trusty main" >> /etc/apt/sources.list.d/mariadb.list
apt-get update -y

# Setup MariaDB. Sets database root password to root.
echo "MariaDB setup"
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

# MariaDB
update-rc.d mysql defaults
rm -r /etc/mysql/my.cnf
cp /vagrant/.isodev/confs/my.cnf /etc/mysql/my.cnf
service mysql restart

# Install xdebug
pecl install xdebug
echo "zend_extenstion=xdebug.so" >> /etc/php5/fpm/php.ini
echo "xdebug.profiler_enable = 0" >> /etc/php5/fpm/php.ini

# Disable cache
echo "apc.enabled = 0" >> /etc/php5/fpm/php.ini
echo "opcache.enabled = 0" >> /etc/php5/fpm/php.ini

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
wget https://phar.phpunit.de/phpunit.phar
mv phpunit.phar /usr/bin/phpunit

# Enable mcrypt
php5enmod mcrypt

# Configure beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
/etc/init.d/beanstalkd start

# Link nodejs to node
echo "Linking /usr/bin/nodejs to /usr/bin/node"
ln -s /usr/bin/nodejs /usr/bin/node

# Setup cachefilesd
echo "RUN=yes" > /etc/default/cachefilesd

# Set start path
cd /vagrant
echo cd \/vagrant > /home/vagrant/.bashrc
rm -rf /etc/motd

# Install Isorock Dashboard
echo "Installing Isodev Dashboard"
mkdir -p /usr/share/isodev/
cp /vagrant/.isodev/default_site/index.html /usr/share/isodev/

# /phpinfo/
echo "Installing phpinfo file"
mkdir -p /usr/share/isodev/phpinfo
echo "<?php phpinfo(); ?>" >> /usr/share/isodev/phpinfo/index.php

# Install phpmyadmin
echo "Installing phpMyAdmin"
mkdir -p /usr/share/isodev/phpmyadmin
wget -q -O phpmyadmin.tar.gz 'http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.3.6/phpMyAdmin-4.3.6-all-languages.tar.gz/download'
tar -xf phpmyadmin.tar.gz
mv phpMyAdmin-4.3.6-all-languages/* /usr/share/isodev/phpmyadmin
rm -r phpMyAdmin-4.3.6-all-languages phpmyadmin.tar.gz

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

# Install Pimp My Log
echo "Installing Pimp My Log"
mkdir -p /usr/share/isodev/pimpmylog
git clone https://github.com/potsky/PimpMyLog.git /usr/share/isodev/pimpmylog
cp /vagrant/.isodev/confs/pimpmylog.config.user.php /usr/share/isodev/pimpmylog/config.user.php

# Installing wp-cli
echo "Installing wp-cli"
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

chgrp www-data /vagrant
chmod 2750 /vagrant

# Copying nginx files to nginx.
rm -r /etc/nginx/sites-enabled/default
cp -R /vagrant/.isodev/nginx/* /etc/nginx/sites-enabled

# HHVM
update-rc.d hhvm defaults
/usr/share/hhvm/install_fastcgi.sh
sed -i "s/hhvm.server.port = .*/hhvm.server.port = 8000/" /etc/hhvm/php.ini
echo "hhvm.log.header = true" >> /etc/hhvm/php.ini
echo "hhvm.log.natives_stack_trace = true" >> /etc/hhvm/php.ini
sed -i "s/fastcgi_pass .*/fastcgi_pass 127.0.0.1:9000/" /etc/hhvm/php.ini

# Restart the services
service hhvm restart
php5-fpm -t && service php5-fpm restart
nginx -t && service nginx restart

# Welcome message
echo "  Welcome to Isodev!" >> /etc/motd
echo >> /etc/motd
echo "  Visit http://iso.dev for the dashboard" >> /etc/motd
echo >> /etc/motd
