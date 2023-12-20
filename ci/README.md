# CI images

This directory contains images for CI builds.

## SUPLA Cloud

### PHP 7.4

```
docker build -t supla/supla-cloud:ci-php7.4 -f supla-cloud-ci-php7.4.Dockerfile .
docker push supla/supla-cloud:ci-php7.4
```
