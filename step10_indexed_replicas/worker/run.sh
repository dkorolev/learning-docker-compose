#!/bin/sh

echo "HOSTNAME: '$HOSTNAME'"

if [ "$ALL" != "" ] ; then
  echo "SET:"
  set
  echo "ENV:"
  env
fi
