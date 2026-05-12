#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if docker compose version >/dev/null 2>&1; then
  DOCKER_COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  DOCKER_COMPOSE=(docker-compose)
else
  echo -e "${RED}Neither docker compose nor docker-compose found. Please install Docker Compose.${NC}"
  exit 1
fi

docker_compose() {
  "${DOCKER_COMPOSE[@]}" "$@"
}

generate_secret() {
  tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$1"
}

ensure_env_file() {
  if [ ! -f .env ]; then
    cp .env.default .env

    DB_PASSWORD="$(generate_secret 32)"
    APP_SECRET="$(generate_secret 64)"

    sed -i "s+CHANGE_PASSWORD_BEFORE_FIRST_LAUNCH+$DB_PASSWORD+g" .env
    sed -i "s+CHANGE_SECRET_BEFORE_FIRST_LAUNCH+$APP_SECRET+g" .env

    echo -e "${YELLOW}Sample configuration file has been generated for you.${NC}"
    echo -e "${YELLOW}Please check if the .env file matches your needs and run this command again.${NC}"
    exit 0
  fi
}

load_env_file() {
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
}

validate_required_env() {
  if [ -z "${DATABASE_IMAGE:-}" ]; then
    echo -e "${RED}DATABASE_IMAGE is not set. Please define it in .env.${NC}"
    exit 1
  fi
}

prepare_env() {
  if [ -n "${MAILER_HOST:-}" ]; then
    echo -e "${YELLOW}[WARN] You are using deprecated e-mail configuration.${NC}"
    echo -e "${YELLOW}[WARN] Please use MAILER_DSN environment variable to configure it.${NC}"
    echo -e "${YELLOW}[WARN] See .env.default for examples.${NC}"
  fi
}

start() {
  echo -e "${GREEN}Starting SUPLA containers${NC}"
  docker_compose up --build -d
  echo -e "${GREEN}SUPLA containers have been started.${NC}"
}

stop() {
  echo -e "${GREEN}Stopping SUPLA containers${NC}"
  docker_compose stop
  echo -e "${GREEN}SUPLA containers have been stopped.${NC}"
}

restart() {
  stop
  sleep 1
  start
}

upgrade() {
  echo -e "${GREEN}Updating SUPLA containers${NC}"
  docker_compose build --pull
  docker_compose up -d --remove-orphans
  echo -e "${GREEN}SUPLA containers have been updated.${NC}"
}

create_confirmed_user() {
  docker_compose exec -u www-data supla-cloud php bin/console supla:create-confirmed-user
}

console() {
  shift
  docker_compose exec -u www-data supla-cloud php bin/console "$@"
}

usage() {
  echo -e "${RED}Usage: $0 start|stop|restart|update|create-confirmed-user${NC}"
}

ensure_env_file
load_env_file
validate_required_env
prepare_env

case "${1:-}" in
  start) start ;;
  stop) stop ;;
  restart) restart ;;
  upgrade) upgrade ;;
  console) console "$@" ;;
  create-confirmed-user) create_confirmed_user ;;
  *) usage; exit 1 ;;
esac
