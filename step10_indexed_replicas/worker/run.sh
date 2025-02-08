#!/bin/sh

echo "HOSTNAME:   '$HOSTNAME'"

# NOTE(dkorolev): Somehow the `healthcheck:` from `docker-compose.yml` is not respected by my `podman-compose`.
#                 Works fine under Docker.
while true ; do
  curl -s http://indexer:8888/healthz 2>&1 >/dev/null && break
  echo 'The indexer service is not healthy, and `docker-compose` does not handle `depends_on`. Waiting.'
  sleep 0.1
done

N="$(curl -s http://indexer:8888/index)"
echo "HOSTNAME_N: $N"

if [ "$ALL" != "" ] ; then
  echo "SET:"
  set
  echo "ENV:"
  env
fi
