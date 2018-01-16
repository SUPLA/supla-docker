# SUPLA-Docker

This branch contains sources for docker containers. Do not build your production
server for this branch unless you have tried building from `master` already.

## Publishing do Docker Hub
After new SUPLA Cloud or SUPLA Server release, a SUPLA Team member
should bump the version number in appropriate `Dockerfile` and build the
containers on target device. 

The `x86` architecture can be built directly on Docker Hub (you need to
trigger the build after updating the `Dockerfile`s manually in GUI).

Other architectures need to be built manually on target platforms and pushed
to Docker Hub.

We always maintain a `latest` tag and a specific `arhcitecture-version` tags.

Example commands that can be used to pushed built containers to Docker hub:

```
docker login
docker tag supla_supla-cloud supla/supla-cloud:arm32v7
docker push supla/supla-cloud:arm32v7
docker tag supla_supla-cloud supla/supla-cloud:arm32v7-2.1.6
docker push supla/supla-cloud:arm32v7-2.1.6
```
