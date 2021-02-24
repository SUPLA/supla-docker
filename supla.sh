#!/usr/bin/env bash

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f .env ]; then
  cp .env.default .env
  DB_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
  SECRET="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
  sed -i "s+CHANGE_PASSWORD_BEFORE_FIRST_LAUNCH+$DB_PASSWORD+g" .env
  sed -i "s+CHANGE_SECRET_BEFORE_FIRST_LAUNCH+$SECRET+g" .env
  echo -e "${YELLOW}Sample configuration file has been generated for you.${NC}"
  echo -e "${YELLOW}Please check if the .env file matches your needs and run this command again.${NC}"
  exit
fi

source .env >/dev/null 2>&1

if [ "MQTT_BROKER_ENABLED" = "true" ]; then
  if [ "$MQTT_BROKER_CLIENT_ID" = "" ]; then
    MQTT_BROKER_CLIENT_ID="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
    echo "MQTT_BROKER_CLIENT_ID=$MQTT_BROKER_CLIENT_ID" >> .env
    echo -e "${YELLOW}We have generateed random MQTT_BROKER_CLIENT_ID for you.${NC}"
  fi
fi

if [ "$(expr substr $(dpkg --print-architecture) 1 3)" == "arm" ]; then
  echo -e "${YELLOW}ARM architecture detected. Adjusting configuration.${NC}"
  sed -i "s#mysql:5.7.20#hypriot/rpi-mysql:5.5#g" docker-compose.yml
fi

# remove \r at the end of the env, if exists
CONTAINER_NAME="$(echo -e "${COMPOSE_PROJECT_NAME}" | sed -e 's/\r$//')"

if [ "$1" = "start" ]; then
  echo -e "${GREEN}Starting SUPLA containers${NC}" && \
  docker-compose up --build -d && \
  echo -e "${GREEN}SUPLA containers has been started.${NC}"

elif [ "$1" = "stop" ]; then
  echo -e "${GREEN}Stopping SUPLA containers${NC}"
  docker-compose stop && echo -e "${GREEN}SUPLA containers has been stopped.${NC}"

elif [ "$1" = "restart" ]; then
  "./$(basename "$0")" stop
  sleep 1
  "./$(basename "$0")" start

elif [ "$1" = "create-confirmed-user" ]; then
  docker exec -it -u www-data "$CONTAINER_NAME-cloud" php bin/console supla:create-confirmed-user

else
  echo -e "${RED}Usage: $0 start|stop|restart|create-confirmed-user${NC}"

fi
