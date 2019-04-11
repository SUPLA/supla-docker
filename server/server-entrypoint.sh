#!/bin/sh
set -e

PASSWORD=${DB_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}
CLOUD_URL=${SUPLA_PROTOCOL:-https}://${CLOUD_DOMAIN:-cloud.supla.org}

sed -i "s+DEFAULT_PASSWORD_IS_BAD_IDEA+$PASSWORD+g" /etc/supla-server/supla.cfg
sed -i "s+url=https://cloud.supla.org+url=$CLOUD_URL+g" /etc/supla-server/supla.cfg

if [ ! -f /etc/supla-server/ssl/cert.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/supla-server/ssl/private.key -out /etc/supla-server/ssl/cert.crt -subj "/C=PL/ST=SUPLA/L=SUPLA/O=SUPLA/CN=SUPLA"
fi

exec "$@"
