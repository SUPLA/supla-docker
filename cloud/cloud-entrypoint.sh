#!/bin/sh
set -e

PASSWORD=${DB_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}
SECRET=${SECRET:-DEFAULT_SECRET_IS_BAD_IDEA}

sed -i "s+database_password: ~+database_password: $PASSWORD+g" app/config/parameters.yml
sed -i "s+secret: ThisTokenIsNotSoSecretChangeIt+secret: $SECRET+g" app/config/parameters.yml
rm -fr var/cache/*
php bin/console supla:initialize
php bin/console cache:warmup

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
