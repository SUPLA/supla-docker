#!/usr/bin/env bash

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$(uname -m)" == "armv6l" ]; then
    ARCH=arm32v6
elif [ "$(uname -m)" == "armv7l" ]; then
    ARCH=arm32v7
else
    echo "${RED}Unsupported release architecture: $(uname -m)${NC}"
    exit
fi

CLOUD_VERSION=$(cat cloud/Dockerfile | grep "ENV CLOUD_VERSION=" | grep -oP "\d+\.\d+\.\d+$")
SERVER_VERSION=$(cat server/Dockerfile | grep "ENV SERVER_VERSION=" | grep -oP "\d+\.\d+\.\d+$")


echo "${GREEN}Releasing supla-cloud ${ARCH}${NC}-${CLOUD_VERSION}"
echo "${GREEN}Releasing supla-server ${ARCH}${NC}-${SERVER_VERSION}"
echo "${YELLOW}If you made a mistake, it's a good time to hit Ctrl+C${N}"
echo "... waiting 10s"
sleep 10
echo ""

./supla.sh restart

sleep 5

docker tag supla_supla-cloud "supla/supla-cloud:${ARCH}-${CLOUD_VERSION}"
docker tag supla_supla-cloud "supla/supla-cloud:${ARCH}"
docker tag supla_supla-server "supla/supla-server:${ARCH}-${SERVER_VERSION}"
docker tag supla_supla-server "supla/supla-server:${ARCH}"

docker push "supla/supla-cloud:${ARCH}-${CLOUD_VERSION}"
docker push "supla/supla-cloud:${ARCH}"
docker push "supla/supla-server:${ARCH}-${SERVER_VERSION}"
docker push "supla/supla-server:${ARCH}"
