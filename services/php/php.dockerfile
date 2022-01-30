FROM php:8.0.10-fpm-alpine3.13 as php_base

COPY config/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN addgroup -g 1000 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

RUN mkdir -p /var/www/html

RUN chown laravel:laravel /var/www/html

WORKDIR /var/www/html

RUN apk add --no-cache \
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

RUN docker-php-ext-install bz2 xsl ctype filter opcache tokenizer gd intl pdo pdo_mysql pdo_pgsql pdo_sqlite exif pcntl sockets 

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
