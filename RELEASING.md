# SUPLA-Docker

This branch contains sources for docker containers. Do not build your production
server for this branch unless you have tried building from `master` already.

## Releasing new version

1. Make sure everything that is going to be released is included in the `master` branch
   (supla-cloud and supla-core).
1. Tag new versions of the products according to the chosen flow (e.g. `v2.3.4`).
1. Wait for the Night Build to pick up the changes, or force it to build the new package with
   `./release-nightly.sh`. If [nightly.supla.org](https://nightly.supla.org) contains the
   appropriate version (pay attention to the footer), you may proceed.
1. Download the release package from [nightly.supla.org/supla-cloud-master.tar.gz](https://nightly.supla.org/supla-cloud-master.tar.gz),
   rename it to `supla-cloud-vVERSION.tar.gz` and upload it to the 
   [SUPLA Cloud latest release](https://github.com/SUPLA/supla-cloud/releases/latest).
1. Update versions in `cloud/Dockerfile` and `server/Dockerfile` on `src` branch in this repo.
1. Publish the containers by executing the folowing commands on every supported architecture
   (being in `supla-docker` repo, `src` branch)
   ```
   git checkout .
   git pull
   docker login
   ./release.sh
   ```
