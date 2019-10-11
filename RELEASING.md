# SUPLA-Docker

This branch contains sources for docker containers. Do not build your production
server for this branch unless you have tried building from `master` already.

## Releasing a new version

1. Make sure everything that is going to be released is included in the `master` branch
   (supla-cloud and supla-core).
1. Tag new versions of the products according to the chosen flow (e.g. `v2.3.4`).
1. Wait for the Night Build to pick up the changes, or force it to build the new package with
   `./release-nightly.sh`. As soon as the [nightly.supla.org](https://nightly.supla.org) contains the
   appropriate version (pay attention to the footer), you may proceed.
1. If the Cloud has been updated:
    1. download the release package from [nightly.supla.org/supla-cloud-master.tar.gz](https://nightly.supla.org/supla-cloud-master.tar.gz),
    1. rename it to `supla-cloud-vVERSION.tar.gz`
    1. calcluate SHA1 checksum with `sha1sum supla-cloud-vVERSION.tar.gz > supla-cloud-vVERSION.tar.gz.sha1` 
    1. upload both `supla-cloud-vVERSION.tar.gz` and `supla-cloud-vVERSION.tar.gz.sha1` files to the
   [SUPLA Cloud latest release](https://github.com/SUPLA/supla-cloud/releases/latest).
1. Disable night build not to interfere with the update process with `touch nightly.lock`.
1. Revert the changes introduced by continuous deploy with `git checkout .`.
1. Update versions in `cloud/Dockerfile` and `server/Dockerfile` on `src` branch in this repo. Commit the changes to the `src` branch.
1. Publish the containers by executing the folowing commands on every supported architecture
   (being in `supla-docker` repo, `src` branch)
   ```
   git checkout .
   git pull
   docker login
   ./release.sh
   rm nightly.lock
   ```
