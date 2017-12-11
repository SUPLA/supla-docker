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
      mbstring \
      opcache \
      intl \
      curl \
      zip \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/*

COPY apache-conf /etc/apache2/sites-available

RUN a2enmod rewrite expires deflate ssl cgi alias env proxy_http && a2ensite default-ssl

ARG CLOUD_VERSION=2.1.5
#COPY supla-cloud-v$CLOUD_VERSION.tar.gz ./

RUN wget -nc https://github.com/SUPLA/supla-cloud/releases/download/v$CLOUD_VERSION/supla-cloud-v$CLOUD_VERSION.tar.gz \
    && mkdir cloud \
    && tar -xzf supla-cloud-v$CLOUD_VERSION.tar.gz -C cloud \
    && rm -f supla-cloud-v$CLOUD_VERSION.tar.gz \
    && sed -i "s+/tmp/supla-server-ctrl.sock+/supla-server/supla-server-ctrl.sock+g" cloud/app/config/config.yml

WORKDIR /var/www/cloud

RUN chown -hR www-data:www-data .

COPY parameters.yml app/config/parameters.yml
