FROM alpine:3.15
RUN apk add --no-cache --virtual .run-deps rsync curl sqlite && rm -rf /var/cache/apk/*
CMD ["sh"]