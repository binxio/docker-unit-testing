#!/bin/sh

if [ ! -d /srv/tst ]
then
    echo "'tst' folder not found, are you sure you have attached your PrivateBin repository as a volume to /srv?" 1>&2
    exit 1
fi

cp -r /srv /tmp/repo

# run phpunit
cd /tmp/repo/tst && /opt/vendor/bin/phpunit
