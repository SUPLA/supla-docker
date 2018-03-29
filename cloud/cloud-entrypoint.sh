#!/bin/sh
set -e

if [ ! -f /etc/apache2/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.crt -subj "/C=PL/ST=SUPLA/L=SUPLA/O=SUPLA/CN=SUPLA"
fi

sed -i "s+database_password: ~+database_password: ${DB_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}+g" app/config/parameters.yml
sed -i "s+secret: ThisTokenIsNotSoSecretChangeIt+secret: ${SECRET:-DEFAULT_SECRET_IS_BAD_IDEA}+g" app/config/parameters.yml
sed -i "s+supla_server: ~+supla_server: ${CLOUD_DOMAIN:-cloud.supla.org}+g" app/config/parameters.yml

sed -i "s+recaptcha_enabled: true+recaptcha_enabled: ${RECAPTCHA_ENABLED:-true}+g" app/config/parameters.yml
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

sed -i "s+supla_require_regulations_acceptance: false+supla_require_regulations_acceptance: ${REQUIRE_REGULATIONS_ACCEPTANCE:-false}+g" app/config/config.yml
sed -i "s+supla_require_cookie_policy_acceptance: false+supla_require_cookie_policy_acceptance: ${REQUIRE_COOKIE_POLICY_ACCEPTANCE:-false}+g" app/config/config.yml

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
