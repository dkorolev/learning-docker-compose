FROM alpine:latest as build
RUN apk add g++
RUN apk add git
RUN git clone https://github.com/c5t/current
COPY ./http.cc /
RUN g++ -static http.cc -o http

FROM alpine:latest
COPY --from=build /http /http
ENTRYPOINT ["/http"]
