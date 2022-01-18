FROM alpine:3.15
RUN apk add --no-cache --virtual .run-deps bash rsync sqlite curl  && rm -rf /var/cache/apk/*
CMD ["sh"]