FROM php:7.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    curl \
    nano \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install mysqli pdo pdo_mysql gd zip \
 && a2enmod rewrite headers expires \
 && mkdir -p /var/lib/php/sessions \
 && chown -R www-data:www-data /var/lib/php/sessions \
 && chmod 1733 /var/lib/php/sessions \
 && rm -rf /var/lib/apt/lists/*

RUN sed -ri 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

COPY apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY php-lab.ini /usr/local/etc/php/conf.d/php-lab.ini

WORKDIR /var/www/html
