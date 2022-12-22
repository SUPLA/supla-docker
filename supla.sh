#!/usr/bin/env bash

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f .env ]; then
  cp .env.default .env
  echo -e "${YELLOW}Sample configuration file is being generated for you.${NC}"
  DB_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
  if [ -z "$DB_PASSWORD" ]; then
    echo -e "${YELLOW}We could not generate passwords. Make sure to change the default DB_PASSWORD and SECRET.${NC}"
  else
    SECRET="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
    sed -i "s+CHANGE_PASSWORD_BEFORE_FIRST_LAUNCH+$DB_PASSWORD+g" .env
    sed -i "s+CHANGE_SECRET_BEFORE_FIRST_LAUNCH+$SECRET+g" .env
  fi
  if [ "$(uname -m)" == "armv6l" ]; then
    sed -i -r "s/COMPOSE_FILE=(.+)/COMPOSE_FILE=\1:docker-compose.arm32v6.yml/" .env
  elif [ "$(expr substr $(uname -m) 1 3)" == "arm" ]; then
    sed -i -r "s/COMPOSE_FILE=(.+)/COMPOSE_FILE=\1:docker-compose.arm32v7.yml/" .env
  elif [ "$(expr substr $(uname -m) 1 3)" == "aar" ]; then
    sed -i -r "s/COMPOSE_FILE=(.+)/COMPOSE_FILE=\1:docker-compose.aarch64.yml/" .env
  fi
  echo -e "${YELLOW}Please check if the .env file matches your needs and run this command again.${NC}"
  exit
fi

source .env >/dev/null 2>&1

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

elif [ "$1" = "backup" ]; then
  echo -e "${GREEN}Making database backup${NC}"
  mkdir -p "$VOLUME_DATA/backups"
  BACKUP_FILE="$VOLUME_DATA/backups/supla$(date +"%m%d%Y%H%M%S").sql"
  docker exec "$CONTAINER_NAME-db" mysqldump --routines -u supla --password=$DB_PASSWORD supla > "$BACKUP_FILE" && \
  gzip "$BACKUP_FILE" && \
  echo -e "${GREEN}Database backup saved to ${BACKUP_FILE}.gz${NC}" || \
  (echo -e "${RED}Could not create the database backup. Is the application started?${NC}" && false)

elif [ "$1" = "upgrade" ]; then
  "./$(basename "$0")" backup && \
  "./$(basename "$0")" stop && \
  docker-compose pull && \
  "./$(basename "$0")" start

elif [ "$1" = "create-confirmed-user" ]; then
  docker exec -it -u www-data "$CONTAINER_NAME-cloud" php bin/console supla:create-confirmed-user

else
  echo -e "${RED}Usage: $0 start|stop|restart|upgrade|backup|create-confirmed-user${NC}"

fi
