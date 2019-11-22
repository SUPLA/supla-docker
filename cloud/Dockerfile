FROM php:7.0.33-apache AS supla_cloud_base

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
      zlib1g-dev \
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

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/*

COPY apache-conf /etc/apache2/sites-available
COPY crontab /etc/cron.d/supla-cron

RUN ln -s /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN { \
            echo 'opcache.memory_consumption=192'; \
            echo 'opcache.interned_strings_buffer=8'; \
            echo 'opcache.max_accelerated_files=10000'; \
            echo 'opcache.revalidate_freq=0'; \
            echo 'opcache.fast_shutdown=1'; \
            echo 'opcache.enable_cli=1'; \
            echo 'opcache.validate_timestamps=0'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini \
    && a2enmod headers rewrite expires deflate ssl cgi alias env \
    && chmod 0644 /etc/cron.d/supla-cron

###
# Production build.
###
FROM supla_cloud_base AS supla_cloud_prod
ENV CLOUD_VERSION=2.3.17
#COPY supla-cloud.tar.gz ./supla-cloud-v$CLOUD_VERSION.tar.gz

RUN a2ensite default-ssl \
    && wget -nc https://github.com/SUPLA/supla-cloud/releases/download/v${CLOUD_VERSION}/supla-cloud-v${CLOUD_VERSION}.tar.gz \
    && mkdir cloud \
    && tar -xzf supla-cloud-v${CLOUD_VERSION}.tar.gz -C cloud \
    && rm -f supla-cloud-v${CLOUD_VERSION}.tar.gz \
    && cp cloud/app/config/parameters.yml.dist cloud/app/config/parameters.yml \
    && sed -i "s+/var/run/supla/supla-server-ctrl.sock+/supla-server/supla-server-ctrl.sock+g" cloud/app/config/config.yml \
    && sed -i "s#database_host: 127.0.0.1#database_host: supla-db#" cloud/app/config/parameters.yml \
    && sed -i "s#database_user: root#database_user: supla#" cloud/app/config/parameters.yml \
    && chown -hR www-data:www-data cloud

WORKDIR /var/www/cloud

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY cloud-entrypoint.sh /usr/local/bin/docker-php-entrypoint

CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]


###
# Container for preparing SUPLA Cloud tar.
###
FROM supla_cloud_base AS supla_cloud_builder

RUN mkdir .npm && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && npm install -g npm@5 \
  && apt-get autoremove \
  && rm -r /var/lib/apt/lists/* \
  && apt-get clean \
  && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN git clone https://github.com/SUPLA/supla-cloud.git /var/www/supla-cloud \
  && git clone https://github.com/SUPLA/supla-core.git --branch master --single-branch /var/www/supla-core \
  && cd supla-cloud && git checkout develop && git checkout master \
  && cp app/config/parameters.yml.dist app/config/parameters.yml \
  && sed -i "s#supla_server: ~#supla_server: supla.local#" /var/www/supla-cloud/app/config/parameters.yml \
  && cd .. && chown -hR www-data:www-data .

WORKDIR /var/www/supla-cloud
