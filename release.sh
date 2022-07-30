#!/usr/bin/env bash

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

if [ "$(uname -m)" == "armv6l" ]; then
    ARCH=arm32v6-
    LATEST_TAG=arm32v6
elif [ "$(uname -m)" == "armv7l" ]; then
    ARCH=arm32v7-
    LATEST_TAG=arm32v7
elif [ "$(uname -m)" == "x86_64" ]; then
    ARCH=
    LATEST_TAG=latest
else
    echo -e "${RED}Unsupported release architecture: $(uname -m)${NC}"
    exit
fi

CLOUD_VERSION=$(cat cloud/Dockerfile | grep "ENV CLOUD_VERSION=" | grep -oP "\d+\.\d+$")
SERVER_VERSION=$(cat server/Dockerfile | grep "ENV SERVER_VERSION=" | grep -oP "\d+\.\d+$")

echo -e "Releasing supla-cloud ${GREEN}${ARCH}${CLOUD_VERSION}${NC}"
echo -e "Releasing supla-server ${GREEN}${ARCH}${SERVER_VERSION}${NC}"
echo -e "${YELLOW}If you made a mistake, it's a good time to hit Ctrl+C${NC}"
echo "... waiting 10s"
sleep 10
echo ""

git checkout cloud
git checkout server
./supla.sh restart

sleep 5

docker tag supla_supla-cloud "supla/supla-cloud:${ARCH}${CLOUD_VERSION}"
docker tag supla_supla-cloud "supla/supla-cloud:${LATEST_TAG}"
docker tag supla_supla-server "supla/supla-server:${ARCH}${SERVER_VERSION}"
docker tag supla_supla-server "supla/supla-server:${LATEST_TAG}"

docker push "supla/supla-cloud:${ARCH}${CLOUD_VERSION}"
docker push "supla/supla-cloud:${LATEST_TAG}"
docker push "supla/supla-server:${ARCH}${SERVER_VERSION}"
docker push "supla/supla-server:${LATEST_TAG}"

rm build.lock
