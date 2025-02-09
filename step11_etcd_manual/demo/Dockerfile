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
RUN apk add bash curl
RUN mkdir -p /usr/local/bin
COPY --from=etcd /etcd/bin/etcd /usr/local/bin/
COPY --from=etcd /etcd/bin/etcdctl /usr/local/bin/
COPY ./demo.sh /
ENTRYPOINT ["/demo.sh"]
