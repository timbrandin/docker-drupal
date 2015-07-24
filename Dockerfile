FROM ubuntu:trusty
MAINTAINER Tim Brandin <tim.brandin@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install packages.
RUN apt-get update
RUN apt-get install -y \
  nano \
  git \
  apache2 \
  php5 \
  php-apc \
  php5-fpm \
  php5-gd \
  php5-curl \
  php5-mysql \
  php5-xdebug \
  php5-intl \
  php5-mcrypt \
	php5-dev \
  php-pear \
  build-essential \
  libapache2-mod-php5 \
  libapache2-mod-auth-mysql \
  mysql-server \
  openssh-server \
  curl \
  supervisor
RUN apt-get clean

# Install PHP 5.6.
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ondrej/php5-5.6
RUN apt-get update
RUN apt-get upgrade -y --force-yes
RUN apt-get install -y --force-yes php5

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drush 7.
RUN composer global require drush/drush:7.*
RUN composer global update
# Unfortunately, adding the composer vendor dir to the PATH doesn't seem to work. So:
RUN ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Setup Apache.
RUN a2enmod rewrite authz_groupfile dav_fs dav reqtimeout

# Adding custom apache VirtualHost configuration.
COPY default.conf /etc/apache2/sites-available/000-default.conf

# Adding custom mysql settings.
COPY my.cnf /etc/mysql/my.cnf

# Setup SSH.
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd
RUN mkdir -p /root/.ssh/ && touch /root/.ssh/authorized_keys
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Setup Supervisor.
RUN echo -e '[program:apache2]\ncommand=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"\nautorestart=true\n\n' >> /etc/supervisor/supervisord.conf
RUN echo -e '[program:mysql]\ncommand=/usr/bin/pidproxy /var/run/mysqld/mysqld.pid /usr/sbin/mysqld\nautorestart=true\n\n' >> /etc/supervisor/supervisord.conf
RUN echo -e '[program:sshd]\ncommand=/usr/sbin/sshd -D\n\n' >> /etc/supervisor/supervisord.conf

# Adding custom php settings.
COPY php.ini /etc/php5/mods-available/custom.ini
RUN ln -s /etc/php5/mods-available/custom.ini /etc/php5/cli/conf.d/zzzz_custom.ini && \
  ln -s /etc/php5/mods-available/custom.ini /etc/php5/apache2/conf.d/zzzz_custom.ini

# Adding pretty terminal.
COPY .bash_aliases /root/.bash_aliases
COPY .bash_git /root/.bash_git
RUN echo "if [ -f ~/.bash_aliases ] ; then source ~/.bash_aliases; fi" >> /root/.bashrc && \
  echo "if [ -f ~/.bash_git ] ; then source ~/.bash_git; fi" >> /root/.bashrc

# Adding apc upload progress.
RUN echo "apc.rfc1867=1" >> /etc/php5/mods-available/apcu.ini

# Set user 1000 and group staff to www-data, enables write permission.
# https://github.com/boot2docker/boot2docker/issues/581#issuecomment-114804894
RUN usermod -u 1000 www-data
RUN usermod -G staff www-data

WORKDIR /var/www

RUN rm -rf /var/www && \
  mkdir -p /var/www && \
  chown -R www-data:www-data /var/www

VOLUME  ["/var/www"]

ENV SHELL /bin/bash

EXPOSE 80 3306 22
CMD exec supervisord -n
