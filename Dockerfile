FROM alpine:3.10.0

LABEL maintainer="support@privatebin.org"

RUN \
# Install dependencies
    apk add --no-cache php7 php7-json php7-gd php7-opcache php7-pdo_sqlite \
        php7-phar php7-openssl php7-mbstring php7-dom php7-xml php7-xmlwriter \
        php7-tokenizer php7-fileinfo nodejs npm mailcap python curl make g++ \
# Install npm modules
    && npm config set unsafe-perm=true \
    && npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types node-webcrypto-ossl jsdom-url \
    && curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | sh \
    && node-prune /usr/lib/node_modules \
# Install composer
    && curl -s https://getcomposer.org/installer > /tmp/composer-setup.php \
    && [ "$(curl -s https://composer.github.io/installer.sig)" = "$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');")" ] \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && cd /usr/local \
    && composer require phpunit/phpunit:^5.0 \
# cleanup to reduce the already large image size
    && apk del --no-cache php7-phar php7-openssl npm python curl make g++ \
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
