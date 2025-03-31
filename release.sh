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

CLOUD_VERSION=$(cat cloud/Dockerfile | grep "ENV CLOUD_VERSION=" | grep -oP "\d+\.\d+(\.\d+)?$")
SERVER_VERSION=$(cat server/Dockerfile | grep "ENV SERVER_VERSION=" | grep -oP "\d+\.\d+(\.\d+)?$")

echo -e "Releasing supla-cloud ${GREEN}${CLOUD_VERSION}${NC}"
echo -e "Releasing supla-server ${GREEN}${SERVER_VERSION}${NC}"
echo -e "${YELLOW}If you made a mistake, it's a good time to hit Ctrl+C${NC}"
echo "... waiting 10s"
sleep 10
echo ""

git checkout cloud
git checkout server
./supla.sh restart

sleep 5

docker buildx build --push --platform linux/arm/v7,linux/arm64,linux/amd64 --tag supla/supla-cloud:${CLOUD_VERSION} cloud
docker buildx build --push --platform linux/arm/v7,linux/arm64,linux/amd64 --tag supla/supla-cloud:latest cloud
docker buildx build --push --platform linux/arm/v7,linux/arm64,linux/amd64 --tag supla/supla-server:${SERVER_VERSION} server
docker buildx build --push --platform linux/arm/v7,linux/arm64,linux/amd64 --tag supla/supla-server:latest server

rm build.lock
