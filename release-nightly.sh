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

if [ -f "./nightly.lock" ]; then
  echo -e "${RED}Continuous deploy turned off. Aborting.${NC}"
  exit 1
fi

touch build.lock

echo -e "Checking for new changes..."

docker-compose up --build -d supla-cloud-builder >/dev/null 2>&1

sleep 5

docker exec -u www-data supla-cloud-builder git fetch
docker exec -u www-data -w /var/www/supla-core supla-cloud-builder git fetch

LAST_MASTER_VERSION=$(docker exec -u www-data supla-cloud-builder git describe --tags master | sed -e 's/\r$//')
CURRENT_MASTER_VERSION=$(docker exec -u www-data supla-cloud-builder git describe --tags origin/master | sed -e 's/\r$//')

LAST_DEVELOP_VERSION=$(docker exec -u www-data supla-cloud-builder git describe --tags develop | sed -e 's/\r$//')
CURRENT_DEVELOP_VERSION=$(docker exec -u www-data supla-cloud-builder git describe --tags origin/develop | sed -e 's/\r$//')

LAST_CORE_VERSION=$(docker exec -u www-data -w /var/www/supla-core supla-cloud-builder git describe --tags master | sed -e 's/\r$//')
CURRENT_CORE_VERSION=$(docker exec -u www-data -w /var/www/supla-core supla-cloud-builder git describe --tags origin/master | sed -e 's/\r$//')

BRANCH=$1
if [[ $BRANCH = "master" ]]; then
  LAST_MASTER_VERSION="force-update"
elif [[ $BRANCH = "develop" ]]; then
  LAST_DEVELOP_VERSION="force-update"
fi

if [ $LAST_MASTER_VERSION != $CURRENT_MASTER_VERSION ]; then
    echo -e "${GREEN}Updating Cloud from master branch: ${LAST_MASTER_VERSION} -> ${CURRENT_MASTER_VERSION}${NC}" && \
    docker exec -u www-data supla-cloud-builder git checkout -f master && \
    docker exec -u www-data supla-cloud-builder git pull && \
    docker exec -u www-data supla-cloud-builder git fetch origin develop:develop && \
    docker exec -u www-data --env RELEASE_FILENAME=supla-cloud.tar.gz supla-cloud-builder composer run-script release && \
    REBUILD=true
    CLOUD_PACKAGE_NAME=supla-cloud-master.tar.gz
elif [ $LAST_DEVELOP_VERSION != $CURRENT_DEVELOP_VERSION ]; then
    echo -e "${GREEN}Updating Cloud from develop branch: ${LAST_DEVELOP_VERSION} -> ${CURRENT_DEVELOP_VERSION}${NC}" && \
    docker exec -u www-data supla-cloud-builder git checkout -f develop && \
    docker exec -u www-data supla-cloud-builder git pull && \
    docker exec -u www-data --env RELEASE_FILENAME=supla-cloud.tar.gz --env RELEASE_VERSION=$CURRENT_DEVELOP_VERSION supla-cloud-builder composer run-script release && \
    docker cp cloud/supla-cloud.tar.gz supla-cloud:/var/www/cloud/web/supla-cloud-develop.tar.gz
    REBUILD=true
    CLOUD_PACKAGE_NAME=supla-cloud-develop.tar.gz
fi

if [ $LAST_CORE_VERSION != $CURRENT_CORE_VERSION ]; then
    echo -e "${GREEN}Updating Core from master branch: ${LAST_CORE_VERSION} -> ${CURRENT_CORE_VERSION}${NC}" && \
    docker exec -u www-data -w /var/www/supla-core supla-cloud-builder git pull && \
    REBUILD=true
fi

if [ -z "$REBUILD" ]; then
  echo -e "${YELLOW}Nothing to update. Work faster.${NC}"
else
  docker cp supla-cloud-builder:/var/www/supla-cloud/supla-cloud.tar.gz cloud/supla-cloud.tar.gz && \
  sed -i -r "s/^#(COPY supla-cloud.*\.tar\.gz)/\1/" cloud/Dockerfile && \
  sed -i -r "s/^(ENV SERVER_VERSION=).+/\1master/" server/Dockerfile && \
  sed -i -r "s/^(ENV SERVER_VERSION_MASTER=).+/\1${CURRENT_CORE_VERSION}/" server/Dockerfile && \
  sed -i -r "s/^#(ENV SERVER_VERSION_MASTER=)/\1/" server/Dockerfile && \
  ./supla.sh restart && \
  sleep 5
  if [ ! -z "$CLOUD_PACKAGE_NAME" ]; then
    docker cp cloud/supla-cloud.tar.gz supla-cloud:/var/www/cloud/web/$CLOUD_PACKAGE_NAME
  fi
  if [ -f "./release-posthook.sh" ]; then
    ./release-posthook.sh nightly
  fi
fi

docker-compose stop supla-cloud-builder >/dev/null 2>&1
rm build.lock
