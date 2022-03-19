FROM nginx:stable-alpine

ARG HOST_UID
ARG HOST_GID
ARG APP_USER

ENV HOST_UID=${HOST_UID}
ENV HOST_GID=${HOST_GID}
ENV APP_USER=${APP_USER}

RUN delgroup dialout
RUN addgroup -g ${HOST_GID} --system ${APP_USER}
RUN adduser -G ${APP_USER} --system -D -s /bin/sh -u ${HOST_UID} ${APP_USER}

RUN mkdir -p /var/www/html && \
    chown ${APP_USER}:${APP_USER} /var/www/html && \
    chown ${APP_USER} /var/log/nginx/*.log

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf

RUN sed -i "s/^user.*/user ${APP_USER};/" /etc/nginx/nginx.conf

