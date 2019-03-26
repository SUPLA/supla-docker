#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ -f "./build.lock" ]; then
  echo "Another build in progress"
  exit 1
fi

touch build.lock

docker-compose up --build -d supla-cloud-builder

sleep 5

docker exec -it -u www-data -w /var/www/supla-cloud-master supla-cloud-builder git fetch
LAST_MASTER_VERSION=$(docker exec -it -u www-data -w /var/www/supla-cloud-master supla-cloud-builder git describe --tags master)
CURRENT_MASTER_VERSION=$(docker exec -it -u www-data -w /var/www/supla-cloud-master supla-cloud-builder git describe --tags origin/master)

LAST_DEVELOP_VERSION=$(docker exec -it -u www-data -w /var/www/supla-cloud-master supla-cloud-builder git describe --tags develop)
CURRENT_DEVELOP_VERSION=$(docker exec -it -u www-data -w /var/www/supla-cloud-master supla-cloud-builder git describe --tags origin/develop)

if [ $LAST_MASTER_VERSION != $CURRENT_MASTER_VERSION ]; then
    docker exec -it -u www-data supla-cloud-builder git checkout -f master
    docker exec -it -u www-data supla-cloud-builder git pull
    docker exec -it -u www-data supla-cloud-builder git fetch origin develop:develop
    docker exec -it -u www-data --env RELEASE_FILENAME=supla-cloud-master.tar.gz supla-cloud-builder composer run-script release
    docker cp supla-cloud-builder:/var/www/supla-cloud/supla-cloud-master.tar.gz cloud/supla-cloud-develop.tar.gz
    ./supla.sh restart
    sleep 5
    docker cp cloud/supla-cloud-develop.tar.gz supla-cloud:/var/www/cloud/web/supla-cloud-master.tar.gz
elif [ $LAST_DEVELOP_VERSION != $CURRENT_DEVELOP_VERSION ]; then
    docker exec -it -u www-data supla-cloud-builder git checkout -f develop
    docker exec -it -u www-data supla-cloud-builder git pull
    docker exec -it -u www-data --env RELEASE_FILENAME=supla-cloud-develop.tar.gz --env RELEASE_VERSION=$CURRENT_DEVELOP_VERSION supla-cloud-builder composer run-script release
    docker cp supla-cloud-builder:/var/www/supla-cloud/supla-cloud-develop.tar.gz cloud/supla-cloud-develop.tar.gz
    ./supla.sh restart
    sleep 5
    docker cp cloud/supla-cloud-develop.tar.gz supla-cloud:/var/www/cloud/web/supla-cloud-develop.tar.gz
fi

docker-compose stop supla-cloud-builder
rm build.lock
