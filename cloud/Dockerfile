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
      supervisor \
      cron \
    && update-ca-certificates \
    && docker-php-ext-install \
      pdo_mysql \
      mbstring \
      opcache \
      intl \
      curl \
      zip \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

COPY apache-conf /etc/apache2/sites-available
COPY crontab /etc/cron.d/supla-cron

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini \
    && a2enmod rewrite expires deflate ssl cgi alias env && a2ensite default-ssl \
    && chmod 0644 /etc/cron.d/supla-cron

ENV CLOUD_VERSION=2.2.0
COPY supla-cloud-v$CLOUD_VERSION.tar.gz ./

RUN wget -nc https://github.com/SUPLA/supla-cloud/releases/download/v${CLOUD_VERSION}/supla-cloud-v${CLOUD_VERSION}.tar.gz \
    && mkdir cloud \
    && tar -xzf supla-cloud-v${CLOUD_VERSION}.tar.gz -C cloud \
    && rm -f supla-cloud-v${CLOUD_VERSION}.tar.gz \
    && sed -i "s+/tmp/supla-server-ctrl.sock+/supla-server/supla-server-ctrl.sock+g" cloud/app/config/config.yml \
    && cp cloud/app/config/parameters.yml.dist cloud/app/config/parameters.yml \
    && sed -i "s#database_host: 127.0.0.1#database_host: supla-db#" cloud/app/config/parameters.yml \
    && sed -i "s#database_user: root#database_user: supla#" cloud/app/config/parameters.yml \
    && chown -hR www-data:www-data cloud

WORKDIR /var/www/cloud

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY cloud-entrypoint.sh /usr/local/bin/docker-php-entrypoint

CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
