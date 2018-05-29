# we use 7.0 for performance reasons, in TravisCI we launch tests for PHP 5.4, 5.5, 5.6, 7.0, 7.1 & 7.2 compatibility
FROM php:7.0-cli

MAINTAINER PrivateBin <support@privatebin.org>

RUN \
# Install GD & xdebug (for code coverage)
    apt-get update \
    && apt-get install -y \
        libjpeg62-turbo-dev \
        libpng-dev \
        libfreetype6-dev \
        git \
# Install composer first, to avoid overhead from xdebug
    && curl -s https://getcomposer.org/installer > /tmp/composer-setup.php \
    && [ "$(curl -s https://composer.github.io/installer.sig)" = "$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');")" ] \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && cd /opt \
    && composer require phpunit/phpunit:^5.0 \
# Configure & build GD & xdebug
    && docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
# cleanup to reduce already large image size
    && apt-get purge -y \
        libjpeg62-turbo-dev \
        libpng-dev \
        libfreetype6-dev \
        git \
    && rm -rf /var/lib/apt/lists/* /tmp/composer-setup.php

# mark dirs as volumes that need to be writable, allows running the container --read-only
VOLUME /srv /tmp

COPY unit-test.sh /usr/local/bin/

WORKDIR /usr/local/bin

ENTRYPOINT ["unit-test.sh"]
