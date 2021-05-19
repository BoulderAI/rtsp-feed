FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine as cloud-sdk
# FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

# ENV STREAM_ENDPOINT=BAI_camerasn
ENV VIDEO_DIR=/data/
# This is the port of the rtsp_server input
# within the docker compose network, not necessarily
# the output port for the host
ARG PORT=8554

RUN mkdir /data/
RUN apk add  --no-cache ffmpeg

ADD run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
