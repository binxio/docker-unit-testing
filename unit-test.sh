#!/bin/sh
[ ! -d /srv/tst ] && \
    echo "'tst' folder not found, are you sure you have attached your PrivateBin git repository as a volume to /srv?" 1>&2 && \
    exit 1

cp -r /srv /tmp/repo
[ -d /tmp/repo/js/node_modules ] && rm -rf /tmp/repo/js/node_modules
ln -s /usr/lib/node_modules /tmp/repo/js/node_modules

# run mocha…
cd /tmp/repo/js
# …(in foreground)
[ "$1" = mocha ] && mocha
# …(in background)
[ -z "$1" ] && mocha > /tmp/mocha.out 2>&1 &

# run phpunit (in foreground)
cd /tmp/repo/tst
[ "$1" = phpunit -o -z "$1" ] && /usr/local/vendor/bin/phpunit --no-coverage

# present mocha results, when done
[ -z "$1" ] && wait && cat /tmp/mocha.out

