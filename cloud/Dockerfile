FROM php:8.4.20-apache

ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/2.10.12/install-php-extensions /usr/local/bin/

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
      pdo_pgsql \
      mbstring \
      opcache \
      intl \
      curl \
      zip \
      gd \
      iconv \
      calendar \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

COPY apache-conf /etc/apache2/sites-available
COPY crontab /etc/cron.d/supla-cron
COPY php.ini /usr/local/etc/php/conf.d/php-supla.ini

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && { \
        echo 'ServerTokens Prod'; \
        echo 'ServerSignature Off'; \
    } >> /etc/apache2/apache2.conf \
    && a2enmod headers rewrite expires deflate ssl cgi alias env \
    && chmod 0644 /etc/cron.d/supla-cron

ENV APP_ENV=prod
ENV APP_DEBUG=0
ENV CLOUD_VERSION=26.05.01
#COPY supla-cloud.tar.gz ./supla-cloud-v$CLOUD_VERSION.tar.gz

RUN a2ensite default-ssl \
    && wget -nc https://github.com/SUPLA/supla-cloud/releases/download/v${CLOUD_VERSION}/supla-cloud-v${CLOUD_VERSION}.tar.gz \
    && mkdir cloud \
    && tar -xzf supla-cloud-v${CLOUD_VERSION}.tar.gz -C cloud \
    && rm -f supla-cloud-v${CLOUD_VERSION}.tar.gz \
    && chown -hR www-data:www-data cloud

WORKDIR /var/www/cloud

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY cloud-entrypoint.sh /usr/local/bin/docker-php-entrypoint

CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
