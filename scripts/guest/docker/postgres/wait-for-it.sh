#!/bin/bash
set -e
host="$1"

until docker exec postgres bash -c 'psql -h "$host" -U "postgres" -lqt | cut -d \| -f 1 | grep -qw initfinished' ; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done