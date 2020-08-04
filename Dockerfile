FROM alpine:latest
RUN apk add --no-cache bash rclone inotify-tools
COPY etc/rclup/exclude /etc/rclup/exclude
COPY bin/rclup /usr/bin/rclup
RUN chmod u+x /usr/bin/rclup
ENV ORIGIN_PATH /backup
ENTRYPOINT ["/usr/bin/rclup"]
