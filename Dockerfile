# Use PHP 8.2 with Apache as the base image
FROM php:8.2-apache

# Expose port 80 to access Apache
EXPOSE 80

RUN apt-get update -y && \
    apt-get install -y  

# Install system libraries required by gd, imap, zip, and mysqli extensions
RUN apt-get update -y && \
apt-get install -y \
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
zip \
&& rm -rf /var/lib/apt/lists/*

# Installing php Dependencies 
RUN docker-php-ext-install mysqli gd zip
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install gd imap zip mysqli

#
# Assuming Perfex-CRM root is located in 'pwd'/perfex_crm
# Copy your application code to the container (assuming your code is in the current directory)
RUN a2enmod rewrite
COPY ./ /var/www/html/

# Set the working directory to the Apache root
WORKDIR /var/www/html

# Configuring Ownerships and permissions
# Set permissions for the Apache root directory
RUN chown -R www-data:www-data /var/www/html/
RUN chmod 755 /var/www/html/uploads/
RUN chmod 755 /var/www/html/application/config/
RUN chmod 755 /var/www/html/application/config/config.php
RUN chmod 755 /var/www/html/application/config/app-config-sample.php
RUN chmod 755 /var/www/html/temp/

# Use the default Apache configuration
CMD ["apache2-foreground"]