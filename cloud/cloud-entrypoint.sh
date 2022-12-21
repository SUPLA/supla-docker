#!/bin/sh
set -e

if [ ! -f /etc/apache2/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.crt -subj "/C=PL/ST=SUPLA/L=SUPLA/O=SUPLA/CN=SUPLA"
fi

echo "
parameters:
  database_driver: pdo_mysql
  database_host: ${DB_HOST:-supla-db}
  database_port: ${DB_PORT:-null}
  database_name: ${DB_NAME:-supla}
  database_user: ${DB_USER:-supla}
  database_password: ${DB_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}
  mailer_transport: smtp
  mailer_host: ${MAILER_HOST:-127.0.0.1}
  mailer_user: ${MAILER_USER:-~}
  mailer_password: ${MAILER_PASSWORD:-~}
  mailer_port: ${MAILER_PORT:-25}
  mailer_encryption: ${MAILER_ENCRYPTION:-~}
  mailer_from: ${MAILER_FROM:-~}
  admin_email: ${ADMIN_EMAIL:-~}
  supla_server: ${CLOUD_DOMAIN:-cloud.supla.org}
  supla_require_regulations_acceptance: ${REQUIRE_REGULATIONS_ACCEPTANCE:-false}
  supla_require_cookie_policy_acceptance: ${REQUIRE_COOKIE_POLICY_ACCEPTANCE:-false}
  brute_force_auth_prevention_enabled: ${BRUTE_FORCE_AUTH_PREVENTION_ENABLED:-true}
  recaptcha_enabled: ${RECAPTCHA_ENABLED:-false}
  recaptcha_site_key: ${RECAPTCHA_PUBLIC_KEY:-~}
  recaptcha_secret: ${RECAPTCHA_PRIVATE_KEY:-~}
  locale: en
  secret: ${SECRET:-DEFAULT_SECRET_IS_BAD_IDEA}
  cors_allow_origin_regex:
    - supla2.+
    - localhost.+
" > app/config/parameters.yml

sed -E -i "s@supla_url: '(.+)'@supla_url: '${SUPLA_URL:-\1}'@g" app/config/config.yml

echo "
supla:
  accounts_registration_enabled: ${ACCOUNTS_REGISTRATION_ENABLED:-true}
  measurement_logs_retention:
    em_voltage_aberrations: ${MEASUREMENT_LOGS_RETENTION_EM_VOLTAGE_ABERRATIONS:-1000}
  mqtt_broker:
    enabled: ${MQTT_BROKER_ENABLED:-false}
    host: ${MQTT_BROKER_HOST:-~}
    integrated_auth: ${MQTT_BROKER_INTEGRATED_AUTH:-false}
    protocol: ${MQTT_BROKER_PROTOCOL:-mqtt}
    port: ${MQTT_BROKER_PORT:-8883}
    tls: ${MQTT_BROKER_TLS:-true}
    username: '${MQTT_BROKER_USERNAME:-}'
    password: '${MQTT_BROKER_PASSWORD:-}'
parameters:
  supla_protocol: ${SUPLA_PROTOCOL:-https}
" > app/config/config_docker.yml

# Copy local configuration file if exists
if [ -f var/local/config_local.yml ]; then
  cp var/local/config_local.yml app/config/config_local.yml
  chown www-data:www-data app/config/config_local.yml
fi

if [ ${SUPLA_PROTOCOL:-https} = "https" ]; then
  if ! grep -q "%{HTTPS} off" web/.htaccess; then
    { \
      echo 'RewriteCond %{HTTPS} off'; \
      echo 'RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]'; \
      cat web/.htaccess; \
    } > web/.htaccess-tmp
    rm web/.htaccess
    mv web/.htaccess-tmp web/.htaccess
  fi
fi

rm -fr var/cache/*
php bin/console supla:initialize
php bin/console cache:warmup
chown -hR www-data:www-data var
php bin/console supla:create-confirmed-user $FIRST_USER_EMAIL $FIRST_USER_PASSWORD --no-interaction --if-not-exists

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
