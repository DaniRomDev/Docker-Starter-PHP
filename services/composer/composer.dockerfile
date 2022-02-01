
FROM composer:2.2.4

ARG HOST_UID
ARG HOST_GID

ENV HOST_UID=${HOST_UID}
ENV HOST_GID=${HOST_GID}

RUN delgroup dialout
RUN addgroup -g ${HOST_GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${HOST_UID} laravel

WORKDIR /var/www/html
