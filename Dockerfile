FROM php:8.1-apache

# Install extensions
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd \
    && docker-php-ext-install zip \
    && docker-php-ext-install pdo_mysql bcmath mysqli

# Set up self-signed SSL certificate
# development.localhost doesn't matter and could be anything
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=UK/ST=Cardiff/L=Cardiff/O=Security/OU=Development/CN=development.localhost"

# Run SSL-related commands
RUN a2enmod rewrite headers
RUN a2ensite default-ssl
RUN a2enmod ssl

# Set memory limit to 4GB
RUN echo 'memory_limit = 4096M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

# Copy Apache .conf files
COPY ./.docker/conf/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./.docker/conf/apache/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY ./.docker/conf/apache/apache2.conf /etc/apache2/apache2.conf