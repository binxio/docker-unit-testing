#!/bin/sh

if [ ! -d /srv/tst ]
then
    echo "'tst' folder not found, are you sure you have attached your PrivateBin repository as a volume to /srv?" 1>&2
    exit 1
fi

# run phpunit
cd /srv/tst && /opt/vendor/bin/phpunit
