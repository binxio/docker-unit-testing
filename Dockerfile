# we use 7.0 for performance reasons, in TravisCI we launch tests for PHP 5.4, 5.5, 5.6, 7.0, 7.1 & 7.2 compatibility
FROM php:7.0-cli

MAINTAINER PrivateBin <support@privatebin.org>

RUN \
# Install GD & xdebug (for code coverage)
    apt-get update \
    && apt-get install -y \
        git \
        libjpeg62-turbo-dev \
        libpng-dev \
        libfreetype6-dev \
        mime-support \
        unzip \
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
# Install node & npm
    && mkdir -p /opt/nvm \
    && curl -s https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | NVM_DIR=/opt/nvm NVM_METHOD=script bash \
    && . /opt/nvm/nvm.sh \
    && nvm install 4 \
    && npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types \
    && ln -s /bin/versions/node/v4.9.1/bin/node /usr/local/bin/node \
    && ln -s /bin/versions/node/v4.9.1/bin/mocha /usr/local/bin/mocha \
# cleanup to reduce already large image size
    && apt-get purge -y \
        git \
        git-man \
        less \
        libcurl3-gnutls \
        liberror-perl \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libpng-tools \
        openssh-client \
        rsync \
        unzip \
        xauth \
        zlib1g-dev \
    && rm -rf /bin/.cache \
        /bin/versions/node/v4.9.1/include \
        /root/.npm \
        /tmp/composer-setup.php \
        /tmp/npm-* \
        /tmp/pear \
        /var/lib/apt/lists/* \
        /var/log/*

# mark dirs as volumes that need to be writable, allows running the container --read-only
VOLUME /srv /tmp

COPY unit-test.sh /usr/local/bin/

WORKDIR /usr/local/bin

USER nobody

ENTRYPOINT ["unit-test.sh"]
