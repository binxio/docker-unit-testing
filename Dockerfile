FROM php:7.3-cli-alpine

LABEL maintainer="support@privatebin.org"

RUN \
# Install dependencies
    apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev mailcap \
        nodejs nodejs-npm python make g++ \
# Install npm modules
    && npm config set unsafe-perm=true \
    && npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types node-webcrypto-ossl \
    && curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | sh \
    && node-prune /usr/lib/node_modules \
# Install composer
    && curl -s https://getcomposer.org/installer > /tmp/composer-setup.php \
    && [ "$(curl -s https://composer.github.io/installer.sig)" = "$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');")" ] \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && cd /usr/local \
    && composer require phpunit/phpunit:^5.0 \
# Configure & build GD
    && docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
# cleanup to reduce the already large image size
    && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev nodejs-npm python make g++ \
    && rm -rf /bin/.cache \
        /bin/node-prune \
        /etc/mailcap \
        /root/.??* \
        /tmp/* \
        /usr/local/composer.* \
        /usr/lib/node_modules/npm \
        /var/lib/apt/lists/* \
        /var/log/*

# mark dirs as volumes that need to be writable, allows running the container --read-only
VOLUME /srv /tmp

COPY unit-test.sh /usr/local/bin/

WORKDIR /usr/local/bin

USER nobody

ENTRYPOINT ["unit-test.sh"]
