#!/bin/bash

function cb_sigint()
{
  echo
  echo "Caught SIGINT."
  exit
}
function cb_sigterm()
{
  echo
  echo "Caught SIGTERM."
  exit
}
function cb_sigquit()
{
  echo
  echo "Caught SIGQUIT."
  exit
}
trap cb_sigint SIGINT
trap cb_sigterm SIGTERM
trap cb_sigquit SIGQUIT

# NOTE(dkorolev): Somehow the `healthcheck:` from `docker-compose.yml` is not respected by my `podman-compose`.
#                 Works fine under Docker.
while true ; do
  curl -s http://indexer:8888/healthz 2>&1 >/dev/null && break
  echo 'The indexer service is not healthy, and `docker-compose` does not handle `depends_on`. Waiting.'
  sleep 0.1
done

echo "The indexer is available."
# Report self, under `$IP`, to the indexer. NOTE(dkorolev): Can't really use `$HOSTNAME`, unfortunately.
IP="$(ip -4 -o a | awk '{print $4}' | cut -d'/' -f1 | grep -v "^127.0.0.1$" | grep -v "^0.0.0.0$" | head -n 1)"
echo -n "The short name for '$HOSTNAME'='$IP' is ... "
NAME="$(curl -s -d "$IP" http://indexer:8888/name_me)"
echo -e "\b\b\b\b'$NAME'."

while true ; do
  CLUSTER="$(curl -s http://indexer:8888/cluster)"
  if [ "$CLUSTER" != "" ] ; then
    break
  fi
  echo "Not all the nodes are ready yet, waiting further."
  sleep 0.5
done

echo "And we have the cluster setup, ready to start etcd."
echo "CLUSTER=$CLUSTER"

# Should be something like:
# etcd-0=http://etcd-0:2380,etcd-1=http://etcd-1:2380,etcd-2=http://etcd-2:2380 
# But with IP addresses this time.

rm -rf /var/lib/etcd

/usr/local/bin/etcd \
  --name=$NAME \
  --initial-advertise-peer-urls=http://$IP:2380 \
  --advertise-client-urls=http://$IP:2379 \
  --listen-client-urls=http://0.0.0.0:2379 \
  --listen-peer-urls=http://0.0.0.0:2380 \
  --initial-cluster-token=blah \
  --initial-cluster=$CLUSTER \
  --initial-cluster-state=new \
  --log-level=error \
  --data-dir=/var/lib/etcd 2>&1 &
ETCD_PID=$!

echo "ETCD PID: $ETCD_PID"

# NOTE(dkorolev): This example container absolutely does not need Python, but life is life as of now, and I'm too tired.
source venv/bin/activate
KILL_PID=$ETCD_PID python3 killer.py
