#!/bin/sh
set -eo pipefail

WORKERS=${WORKERS:-1}
WORKER_CLASS=${WORKER_CLASS:-gevent}
ACCESS_LOG=${ACCESS_LOG:--}
ERROR_LOG=${ERROR_LOG:--}
WORKER_TEMP_DIR=${WORKER_TEMP_DIR:-/dev/shm}
MAX_REQUESTS=${MAX_REQUESTS:-0}
PORT=${PORT:-8000}

# Check that a .ctfd_secret_key file or SECRET_KEY envvar is set
if [ ! -f .ctfd_secret_key ] && [ -z "$SECRET_KEY" ]; then
    if [ $WORKERS -gt 1 ]; then
        echo "[ ERROR ] You are configured to use more than 1 worker."
        echo "[ ERROR ] To do this, you must define the SECRET_KEY environment variable or create a .ctfd_secret_key file."
        echo "[ ERROR ] Exiting..."
        exit 1
    fi
fi

# Check that the database is available
if [ -n "$DATABASE_URL" ]
    then
    if [ -z "${DATABASE_URL##sqlite*}" ]
    then
        echo "The database server is sqlite"
    else
        url=`echo $DATABASE_URL | awk -F[@//] '{print $4}'`
        database=`echo $url | awk -F[:] '{print $1}'`
        port=`echo $url | awk -F[:] '{print $2}'`
        echo "Waiting for $database:$port to be ready"
        while ! nc -w 1 $database $port; do
            # Show some progress
            echo -n '.';
            sleep 1;
        done
        echo "$database is ready"
        # Give it another second.
        sleep 1;
    fi
fi

# Start CTFd
echo "Starting CTFd"
exec gunicorn "CTFd:create_app()" \
    --bind 0.0.0.0:$PORT \
    --workers $WORKERS \
    --worker-tmp-dir "$WORKER_TEMP_DIR" \
    --worker-class "$WORKER_CLASS" \
    --access-logfile "$ACCESS_LOG" \
    --error-logfile "$ERROR_LOG" \
    --max-requests "$MAX_REQUESTS"
