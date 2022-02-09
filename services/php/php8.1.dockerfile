#PHP BASE IMAGE FOR MULTI STAGING
FROM  php:8.1.3RC1-fpm-alpine3.15 as php_base


ARG HOST_UID
ARG HOST_GID

ENV HOST_UID=${HOST_UID}
ENV HOST_GID=${HOST_GID}

COPY config/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN delgroup dialout
RUN addgroup -g ${HOST_GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${HOST_UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /var/www/html && \
    chown laravel:laravel /var/www/html 

WORKDIR /var/www/html

RUN apk add --update --no-cache --virtual .build-deps \
    autoconf \
    automake \
    g++ \
    bash \
    gcc \
    make \
    libzip-dev \
    postgresql-dev \
    postgresql-libs \
    sqlite-dev 

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-configure intl

RUN docker-php-ext-install bcmath opcache zip intl pdo pdo_mysql pdo_pgsql pdo_sqlite pcntl 
RUN docker-php-ext-enable opcache
#PHP MAIN image with redis extension
FROM php_base as php_main

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]

#PHP IMAGE FOR CRON SCHEDULER
FROM php_base AS php_cron

COPY cron/run-scheduler.sh /usr/bin/run-scheduler.sh
RUN chmod u+x /usr/bin/run-scheduler.sh

CMD ["/usr/bin/run-scheduler.sh"]

#PHP IMAGE FOR QUEUE DAEMON
FROM php_base AS php_queue

CMD ["php", "/var/www/html/artisan", "queue:work"] 
