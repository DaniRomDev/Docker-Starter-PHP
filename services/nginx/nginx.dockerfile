FROM nginx:stable-alpine

ARG HOST_UID
ARG HOST_GID

ENV HOST_UID=${HOST_UID}
ENV HOST_GID=${HOST_GID}

RUN delgroup dialout
RUN addgroup -g ${HOST_GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${HOST_UID} laravel
RUN sed -i "s/user  nginx/user laravel/g" /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html && \
    chown laravel:laravel /var/www/html && \
    chown laravel /var/log/nginx/*.log

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf

