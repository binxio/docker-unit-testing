#!/bin/sh
[ ! -d /srv/tst ] && \
    echo "'tst' folder not found, are you sure you have attached your PrivateBin git repository as a volume to /srv?" 1>&2 && \
    exit 1

cp -r /srv /tmp/repo
[ -d /tmp/repo/js/node_modules ] && rm -rf /tmp/repo/js/node_modules
ln -s /usr/lib/node_modules /tmp/repo/js/node_modules
COMMAND="$1"
[ -n "$COMMAND" ] && shift

# run mocha…
cd /tmp/repo/js
# …(in foreground)
[ "$COMMAND" = mocha ] && mocha -c "$@"
# …(in background)
[ -z "$COMMAND" ] && mocha -c > /tmp/mocha.out 2>&1 &

if [ "$COMMAND" = phpunit -o -z "$COMMAND" ]; then
        # start fake GCS server
	/usr/local/bin/fake-gcs-server \
	  -host localhost \
	  -filesystem-root /tmp/gcs &
        GCS_ID=$!

	# run phpunit (in foreground)
	cd /tmp/repo/tst
	/usr/local/vendor/bin/phpunit --no-coverage --colors=always "$@"
        # stop the server again
        kill -15 $GCS_ID
fi

# present mocha results, when done
[ -z "$COMMAND" ] && wait && cat /tmp/mocha.out

