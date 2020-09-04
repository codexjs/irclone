FROM alpine:latest
RUN apk add --no-cache bash curl zip inotify-tools
RUN curl https://rclone.org/install.sh | bash
RUN apk del curl zip
COPY etc/irclone/exclude /etc/irclone/exclude
COPY bin/irclone /usr/bin/irclone
RUN chmod 755 /usr/bin/irclone
ENV ORIGIN_PATH /backup
ENTRYPOINT ["/usr/bin/irclone"]
