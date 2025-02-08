# `step7`

To see the delay in action, start the service:

```
docker compose up
```

Test the query:

```
curl localhost:8888/inc/1
```

Add the delay:

```
docker exec -i $(docker ps | grep -i add_service | cut -f 1 -d' ') sh -c 'tc qdisc add dev eth0 root netem delay 100ms'
```

Now re-test the query. To remove the delay:

```
docker exec -i $(docker ps | grep -i add_service | cut -f 1 -d' ') sh -c 'tc qdisc del dev eth0 root netem'
```
