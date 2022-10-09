FROM alpine:latest as build
RUN apk add g++
RUN apk add git
RUN git clone https://github.com/c5t/current
COPY ./pre.cc /
RUN g++ -static pre.cc -o pre

FROM alpine:latest
RUN apk add curl
COPY --from=build /pre /pre
HEALTHCHECK --interval=0.25s --timeout=1s --retries=100 --start-period=3s CMD curl -f http://localhost/healthz || exit 1
ENTRYPOINT ["/pre"]
