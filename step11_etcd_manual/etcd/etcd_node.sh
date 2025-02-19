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

# NOTE(dkorolev): Use the `&` + `wait` combo for trapped signals to work, so that shutdowns are fast.

/usr/local/bin/etcd \
  --name=step11_etcd_manual-$NAME \
  --initial-advertise-peer-urls=http://step11_etcd_manual-$NAME:2380 \
  --advertise-client-urls=http://step11_etcd_manual-$NAME:2379 \
  --listen-client-urls=http://0.0.0.0:2379 \
  --listen-peer-urls=http://0.0.0.0:2380 \
  --initial-cluster-token=blah \
  --initial-cluster=etcd-0=http://step11_etcd_manual-etcd-0:2380,etcd-1=http://step11_etcd_manual-etcd-1:2380,etcd-2=http://step11_etcd_manual-etcd-2:2380 \
  --initial-cluster-state=new \
  --data-dir=/var/lib/etcd 2>&1 &
ETCD_PID=$!

echo "ETCD PID: $ETCD_PID"

source venv/bin/activate
KILL_PID=$ETCD_PID python3 killer.py
