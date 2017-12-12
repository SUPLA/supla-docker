#!/bin/sh
set -e

PASSWORD=${DB_PASSWORD:-DEFAULT_PASSWORD_IS_BAD_IDEA}
sed -i "s+DEFAULT_PASSWORD_IS_BAD_IDEA+$PASSWORD+g" /etc/supla-server/supla.cfg

exec "$@"
