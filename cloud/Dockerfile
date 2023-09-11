FROM php:7.3.33-apache

ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/1.5.29/install-php-extensions /usr/local/bin/

WORKDIR /var/www

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      libicu-dev \
      libpq-dev \
      ca-certificates \
      ssl-cert \
      libcurl4-gnutls-dev \
      git \
      unzip \
      mariadb-client \
      wget \
      supervisor \
      cron \
      libzip-dev \
      zip \
    && update-ca-certificates \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions \
      pdo_mysql \
      mbstring \
      opcache \
      intl \
      curl \
      zip \
      gd \
      iconv \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

COPY apache-conf /etc/apache2/sites-available
COPY crontab /etc/cron.d/supla-cron
COPY php.ini /usr/local/etc/php/conf.d/php-supla.ini

RUN ln -s /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && { \
        echo 'ServerTokens Prod\n'; \
        echo 'ServerSignature Off\n'; \
    } >> /etc/apache2/apache2.conf \
    && a2enmod headers rewrite expires deflate ssl cgi alias env \
    && chmod 0644 /etc/cron.d/supla-cron

ENV CLOUD_VERSION=23.09
#COPY supla-cloud.tar.gz ./supla-cloud-v$CLOUD_VERSION.tar.gz

RUN a2ensite default-ssl \
    && wget -nc https://github.com/SUPLA/supla-cloud/releases/download/v${CLOUD_VERSION}/supla-cloud-v${CLOUD_VERSION}.tar.gz \
    && mkdir cloud \
    && tar -xzf supla-cloud-v${CLOUD_VERSION}.tar.gz -C cloud \
    && rm -f supla-cloud-v${CLOUD_VERSION}.tar.gz \
    && sed -i "s+/var/run/supla/supla-server-ctrl.sock+/supla-server/supla-server-ctrl.sock+g" cloud/app/config/config.yml \
    && chown -hR www-data:www-data cloud

WORKDIR /var/www/cloud

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY cloud-entrypoint.sh /usr/local/bin/docker-php-entrypoint

HEALTHCHECK --interval=30s --timeout=5s --retries=3 --start-period=30s \
    CMD wget --no-verbose --tries=1 --spider http://localhost/api/server-info || exit 1

CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
