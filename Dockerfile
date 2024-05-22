# Use PHP 8.2 with Apache as the base image
FROM php:8.2-apache

# Expose port 80 to access Apache
EXPOSE 80

# Update apt-get
RUN apt-get update -y && \
    apt-get install -y  

# Install system libraries required by gd, imap, zip, and mysqli extensions
RUN apt-get update -y && \
apt-get install -y \
cron \
libpng-dev \
libjpeg-dev \
libfreetype6-dev \
libzip-dev \
libc-client-dev \
libkrb5-dev \
mc \
apt-utils \
tree \
htop \
libpng-dev \
libc-client-dev \
libkrb5-dev \
libzip-dev \
wget \
zip \
&& rm -rf /var/lib/apt/lists/*

# Installing php Dependencies 
RUN docker-php-ext-install mysqli gd zip
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install gd imap zip mysqli


# Assuming Perfex-CRM root is located in 'pwd'/perfex_crm
# Copy your application code to the container (assuming your code is in the current directory)
RUN a2enmod rewrite
COPY ./ /var/www/html/

# Set the working directory to the Apache root
WORKDIR /var/www/html

# Cron configuration to reminders
RUN touch /etc/cron.d/perfex-cron
RUN echo '* * * * * wget -q -O- http://proyectos.htc.gov.ar/cron/index >> /var/log/cron.log 2>&1' >> /etc/cron.d/perfex-cron
RUN chmod 0644 /etc/cron.d/perfex-cron
RUN crontab /etc/cron.d/perfex-cron
RUN touch /var/log/cron.log


# Configuring Ownerships and permissions
# Set permissions for the Apache root directory
RUN chown -R www-data:www-data /var/www/html/
RUN chmod 755 /var/www/html/uploads/
RUN chmod 755 /var/www/html/application/config/
RUN chmod 755 /var/www/html/application/config/config.php
RUN chmod 755 /var/www/html/application/config/app-config-sample.php
RUN chmod 755 /var/www/html/temp/

# Create a shell script to start the cron service and Apache
RUN echo -e "#!/bin/sh\nservice cron start\napache2-foreground" > /start.sh
RUN chmod +x /start.sh

# Start the shell script when the container runs
CMD ["/start.sh"]
