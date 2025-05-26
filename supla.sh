#!/usr/bin/env bash

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if docker compose version >/dev/null 2>&1; then
  DOCKER_COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DOCKER_COMPOSE="docker-compose"
else
  echo -e "${RED}Neither docker-compose nor docker compose found. Please install Docker with docker compose plugin.${NC}"
  exit 1
fi

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
  echo -e "${YELLOW}Please check if the .env file matches your needs and run this command again.${NC}"
  exit
fi

source .env >/dev/null 2>&1
DB_IMAGE_MISSING=0

if [ -z "$DB_IMAGE" ]; then
  export DB_IMAGE="mysql:5.7.20"
  DB_IMAGE_MISSING=1
fi

if [ "$DB_IMAGE" = "mysql:5.7.20" ]; then
  echo -e "${YELLOW}[WARN] Using the outdated MySQL image 5.7.20.${NC}"
  echo -e "${YELLOW}[WARN] Please consider upgrading your SUPLA stack.${NC}"
  echo -e "${YELLOW}[WARN] The support for current configuration will be dropped at the end of August 2025.${NC}"
  echo -e "${YELLOW}[WARN] See https://github.com/SUPLA/supla-docker/wiki/Docker-stack-upgrade-2025 for more information.${NC}"
  if [ "$(expr substr $(dpkg --print-architecture) 1 3)" == "arm" ]; then
    echo -e "${YELLOW}[WARN] You are using the ARM x32 architecture.${NC}"
    echo -e "${YELLOW}[WARN] Please consider using the x64 OS on your device.${NC}"
    echo -e "${YELLOW}[WARN] Support for ARM x32 will be dropped at the end of December 2025.${NC}"
    echo -e "${YELLOW}[WARN] See https://github.com/SUPLA/supla-docker/wiki/Docker-stack-upgrade-2025 for more information.${NC}"
    export DB_IMAGE="hypriot/rpi-mysql:5.5"
  fi
fi

if [ "$DB_IMAGE_MISSING" = 1 ]; then
  echo "DB_IMAGE=$DB_IMAGE" >> .env
fi

if [ "${MAILER_HOST}" != "" ]; then
  echo -e "${YELLOW}[WARN] You are using deprecated e-mail configuration.${NC}"
  echo -e "${YELLOW}[WARN] Please use MAILER_DSN environment variable to configure it.${NC}"
  echo -e "${YELLOW}[WARN] See .env.default for examples.${NC}"
fi

# remove \r at the end of the env, if exists
CONTAINER_NAME="$(echo -e "${COMPOSE_PROJECT_NAME}" | sed -e 's/\r$//')"

if [ "$1" = "start" ]; then
  echo -e "${GREEN}Starting SUPLA containers${NC}" && \
  $DOCKER_COMPOSE up --build -d && \
  echo -e "${GREEN}SUPLA containers has been started.${NC}"

elif [ "$1" = "stop" ]; then
  echo -e "${GREEN}Stopping SUPLA containers${NC}"
  $DOCKER_COMPOSE stop && echo -e "${GREEN}SUPLA containers has been stopped.${NC}"

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
  $DOCKER_COMPOSE pull && \
  "./$(basename "$0")" start

elif [ "$1" = "create-confirmed-user" ]; then
  docker exec -it -u www-data "$CONTAINER_NAME-cloud" php bin/console supla:create-confirmed-user

else
  echo -e "${RED}Usage: $0 start|stop|restart|upgrade|backup|create-confirmed-user${NC}"

fi
