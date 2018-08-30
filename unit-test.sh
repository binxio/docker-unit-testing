#!/bin/sh
[ ! -d /srv/tst ] && \
    echo "'tst' folder not found, are you sure you have attached your PrivateBin git repository as a volume to /srv?" 1>&2 && \
    exit 1

cp -r /srv /tmp/repo
[ -d /tmp/repo/js/node_modules ] && rm -rf /tmp/repo/js/node_modules
ln -s /usr/lib/node_modules /tmp/repo/js/node_modules

# run mocha (in background)
cd /tmp/repo/js && mocha > /tmp/mocha.out 2>&1 &

# run phpunit (in foreground)
cd /tmp/repo/tst && /usr/local/vendor/bin/phpunit

# present mocha results, when done
echo
wait
cat /tmp/mocha.out
