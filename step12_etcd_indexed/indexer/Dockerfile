# NOTE(dkorolev): I made this logic work with pure `sh` and `nc` on `alpine`,
#                 but it struggles with graceful shutdown. So Python it is.
FROM alpine
RUN apk add python3 curl
COPY indexer.py .
EXPOSE 8888
CMD ["python", "indexer.py"]
