#PHP BASE IMAGE FOR MULTI STAGING
FROM php:fpm-alpine3.15

ARG HOST_UID
ARG HOST_GID
ARG APP_USER

ENV HOST_UID=${HOST_UID}
ENV HOST_GID=${HOST_GID}
ENV APP_USER=${APP_USER}

COPY config/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY cron/start.sh /usr/local/bin/start

RUN delgroup dialout
RUN addgroup -g ${HOST_GID} --system ${APP_USER}
RUN adduser -G ${APP_USER} --system -D -s /bin/sh -u ${HOST_UID} ${APP_USER}

RUN sed -i "s/user = www-data/user = ${APP_USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${APP_USER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /var/www/html && \
    chown ${APP_USER}:${APP_USER} /var/www/html && \
    chmod u+x /usr/local/bin/start

WORKDIR /var/www/html

RUN apk add --update --no-cache --virtual .build-deps \
    autoconf \
    nodejs \
    npm \
    automake \
    g++ \
    bash \
    gcc \
    make \
    libzip-dev \
    postgresql-dev \
    postgresql-libs \
    sqlite-dev \
    mysql-client

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-configure intl

RUN docker-php-ext-install bcmath opcache zip intl pdo pdo_mysql mysqli pdo_pgsql pdo_sqlite pcntl 
RUN docker-php-ext-enable opcache

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

COPY --from=composer:2.2.6 /usr/bin/composer /usr/local/bin/composer
