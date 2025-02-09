# Build `etcd`, as well as `etcdctl`, from scratch, to have static binaries.
FROM alpine AS etcd
RUN apk add git go
RUN git clone --depth 1 --no-checkout https://github.com/etcd-io/etcd etcd
RUN (cd etcd; git fetch --tags)
RUN (cd etcd; git checkout tags/v3.5.18)
RUN (cd etcd; git rev-parse HEAD)  # Should be 5bca08ec10d2ffcc658a5002381a3e5600d7132f as of 2024-Feb-08.
RUN apk add bash
RUN (cd etcd; ./build.sh)

FROM alpine

# NOTE(dkorolev): This did not work forme.
# ENV PIP_NO_CACHE_DIR=1

RUN apk add bash python3 py3-pip gcc python3-dev musl-dev linux-headers
RUN mkdir -p /usr/local/bin
COPY --from=etcd /etcd/bin/etcd /usr/local/bin/
COPY --from=etcd /etcd/bin/etcdctl /usr/local/bin/

RUN python3 -m venv ./venv
RUN (source venv/bin/activate; pip install psutil)

COPY ./etcd_node.sh /
COPY ./killer.py /
ENTRYPOINT ["/etcd_node.sh"]
