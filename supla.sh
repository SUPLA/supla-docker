#!/usr/bin/env bash

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$(expr substr $(dpkg --print-architecture) 1 3)" == "arm" ]; then
  echo -e "${RED}ARM architecture detected. Use the configuration from arm32v7 branch.${NC}"
  echo -e "${YELLOW}Run the following command and try again: git checkout arm32v7${NC}"
  exit
fi

if [ ! -f .env ]; then
  cp .env.sample .env
  DB_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
  SECRET="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
  sed -i "s+CHANGE_PASSWORD_BEFORE_FIRST_LAUNCH+$DB_PASSWORD+g" .env
  sed -i "s+CHANGE_SECRET_BEFORE_FIRST_LAUNCH+$SECRET+g" .env
  echo -e "${YELLOW}Sample configuration file has been generated for you.${NC}"
  echo -e "${YELLOW}Please check if the .env file matches your needs and run this command again.${NC}"
  exit
fi

source .env >/dev/null 2>&1

# remove \r at the end of the env, if exists
CONTAINER_NAME="$(echo -e "${COMPOSE_PROJECT_NAME}" | sed -e 's/\r$//')"

if [ "$1" = "start" ]; then
  echo -e "${GREEN}Starting SUPLA containers${NC}"
  docker-compose up --build -d && echo -e "${GREEN}SUPLA containers has been started.${NC}"

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
  BACKUP_FILE="$VOLUME_DATA/backups/supla$(date +"%m%d%Y%H%M%S").sql.gz"
  docker exec "$CONTAINER_NAME-db" mysqldump -u supla --password=$DB_PASSWORD supla > "$BACKUP_FILE" && \
  gzip "$BACKUP_FILE" && \
  echo -e "${GREEN}Database backup saved to $BACKUP_FILE${NC}" || \
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
