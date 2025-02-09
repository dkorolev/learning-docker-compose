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

while true ; do
  ENDPOINTS="$(curl -s http://indexer:8888/endpoints)"
  if [ "$ENDPOINTS" != "" ] ; then
    break
  fi
  echo "Not all the nodes are ready yet, waiting further."
  sleep 0.5
done

echo "And we have the cluster setup, ready to run the demo."
echo "ENDPOINTS=$ENDPOINTS"
# http://etcd-0:2380,http://etcd-1:2380,http://etcd-2:2380

while true ; do
  etcdctl --endpoints="$ENDPOINTS" endpoint health && break
  echo 'The etcd cluster is not healthy yet, waiting.'
  sleep 0.5
done

echo 'The etcd cluster is up and running. Querying its status.'

etcdctl --endpoints="$ENDPOINTS" endpoint status --write-out=table

echo 'The demo is done, stopping etcd nodes.'

for IP in $(curl -s http://indexer:8888/ips) ; do
  echo "curl -s http://$IP:8888/stop"
  curl -s http://$IP:8888/stop
done

echo 'Stopped the nodes.'

curl -s http://indexer:8888/quit

echo 'Stopped the indexer.'
