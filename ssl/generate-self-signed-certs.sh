#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
    export SUBJECT="//C=PL\ST=SUPLA\L=SUPLA\O=Dis\CN=SUPLA"
else
    export SUBJECT="/C=PL/ST=SUPLA/L=SUPLA/O=Dis/CN=SUPLA"
fi

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cloud/server.key -out cloud/server.crt -subj $SUBJECT
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server/private.key -out server/cert.crt -subj $SUBJECT
