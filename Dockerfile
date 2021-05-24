FROM alpine:3.13

LABEL maintainer="support@privatebin.org"

RUN wget -q -O /tmp/gcs.tar.gz \
    https://github.com/fsouza/fake-gcs-server/releases/download/v1.25.0/fake-gcs-server_1.25.0_Linux_amd64.tar.gz && \
    test  "$(sha256sum /tmp/gcs.tar.gz | awk '{print $1}')" = "30543e3fcd5c1f394f14c6f059de0438bc36789969e9af554abfe77240a1bbfe" && \
    tar -C /usr/local/bin -zxf /tmp/gcs.tar.gz fake-gcs-server && \
    rm /tmp/gcs.tar.gz

RUN \
# Install dependencies
    apk add --no-cache composer php7 php7-json php7-gd php7-opcache \
        php7-pdo_sqlite php7-mbstring php7-dom php7-xml php7-xmlwriter \
        php7-tokenizer php7-fileinfo nodejs npm mailcap \
# Install npm modules
    && npm config set unsafe-perm=true \
    && npm install -g mocha jsverify jsdom@9 jsdom-global@2 mime-types @peculiar/webcrypto jsdom-url fake-indexeddb \
    && wget -qO- https://install.goreleaser.com/github.com/tj/node-prune.sh | sh \
    && node-prune /usr/lib/node_modules \
# Install composer modules
    && cd /usr/local \
    && composer require phpunit/phpunit:^5.0 \
# cleanup to reduce the already large image size
    && apk del --no-cache composer npm \
    && rm -rf /bin/.cache \
        /bin/node-prune \
        /etc/mailcap \
        /root/.??* \
        /tmp/* \
        /usr/lib/node_modules/npm \
        /usr/local/composer.* \
        /var/log/*

# mark dirs as volumes that need to be writable, allows running the container --read-only
VOLUME /srv /tmp

COPY unit-test.sh /usr/local/bin/

WORKDIR /usr/local/bin

USER nobody

ENV GOOGLE_CLOUD_PROJECT fake-project

ENTRYPOINT ["unit-test.sh"]
