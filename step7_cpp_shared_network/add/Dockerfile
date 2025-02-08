FROM alpine:latest as build
RUN apk add g++
RUN apk add git
RUN git clone https://github.com/c5t/current
COPY ./add.cc /
RUN g++ -static add.cc -o add

FROM alpine:latest
RUN apk add iproute2
COPY --from=build /add /add
ENTRYPOINT ["/add"]
