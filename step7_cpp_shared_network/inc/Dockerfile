FROM alpine:latest as build
RUN apk add g++
RUN apk add git
RUN git clone https://github.com/c5t/current
COPY ./inc.cc /
RUN g++ -static inc.cc -o inc

FROM alpine:latest
COPY --from=build /inc /inc
ENTRYPOINT ["/inc"]
