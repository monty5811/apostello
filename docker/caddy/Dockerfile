FROM alpine:3.3

RUN apk add --update curl \
    && curl -sLO https://github.com/mholt/caddy/releases/download/v0.8.3/caddy_linux_amd64.tar.gz \
    && tar -xvzf caddy_linux_amd64.tar.gz \
    && mv caddy_linux_amd64 /usr/bin/caddy \ 
    && chmod 755 /usr/bin/caddy && rm -rf caddy* init *.txt \
    && apk del --purge curl \
    && rm -rf /var/cache/apk/*

RUN mkdir /apostello
WORKDIR /apostello

COPY docker/caddy/Caddyfile /apostello/Caddyfile
COPY docker/caddy/start_server.sh /apostello/start_server.sh

CMD caddy -email $CADDY_LE_EMAIL
