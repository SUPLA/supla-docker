#!/bin/sh
set -e

if [ ! -f /etc/apache2/ssl/server.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.crt -subj "/C=PL/ST=SUPLA/L=SUPLA/O=SUPLA/CN=SUPLA"
fi

PASSWORD=${DB_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}
SECRET=${SECRET:-DEFAULT_SECRET_IS_BAD_IDEA}
DOMAIN=${CLOUD_DOMAIN:-cloud.supla.org}

sed -i "s+database_password: ~+database_password: $PASSWORD+g" app/config/parameters.yml
sed -i "s+secret: ThisTokenIsNotSoSecretChangeIt+secret: $SECRET+g" app/config/parameters.yml
sed -i "s+supla_server: ~+supla_server: $DOMAIN+g" app/config/parameters.yml
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
