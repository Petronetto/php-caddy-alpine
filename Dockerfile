FROM alpine:edge

MAINTAINER Juliano Petronetto <juliano@petronetto.com.br>

# Install packages
RUN apk --update add \
        curl \
        libcap \
        openssh-client \
        supervisor \
        gd \
        freetype \
        libpng \
        libjpeg-turbo \
        freetype-dev \
        libpng-dev \
        nodejs \
        git \
        php7 \
        php7-dom \
        php7-fpm \
        php7-mbstring \
        php7-mcrypt \
        php7-opcache \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-pdo_sqlite \
        php7-xml \
        php7-phar \
        php7-openssl \
        php7-json \
        php7-ctype \
        php7-session \
        php7-gd \
        php7-zlib \
    && rm -rf /var/cache/apk/*

# Creating symbolic link to php
RUN ln -s /usr/bin/php7 /usr/bin/php

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install Caddy
RUN curl --silent --show-error --fail --location \
      --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
      "https://caddyserver.com/download/build?os=linux&arch=amd64&features=${plugins}" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
    && chmod 0755 /usr/bin/caddy \
    && setcap cap_net_bind_service=+ep /usr/bin/caddy

# Configure Caddy
COPY config/caddy/Caddyfile /etc/Caddyfile

# Configure PHP-FPM
COPY config/php/php.ini /etc/php7/php.ini
COPY config/php/www.conf /etc/php7/php-fpm.d/www.conf

# Configure supervisord
COPY config/supervisord.conf /etc/supervisord.conf

# Add application
RUN mkdir -p /app
WORKDIR /app

# Set UID for www user to 1000
RUN addgroup -g 1000 -S www \
    && adduser -u 1000 -D -S -G www -h /app -g www www

# Start Supervisord
ADD config/start.sh /start.sh
RUN chmod 755 /start.sh

# Start Supervisord
CMD ["/start.sh"]