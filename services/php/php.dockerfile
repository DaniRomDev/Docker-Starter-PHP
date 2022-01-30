FROM php:fpm-alpine3.15 as php_base

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

COPY config/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN delgroup dialout
RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /var/www/html

RUN chown laravel:laravel /var/www/html

WORKDIR /var/www/html

RUN apk add --update --no-cache --virtual .build-deps \
    yaml-dev \
    bzip2-dev \
    g++ \
    gcc \
    make \
    zlib-dev \
    freetype \
    libxslt-dev \
    libbz2 \
    libpng \
    libzip-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    postgresql-dev \
    postgresql-libs \
    sqlite-dev \
    zstd-dev \
    icu-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-configure intl

RUN docker-php-ext-install bz2 xsl ctype filter opcache gd intl pdo pdo_mysql pdo_pgsql pdo_sqlite exif pcntl 

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]

FROM php_base AS php_cron

COPY cron/run-scheduler.sh /usr/bin/run-scheduler.sh
RUN chmod u+x /usr/bin/run-scheduler.sh

CMD ["/usr/bin/run-scheduler.sh"]

FROM php_base AS php_queue

CMD ["php", "/var/www/html/artisan", "queue:work"] 
