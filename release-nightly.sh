#!/usr/bin/env bash

###
# This script releases night build, i.e. https://nightly.supla.org.
# It WILL UPDATE the working supla-cloud and supla-server containers with the newest SUPLA Cloud (may be unstable!).
###

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -f "./build.lock" ]; then
  echo -e "${RED}Another build in progress. Aborting.${NC}"
  exit 1
fi

touch build.lock

echo -e "Checking for new changes..."

docker-compose up --build -d supla-cloud-builder >/dev/null 2>&1

sleep 5

update_nightly () {
  docker cp supla-cloud-builder:/var/www/supla-cloud/supla-cloud.tar.gz cloud/supla-cloud.tar.gz
  sed -i -r "s/^#(COPY supla-cloud.*\.tar\.gz)/\1/" cloud/Dockerfile
  sed -i -r "s/^(ENV SERVER_VERSION=).+/\1master/" server/Dockerfile
  sed -i -r "s/^(ENV SERVER_VERSION=).+/\1master/" server/Dockerfile
  ./supla.sh restart && \
  sleep 5
}

docker exec -u www-data supla-cloud-builder git fetch
LAST_MASTER_VERSION=$(docker exec -it -u www-data supla-cloud-builder git describe --tags master)
CURRENT_MASTER_VERSION=$(docker exec -it -u www-data supla-cloud-builder git describe --tags origin/master)

LAST_DEVELOP_VERSION=$(docker exec -it -u www-data supla-cloud-builder git describe --tags develop)
CURRENT_DEVELOP_VERSION=$(docker exec -it -u www-data supla-cloud-builder git describe --tags origin/develop)

if [ $LAST_MASTER_VERSION != $CURRENT_MASTER_VERSION ]; then
    echo -e "${GREEN}Updating from master branch: ${LAST_MASTER_VERSION} -> ${CURRENT_MASTER_VERSION}${NC}" && \
    docker exec -u www-data supla-cloud-builder git checkout -f master && \
    docker exec -u www-data supla-cloud-builder git pull && \
    docker exec -u www-data supla-cloud-builder git fetch origin develop:develop && \
    docker exec -u www-data --env RELEASE_FILENAME=supla-cloud.tar.gz supla-cloud-builder composer run-script release && \
    update_nightly && \
    docker cp cloud/supla-cloud.tar.gz supla-cloud:/var/www/cloud/web/supla-cloud-master.tar.gz
elif [ $LAST_DEVELOP_VERSION != $CURRENT_DEVELOP_VERSION ]; then
    echo -e "${GREEN}Updating from develop branch: ${LAST_DEVELOP_VERSION} -> ${CURRENT_DEVELOP_VERSION}${NC}" && \
    docker exec -u www-data supla-cloud-builder git checkout -f develop && \
    docker exec -u www-data supla-cloud-builder git pull && \
    docker exec -u www-data --env RELEASE_FILENAME=supla-cloud.tar.gz --env RELEASE_VERSION=$CURRENT_DEVELOP_VERSION supla-cloud-builder composer run-script release && \
    update_nightly && \
    docker cp cloud/supla-cloud.tar.gz supla-cloud:/var/www/cloud/web/supla-cloud-develop.tar.gz
else
    echo -e "${YELLOW}Nothing to update. Work faster.${NC}"
fi

docker-compose stop supla-cloud-builder
rm build.lock
