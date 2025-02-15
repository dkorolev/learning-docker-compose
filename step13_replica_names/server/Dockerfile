FROM alpine:latest
RUN apk add bash python3 clang cmake make git

RUN git clone https://github.com/dkorolev/pls
RUN ln -sf $PWD/pls/pls/pls /usr/local/bin/

WORKDIR code
COPY server.cc /code/server.cc
RUN pls build

ENTRYPOINT [".debug/server"]
