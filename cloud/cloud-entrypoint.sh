#!/bin/sh
set -e

if [ ! -f /etc/apache2/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.crt -subj "/C=PL/ST=SUPLA/L=SUPLA/O=SUPLA/CN=SUPLA"
fi

sed -i "s+database_host: 127.0.0.1+database_host: ${DB_HOST:-supla-db}+g" app/config/parameters.yml
sed -i "s+database_port: null+database_port: ${DB_PORT:-null}+g" app/config/parameters.yml
sed -i "s+database_name: supla+database_name: ${DB_NAME:-supla}+g" app/config/parameters.yml
sed -i "s+database_user: root+database_user: ${DB_USER:-supla}+g" app/config/parameters.yml
sed -i "s+database_password: ~+database_password: ${DB_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}+g" app/config/parameters.yml

sed -i "s+secret: ThisTokenIsNotSoSecretChangeIt+secret: ${SECRET:-DEFAULT_SECRET_IS_BAD_IDEA}+g" app/config/parameters.yml
sed -i "s+supla_server: ~+supla_server: ${CLOUD_DOMAIN:-cloud.supla.org}+g" app/config/parameters.yml

sed -i "s+recaptcha_enabled: false+recaptcha_enabled: ${RECAPTCHA_ENABLED:-false}+g" app/config/parameters.yml
sed -i "s+recaptcha_site_key: ~+recaptcha_site_key: ${RECAPTCHA_PUBLIC_KEY:-~}+g" app/config/parameters.yml
sed -i "s+recaptcha_secret: ~+recaptcha_secret: ${RECAPTCHA_PRIVATE_KEY:-~}+g" app/config/parameters.yml

sed -i "s+mailer_host: 127.0.0.1+mailer_host: ${MAILER_HOST:-127.0.0.1}+g" app/config/parameters.yml
sed -i "s+mailer_user: ~+mailer_user: ${MAILER_USER:-~}+g" app/config/parameters.yml
sed -i "s+mailer_password: ~+mailer_password: ${MAILER_PASSWORD:-~}+g" app/config/parameters.yml
sed -i "s+mailer_port: 465+mailer_port: ${MAILER_PORT:-25}+g" app/config/parameters.yml
sed -i "s+mailer_encryption: ssl+mailer_encryption: ${MAILER_ENCRYPTION:-~}+g" app/config/parameters.yml
sed -i "s+mailer_from: ~+mailer_from: ${MAILER_FROM:-~}+g" app/config/parameters.yml
sed -i "s+admin_email: ~+admin_email: ${ADMIN_EMAIL:-~}+g" app/config/parameters.yml
sed -i "s+supla_protocol: https+supla_protocol: ${SUPLA_PROTOCOL:-https}+g" app/config/config.yml
sed -E -i "s@supla_url: '(.+)'@supla_url: '${SUPLA_URL:-\1}'@g" app/config/config.yml
sed -i "s+accounts_registration_enabled: true+accounts_registration_enabled: ${ACCOUNTS_REGISTRATION_ENABLED:-true}+g" app/config/config.yml

sed -i "s+supla_require_regulations_acceptance: false+supla_require_regulations_acceptance: ${REQUIRE_REGULATIONS_ACCEPTANCE:-false}+g" app/config/parameters.yml
sed -i "s+supla_require_cookie_policy_acceptance: false+supla_require_cookie_policy_acceptance: ${REQUIRE_COOKIE_POLICY_ACCEPTANCE:-false}+g" app/config/parameters.yml
sed -i "s+brute_force_auth_prevention_enabled: true+brute_force_auth_prevention_enabled: ${BRUTE_FORCE_AUTH_PREVENTION_ENABLED:-true}+g" app/config/parameters.yml

if ! grep -q mqtt app/config/config_build.yml; then
  echo "    mqtt_broker:
        enabled: ${MQTT_BROKER_ENABLED:-false}
        host: ${MQTT_BROKER_HOST:-~}
        integrated_auth: ${MQTT_BROKER_INTEGRATED_AUTH:-false}
        protocol: ${MQTT_BROKER_PROTOCOL:-mqtt}
        port: ${MQTT_BROKER_PORT:-8883}
        tls: ${MQTT_BROKER_TLS:-true}
        username: '${MQTT_BROKER_USERNAME:-}'
        password: '${MQTT_BROKER_PASSWORD:-}'
" >> app/config/config_build.yml
fi

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
