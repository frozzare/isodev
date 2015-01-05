# Isodev
Vagrant machine for PHP development. The operating system is Ubuntu 14.04. A custom dashboard is available at [http://iso.dev](http://iso.dev) with all tools and all other domains will go to web directory.

![Isodev Dashboard](http://public.forsmo.me/github/isodev.png)

## Sites directory
The directory name should be the hostname you are using. For example `isotest.dev` for `http://isotest.dev`.

If `web` directory exists in your hostname directory then that directory is the web root directory. This can be turned of by edit [.isodev/nginx/default](https://github.com/frozzare/isodev/blob/master/.isodev/nginx/default)

## Passwords
Password for the virtual machines `root` user is `vagrant`. Password for MySQL `root` user is `root`.

## Tools installed:
* phpMyAdmin
* phpMemcachedAdmin
* Opcache Status
* Beanstalk Console
* Webgrind
* And a page with phpinfo
* wp-cli

## Installed packages
* build-essential  
* imagemagick
* subversion
* git-core
* zip
* unzip
* ngrep
* curl
* make
* colordiff
* postfix
* gettext
* graphviz
* memcached
* dos2unix
* libmcrypt4
* nginx
* php5-fpm
* php5-cli
* php5-common
* php5-dev
* php5-imagick
* php5-mcrypt
* php5-imap
* php5-curl
* php-pear
* php5-gd
* php5-xdebug
* php5-apcu
* php5-json
* php5-sqlite
* php5-mysql
* php5-memcached
* php5-redis
* mariadb-server
* redis-server
* beanstalkd
* g++
* npm
* nodejs

## License
MIT © [Fredrik Forsmo](https://github.com/frozzare)
