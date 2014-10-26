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
  cachefilesd

  # Webserver
  apache

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

  # Queue
  beanstalkd

  # Install node.js
  g++
  npm
  nodejs

  # Locale
  language-pack-sv
)

# Add MariaDB source
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
echo "deb http://ftp.ddg.lth.se/mariadb/repo/10.0/ubuntu trusty main" >> /etc/apt/sources.list.d/mariadb.list
echo "deb-src http://ftp.ddg.lth.se/mariadb/repo/10.0/ubuntu trusty main" >> /etc/apt/sources.list.d/mariadb.list
apt-get update -y

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

# Bind address Mariadb
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

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

# Setup cachefilesd
sudo echo "RUN=yes" > /etc/default/cachefilesd

# Set start path
cd /vagrant
echo cd \/vagrant > /home/vagrant/.bashrc
rm -rf /etc/motd

# Enable rewrite
a2enmod rewrite

# /phpinfo/
echo "Creating phpinfo file"
mkdir /usr/share/phpinfo
mkdir /etc/phpinfo
phpinfoalias="Alias /phpinfo /usr/share/phpinfo

<Directory /usr/share/phpmyadmin>
  Options Indexes FollowSymLinks
  DirectoryIndex index.php
</Directory>"

echo "<?php phpinfo(); ?>" >> /usr/share/phpinfo/index.php
echo "${phpinfoalias}" >> /etc/phpinfo/apache2.conf
ln -s /etc/phpinfo/apache2.conf /etc/apache2/conf-enabled/phpinfo.conf
service apache2 restart

# Install phpmyadmin
echo "Installing phpMyAdmin"
mkdir /usr/share/phpmyadmin
mkdir /etc/phpmyadmin
wget -q -O phpmyadmin.tar.gz 'http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.2.2/phpMyAdmin-4.2.2-all-languages.tar.gz/download'
tar -xf phpmyadmin.tar.gz
mv phpMyAdmin-4.2.2-all-languages/* /usr/share/phpmyadmin/
rm -r phpmyadmin.tar.gz phpMyAdmin-4.2.2-all-languages
phpmyadminalias="Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
  Options Indexes FollowSymLinks
  DirectoryIndex index.php
</Directory>"
echo "${phpmyadminalias}" >> /etc/phpmyadmin/apache2.conf
ln -s /etc/phpmyadmin/apache2.conf /etc/apache2/conf-enabled/phpmyadmin.conf
service apache2 restart

# Install beanstalk console
echo "Installing Beanstalk Console"
git clone https://github.com/ptrofimov/beanstalk_console.git /usr/share/phpbeanstalk_console
mkdir /etc/phpbeanstalk_console
beanstalk_consolealias="Alias /beanstalk-console /usr/share/phpbeanstalk_console/public

<Directory /usr/share/phpbeanstalk_console/public>
  Options Indexes FollowSymLinks
  DirectoryIndex index.php
</Directory>"
echo "${beanstalk_consolealias}" >> /etc/phpbeanstalk_console/apache2.conf
ln -s /etc/phpbeanstalk_console/apache2.conf /etc/apache2/conf-enabled/beanstalk_console.conf
chmod u+w /usr/share/phpbeanstalk_console/storage.json
chown www-data:www-data /usr/share/phpbeanstalk_console/storage.json
service apache2 restart

# Install webgrid
echo "Installing Webgrind"
mkdir /etc/phpwebgrind
git clone https://github.com/jokkedk/webgrind.git /usr/share/phpwebgrind/
phpwebgrindalias="Alias /webgrind /usr/share/phpwebgrind

<Directory /usr/share/phpwebgrind>
  Options Indexes FollowSymLinks
  DirectoryIndex index.php
</Directory>"
echo "${phpwebgrindalias}" >> /etc/phpwebgrind/apache2.conf
ln -s /etc/phpwebgrind/apache2.conf /etc/apache2/conf-enabled/phpwebgrind.conf
service apache2 restart

# Install opcache-status
echo "Installing Opcache Status"
mkdir /etc/phpopcache-status
git clone https://github.com/rlerdorf/opcache-status.git /usr/share/phpopcache-status/
phpwebgrindalias="Alias /opcache-status /usr/share/phpopcache-status

<Directory /usr/share/phpopcache-status>
  Options Indexes FollowSymLinks
  DirectoryIndex index.php
</Directory>"
echo "${phpwebgrindalias}" >> /etc/phpopcache-status/apache2.conf
ln -s /etc/phpopcache-status/apache2.conf /etc/apache2/conf-enabled/phpopcache-status.conf
service apache2 restart

# Install phpmemcachedadmin
echo "Installing phpMemcachedAdmin"
mkdir /usr/share/phpmemcachedadmin
mkdir /etc/phpmemcachedadmin
wget -q -O phpmemcachedadmin.tar.gz http://phpmemcacheadmin.googlecode.com/files/phpMemcachedAdmin-1.2.2-r262.tar.gz
tar -xf phpmemcachedadmin.tar.gz -C /usr/share/phpmemcachedadmin
rm -r phpmemcachedadmin.tar.gz
phpmemcachedadminalias="Alias /phpmemcachedadmin /usr/share/phpmemcachedadmin

<Directory /usr/share/phpmemcachedadmin>
  Options Indexes FollowSymLinks
  DirectoryIndex index.php
</Directory>"
echo "${phpmemcachedadminalias}" >> /etc/phpmemcachedadmin/apache2.conf
ln -s /etc/phpmemcachedadmin/apache2.conf /etc/apache2/conf-enabled/phpmemcachedadmin.conf
service apache2 restart

# Install Isodev Dashboard
echo "Installing Isodev Dashboard"
mkdir /usr/share/isodevdashboard
cp /vagrant/.isodev/default_site/index.html /usr/share/isodevdashboard
isodevdashboardsite="<VirtualHost *:80>
     ServerName iso.dev
     DocumentRoot /usr/share/isodevdashboard
     <Directory /usr/share/isodevdashboard>
       Options Indexes FollowSymLinks Includes ExecCGI
       AllowOverride All
       Order deny,allow
       Allow from all
    </Directory>
</VirtualHost>"
echo "${isodevdashboardsite}" >> /etc/apache2/sites-enabled/isodevdashboard.conf
rm -r /etc/apache2/sites-enabled/000-default.conf
service apache2 restart

# Installing other sites
rm -r /var/www
ln -s $webroot /var/www
chgrp www-data /var/www
chmod 2750 /var/www
echo "Installing other sites"
allothersites="<VirtualHost *:80>
     ServerName rest.isodev
     DocumentRoot /var/www
     <Directory /var/www>
       Options Indexes FollowSymLinks Includes ExecCGI
       AllowOverride All
       Order deny,allow
       Allow from all
    </Directory>
</VirtualHost>"
echo "${allothersites}" >> /etc/apache2/sites-enabled/allothersites.conf
service apache2 restart

# Welcome message
echo "  Welcome to Isodev!" >> /etc/motd
echo >> /etc/motd
echo "  Visit http://iso.dev for the dashboard" >> /etc/motd
echo >> /etc/motd
