#!/bin/sh
set -e

cp /etc/supla-server/supla.cfg.initial /etc/supla-server/supla.cfg

CLOUD_URL=${SUPLA_PROTOCOL:-https}://${CLOUD_DOMAIN:-cloud.supla.org}

sed -i "s+url=https://cloud.supla.org+url=$CLOUD_URL+g" /etc/supla-server/supla.cfg


echo "
[MySQL]
host=${DB_HOST:-supla-db}
port=${DB_PORT:-3306}
database=${DB_NAME:-supla}
user=${DB_USER:-supla}
password=${DB_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}
" >> /etc/supla-server/supla.cfg


MQTT_BROKER_ENABLED_01=$([ "${MQTT_BROKER_ENABLED:-false}" = "true" ] && echo "1" || echo "0")
MQTT_BROKER_TLS_01=$([ "${MQTT_BROKER_TLS:-false}" = "true" ] && echo "1" || echo "0")

echo "
[MQTT-BROKER]
enabled=${MQTT_BROKER_ENABLED_01}
host=${MQTT_BROKER_HOST:-}
port=${MQTT_BROKER_PORT:-8883}
ssl=${MQTT_BROKER_TLS_01}
username=${MQTT_BROKER_USERNAME:-}
password=${MQTT_BROKER_PASSWORD:-}
client_id=${MQTT_BROKER_CLIENT_ID:-}
" >> /etc/supla-server/supla.cfg

if [ ! -f /etc/supla-server/ssl/cert.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/supla-server/ssl/private.key -out /etc/supla-server/ssl/cert.crt -subj "/C=PL/ST=SUPLA/L=SUPLA/O=SUPLA/CN=SUPLA"
fi

exec "$@"
