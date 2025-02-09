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
  etcdctl --endpoints="http://etcd-0:2380,http://etcd-1:2380,http://etcd-2:2380" endpoint health && break
  echo 'The etcd cluster is not healthy yet, waiting.'
  sleep 0.5
done

echo 'The etcd cluster is up and running. Querying its status.'

etcdctl --endpoints="http://etcd-0:2380,http://etcd-1:2380,http://etcd-2:2380" endpoint status --write-out=table

echo 'The demo is done, stopping etcd nodes.'

curl -s http://etcd-0:8888/stop
curl -s http://etcd-1:8888/stop
curl -s http://etcd-2:8888/stop

echo 'Stopped the nodes.'
