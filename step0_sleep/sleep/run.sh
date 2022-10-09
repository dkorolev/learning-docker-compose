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

N=60
for i in $(seq $N); do
  echo $i / $N
  sleep 1
done
