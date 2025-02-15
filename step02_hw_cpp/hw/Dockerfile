FROM alpine:latest AS build
RUN apk add g++
COPY ./hw.cc /
RUN g++ -static hw.cc -o hw

FROM alpine:latest
COPY --from=build /hw /hw
CMD /hw
