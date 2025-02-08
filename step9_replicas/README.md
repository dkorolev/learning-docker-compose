# `step9_replicas`

## Run Instructions

Outer script (keep in mind `HOSTNAME` may well be empty in the output.

```
./worker/run.sh
```

To run it inside Docker:

```
(cd worker; docker build .; docker run -t $(docker build -q .))
```

To run several replicas:

```
# Full output.
docker compose up --build

# Short output
docker compose up --build 2>&1 | grep HOSTNAME
```

My Ubuntu `podman` short output (each `worker` is printed in its own color):

```
[worker] | HOSTNAME: '0c3f46489c97'
[worker] | HOSTNAME: '7a899c8d84ef'
[worker] | HOSTNAME: '350dfc626bc0'
[worker] | HOSTNAME: '32c28dd896cb'
[worker] | HOSTNAME: '723c4a1f4b01'
```
