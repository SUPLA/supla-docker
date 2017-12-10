#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "Could not read the .env configuration file."
  exit
fi

source .env >/dev/null 2>&1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# remove \r at the end of the env, if exists
CONTAINER_NAME="$(echo -e "${COMPOSE_PROJECT_NAME}" | sed -e 's/\r$//')"

if [ "$1" = "start" ]; then
  echo -e "${GREEN}Starting SUPLA containers${NC}"
  docker-compose up --build -d
  sleep 1
  docker exec -u www-data "$CONTAINER_NAME-cloud" rm -fr var/cache/*
  docker exec -u www-data "$CONTAINER_NAME-cloud" php bin/console doctrine:migrations:migrate --no-interaction
  docker exec -u www-data "$CONTAINER_NAME-cloud" php bin/console cache:warmup
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
