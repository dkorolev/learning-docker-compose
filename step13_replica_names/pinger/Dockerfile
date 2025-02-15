FROM alpine
RUN apk add curl bash
COPY ./pinger.sh .
ENTRYPOINT ["./pinger.sh"]
