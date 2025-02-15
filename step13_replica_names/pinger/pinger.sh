#!/bin/bash

echo "Waiting."
sleep 1

echo "Pinging."

for i in $* ; do
  echo "URL:     $i/"
  echo -n "Result: "
  curl -s $i/ || echo "request failed."
done

for i in $* ; do
  echo "URL:     $i/q"
  echo -n "Result: "
  curl -s $i/q || echo "request failed."
done
