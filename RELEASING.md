# SUPLA-Docker

This branch contains sources for docker containers. Do not build your production
server for this branch unless you have tried building from `master` already.

## Releasing a new version

1. Make sure everything that is going to be released is included in the `master` branch
   (supla-cloud and supla-core).
2. Tag new versions of the products according to the chosen flow (e.g. `v2.3.4`).
3. If the Cloud has been updated:
    1. Release the Cloud with `./release.sh` script after cloning `supla-cloud` repo.
    1. upload both `supla-cloud-vVERSION.tar.gz` and `supla-cloud-vVERSION.tar.gz.sha1` files to the
   [SUPLA Cloud latest release](https://github.com/SUPLA/supla-cloud/releases/latest).
4. Disable night build not to interfere with the update process with `touch nightly.lock`.
5. Revert the changes introduced by continuous deploy with `git checkout .`.
6. Update versions in `cloud/Dockerfile` and `server/Dockerfile` on `src` branch in this repo. Commit the changes to the `src` branch.
7. Publish the containers by executing the folowing commands on every supported architecture
   (being in `supla-docker` repo, `src` branch)
   ```
   git checkout .
   git pull
   docker login
   ./release.sh
   rm nightly.lock
   ```

## Deploying a preview version to the nightly

1. Build a release package locally with
    ```
    RELEASE_VERSION=2.4.0-preview.1 composer run-script release-dev
    ```
1. Copy the resulting tar to the nightly host to the `cloud/supla.tar.gz`.
1. Disable night build not to interfere with the preview process with `touch nightly.lock`.
1. Rebuild the `supla-cloud` container
    ```
    docker-compose up --build -d supla-cloud
    ```
1. Optionally, load fixtures
    ```
    docker exec -it -u www-data supla-cloud php bin/console supla:dev:dropAndLoadFixtures -e dev
    docker exec -it -u www-data supla-cloud php bin/console supla:user:change-limits user@supla.org 1000
    ```
    
## Turning on the maintenance mode in SUPLA Cloud

When SUPLA Cloud operates in maintenance mode, users are not allowed to make any modifications to 
their accounts configuration. User Interface displays appropriate warning.

In order to turn on the maintenance mode:

1. Open the `app/config/config_local.yml`.
1. Add `supla.maintenance_mode: true` setting and save changes.
1. Clear the cache with `php bin/console cache:clear`.

Then, perform the required maintenance and turn off the maintenance mode by setting the `supla.maintenance_mode`
to `false.
