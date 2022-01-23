FROM nginx:1.21.1-alpine

RUN addgroup -g 1000 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

RUN mkdir -p /var/www/html && \
    chown laravel:laravel /var/www/html && \
    chown laravel /var/log/nginx/*.log

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf
