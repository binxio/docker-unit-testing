FROM alpine:3.12

LABEL maintainer="support@privatebin.org"

RUN \
# Install dependencies
    apk add --no-cache php7 php7-json php7-gd php7-opcache php7-pdo_sqlite \
        php7-phar php7-openssl php7-mbstring php7-dom php7-xml php7-xmlwriter \
        php7-tokenizer php7-fileinfo nodejs npm mailcap \
# Install npm modules
    && npm config set unsafe-perm=true \
    && npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types @peculiar/webcrypto jsdom-url \
    && wget -qO- https://install.goreleaser.com/github.com/tj/node-prune.sh | sh \
    && node-prune /usr/lib/node_modules \
# Install composer
    && wget -qO /tmp/composer-setup.php https://getcomposer.org/installer \
    && [ "$(wget -qO- https://composer.github.io/installer.sig)" = "$(php -r "echo hash_file('SHA384', '/tmp/composer-setup.php');")" ] \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && cd /usr/local \
    && composer require phpunit/phpunit:^5.0 \
# cleanup to reduce the already large image size
    && apk del --no-cache php7-phar php7-openssl npm \
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
