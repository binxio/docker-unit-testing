#!/bin/sh

if [ ! -d /srv/tst ]
then
    echo "'tst' folder not found, are you sure you have attached your PrivateBin repository as a volume to /srv?" 1>&2
    exit 1
fi

cp -r /srv /tmp/repo
ln -s /bin/versions/node/v4.9.1/lib/node_modules /tmp/repo/js/node_modules

# run mocha (in background)
cd /tmp/repo/js && mocha 2> /tmp/mocha.out > /tmp/mocha.out &

# run phpunit (in foreground)
cd /tmp/repo/tst && /usr/local/vendor/bin/phpunit

# present mocha results, when done
echo
wait
cat /tmp/mocha.out
