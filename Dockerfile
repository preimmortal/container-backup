FROM alpine:3.15
RUN apk add --no-cache --virtual .run-deps bash rsync sqlite curl  && rm -rf /var/cache/apk/*

ENV USER=backup
ENV USERGROUP=backup
ENV PUID=1000
ENV PGID=1000

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]