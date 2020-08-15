FROM alpine:latest
RUN apk add --no-cache bash rclone inotify-tools
COPY etc/irclone/exclude /etc/irclone/exclude
COPY bin/irclone /usr/bin/irclone
RUN chmod u+x /usr/bin/irclone
ENV ORIGIN_PATH /backup
ENTRYPOINT ["/usr/bin/irclone"]
