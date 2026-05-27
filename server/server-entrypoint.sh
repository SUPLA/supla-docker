#!/bin/sh
set -e

cp /etc/supla-server/supla.cfg.initial /etc/supla-server/supla.cfg

CLOUD_URL=${SUPLA_PROTOCOL:-https}://${CLOUD_DOMAIN:-cloud.supla.org}

sed -i "s+url=https://cloud.supla.org+url=$CLOUD_URL+g" /etc/supla-server/supla.cfg


ENV_MAPPINGS="
MQTT_BROKER_ENABLED:SUPLA_MQTT_BROKER_ENABLED
MQTT_BROKER_HOST:SUPLA_MQTT_BROKER_HOST
MQTT_BROKER_PORT:SUPLA_MQTT_BROKER_PORT
MQTT_BROKER_TLS:SUPLA_MQTT_BROKER_TLS
MQTT_BROKER_USERNAME:SUPLA_MQTT_BROKER_USERNAME
MQTT_BROKER_PASSWORD:SUPLA_MQTT_BROKER_PASSWORD
MQTT_BROKER_CLIENT_ID:SUPLA_MQTT_BROKER_CLIENT_ID
"

for mapping in $ENV_MAPPINGS; do
  old_name=$(echo "$mapping" | cut -d: -f1)
  new_name=$(echo "$mapping" | cut -d: -f2)

  eval old_value=\$${old_name}
  eval new_value=\$${new_name}

  if [ "${old_value}" != "" ]; then
    if [ "${new_value}" != "" ]; then
      echo "[WARN] Both ${old_name} and ${new_name} are set. Using ${new_name} and ignoring ${old_name}."
    else
      echo "[WARN] You are using deprecated ${old_name} environment variable. Please use ${new_name} instead."
      export ${new_name}="${old_value}"
    fi
  fi
done

echo "
[MySQL]
host=${DATABASE_HOST:-supla-db}
port=${DATABASE_PORT:-3306}
database=${DATABASE_NAME:-supla}
user=${DATABASE_USER:-supla}
password=${DATABASE_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}
" >> /etc/supla-server/supla.cfg


SUPLA_MQTT_BROKER_ENABLED_01=$([ "${SUPLA_MQTT_BROKER_ENABLED:-false}" = "true" ] && echo "1" || echo "0")
SUPLA_MQTT_BROKER_TLS_01=$([ "${SUPLA_MQTT_BROKER_TLS:-false}" = "true" ] && echo "1" || echo "0")

echo "
[MQTT-BROKER]
enabled=${SUPLA_MQTT_BROKER_ENABLED_01}
host=${SUPLA_MQTT_BROKER_HOST:-}
port=${SUPLA_MQTT_BROKER_PORT:-8883}
ssl=${SUPLA_MQTT_BROKER_TLS_01}
username=${SUPLA_MQTT_BROKER_USERNAME:-}
password=${SUPLA_MQTT_BROKER_PASSWORD:-}
client_id=${SUPLA_MQTT_BROKER_CLIENT_ID:-}
" >> /etc/supla-server/supla.cfg

if [ ! -f /etc/supla-server/ssl/cert.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/supla-server/ssl/private.key -out /etc/supla-server/ssl/cert.crt -subj "/C=PL/ST=SUPLA/L=SUPLA/O=SUPLA/CN=SUPLA"
fi

exec "$@"
