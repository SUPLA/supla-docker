FROM php:7.0.26-apache

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
      mysql-client \
      wget \
    && update-ca-certificates \
    && docker-php-ext-install \
      pdo_mysql \
      opcache \
      curl \
      zip \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/*

RUN a2enmod rewrite expires deflate ssl cgi alias env proxy_http

ARG CLOUD_VERSION=2.1.5
RUN wget https://github.com/SUPLA/supla-cloud/releases/download/v$CLOUD_VERSION/supla-cloud-v$CLOUD_VERSION.tar.gz \
    && mkdir cloud \
    && tar -xzf supla-cloud-v$CLOUD_VERSION.tar.gz -C cloud \
    && rm -f supla-cloud-v$CLOUD_VERSION.tar.gz

ADD parameters.yml cloud/app/config/parameters.yml

RUN a2ensite default-ssl

WORKDIR /var/www/cloud
RUN php bin/console doctrine:query:sql --no-interaction "$(< app/DoctrineMigrations/supla-1.1.0.sql)" \
    && php bin/console doctrine:migrations:migrate --no-interaction \
    && php bin/console cache:clear --no-warmup \
    && php bin/console cache:warmup

RUN chown -hR www-data:www-data /var/www/cloud/var
