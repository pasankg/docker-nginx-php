# Stage 1: Build PHP/Nginx application
FROM --platform=linux/amd64 php:8.2-fpm AS stage1

# Depending on the image used, use pecl, apt-get etc.
#RUN pecl install xdebug \
#    && docker-php-ext-enable xdebug

RUN apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev

# ------ EXTRA STEPS, For example purpose --------- #

# Set environment variables for dev.
# Set PHP_OPCACHE_VALIDATE_TIMESTAMPS to 1 for development environment.
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" \
    COMPOSER_ALLOW_SUPERUSER="1"

RUN	docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install -j$(nproc) gd

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions

RUN docker-php-ext-install opcache

# Copy over opcache ini content
COPY docker/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Install necessary dependencies
RUN apt-get install -y sudo

RUN sudo apt-get install -y default-mysql-client default-libmysqlclient-dev

RUN apt-get install -y nginx nginx-extras libgd3 gdebi git software-properties-common

RUN apt-get install -y imagemagick imagemagick-doc vim curl unzip postfix

RUN apt-get install -y libonig-dev libxml2-dev libzip-dev

# Install additional PHP extensions
RUN install-php-extensions gd pdo_mysql mbstring exif pcntl bcmath soap zip xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# For Drupal projects only.
# Install Drush globally using curl
RUN curl -fsSL -o drush.phar https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar \
    && chmod +x drush.phar \
    && mv drush.phar /usr/local/bin/drush

FROM stage1 as stage2

# Update Nginx config with your custom configs.
COPY ./docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./docker/nginx/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

# Set the working directory
WORKDIR /var/www/html

# For Drupal projects only.
RUN mkdir /var/www/html/patches

# Copy over only these files. Check the Dockerignore file.
COPY ./composer.json ./composer.lock /var/www/html/
COPY ./patches /var/www/html/patches

# ------ END OF EXTRA STEPS, For example purpose --------- #

# Install dependencies
RUN composer install

FROM stage2 as stage3
# Copy the application code
COPY . /var/www/html

# Drupal File system.
RUN mkdir -p /var/www/html/web/sites/default/files

# Mount a volum here; ex. Azure fileshare volume
VOLUME /var/www/html/web/sites/default/files

RUN chmod -R g+rwx /var/www/html/web/sites/default/files

# For Drupal projects.
RUN chown -R root:root /var/www/html

# For Drupal projects. Drupal will clean this later automatically.
RUN chmod -R 777 /var/www/html

EXPOSE 80 443

# Add any scripts that you want to execute after the build is complete.
COPY ./entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]