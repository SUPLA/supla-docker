FROM php:7.4.33-apache

ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/1.5.33/install-php-extensions /usr/local/bin/

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      libicu-dev \
      libpq-dev \
      ca-certificates \
      ssl-cert \
      libcurl4-gnutls-dev \
      mariadb-client \
      libzip-dev \
      zip \
      unzip \
    && update-ca-certificates \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions \
      pdo_mysql \
      mbstring \
      intl \
      curl \
      zip \
      gd \
      iconv \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

COPY --from=composer:2.3.4 /usr/bin/composer /usr/local/bin/composer
