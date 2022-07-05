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

if [ -f "build.lock" ]; then
  echo -e "${RED}Another build in progress. Aborting.${NC}"
  exit 1
fi

if [ -f "nightly.lock" ]; then
  echo -e "${RED}Continuous deploy turned off. Aborting.${NC}"
  exit 1
fi

touch build.lock

if [[ "$1" != "" ]]; then
  echo -e "Building SUPLA Cloud from $1 branch."
else
  echo -e "Checking for new changes..."
fi

CLOUD_BRANCH=${1-develop}
CORE_BRANCH=master

if [ -d "var/repos/supla-cloud" ]; then
  git --git-dir var/repos/supla-cloud/.git --work-tree var/repos/supla-cloud checkout -f $CLOUD_BRANCH >/dev/null 2>&1
  LAST_CLOUD_VERSION=$(git --git-dir var/repos/supla-cloud/.git describe --tags $CLOUD_BRANCH | sed -e 's/\r$//')
else
  LAST_CLOUD_VERSION=""
  git clone https://github.com/SUPLA/supla-cloud.git --branch $CLOUD_BRANCH var/repos/supla-cloud
fi

if [ -d "var/repos/supla-core" ]; then
  LAST_CORE_VERSION=$(git --git-dir var/repos/supla-core/.git describe --tags origin/$CORE_BRANCH | sed -e 's/\r$//')
else
  LAST_CORE_VERSION=""
  git clone https://github.com/SUPLA/supla-core.git --branch $CORE_BRANCH var/repos/supla-core
fi

git --git-dir var/repos/supla-cloud/.git fetch >/dev/null 2>&1
CURRENT_CLOUD_VERSION=$(git --git-dir var/repos/supla-cloud/.git describe --tags origin/$CLOUD_BRANCH | sed -e 's/\r$//')
git --git-dir var/repos/supla-cloud/.git fetch >/dev/null 2>&1
CURRENT_CORE_VERSION=$(git --git-dir var/repos/supla-core/.git describe --tags origin/$CORE_BRANCH | sed -e 's/\r$//')

if [[ "$1" != "" ]]; then
  LAST_CLOUD_VERSION=""
  LAST_CORE_VERSION=""
fi

if [[ $LAST_CLOUD_VERSION != $CURRENT_CLOUD_VERSION ]]; then
    rm -f var/repos/supla-cloud/*.tar.gz
    rm -f var/repos/supla-cloud/*.sha1
    echo -e "${GREEN}Updating SUPLA Cloud from ${CLOUD_BRANCH} branch: ${LAST_CLOUD_VERSION} -> ${CURRENT_CLOUD_VERSION}${NC}" && \
    git --git-dir var/repos/supla-cloud/.git --work-tree var/repos/supla-cloud reset --hard origin/$CLOUD_BRANCH && \
    RELEASE_FILENAME=supla-cloud.tar.gz RELEASE_VERSION=$CURRENT_CLOUD_VERSION ./var/repos/supla-cloud/release.sh
    REBUILD=true
fi

if [[ $LAST_CORE_VERSION != $CURRENT_CORE_VERSION ]]; then
    echo -e "${GREEN}Updating Core from $CORE_BRANCH branch: ${LAST_CORE_VERSION} -> ${CURRENT_CORE_VERSION}${NC}" && \
    git --git-dir var/repos/supla-core/.git --work-tree var/repos/supla-core reset --hard origin/$CORE_BRANCH
    REBUILD=true
fi

if [ -z "$REBUILD" ]; then
  echo -e "${YELLOW}Nothing to update. Work faster.${NC}"
else
  if [ -f "var/repos/supla-cloud/supla-cloud.tar.gz" ]; then
    mv var/repos/supla-cloud/supla-cloud.tar.gz cloud/supla-cloud.tar.gz
    sed -i -r "s/^#(COPY supla-cloud.*\.tar\.gz)/\1/" cloud/Dockerfile
  fi
  sed -i -r "s/^(ENV SERVER_VERSION=).+/\1$CORE_BRANCH/" server/Dockerfile && \
  ./supla.sh restart && \
  sleep 5
  if [ -f "./release-posthook.sh" ]; then
    ./release-posthook.sh nightly
  fi
fi

rm build.lock
