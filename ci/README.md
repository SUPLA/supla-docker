# CI images

This directory contains images for CI builds.

## SUPLA Cloud

### PHP 7.4

```sh
docker build -t supla/supla-cloud:ci-php7.4 -f supla-cloud-ci-php7.4.Dockerfile .
docker push supla/supla-cloud:ci-php7.4
```

### PHP 8.1

```sh
docker build -t supla/supla-cloud:ci-php8.1 -f supla-cloud-ci-php8.1.Dockerfile .
docker push supla/supla-cloud:ci-php8.1
```

### PHP 8.2

```sh
docker build -t supla/supla-cloud:ci-php8.2 -f supla-cloud-ci-php8.2.Dockerfile .
docker push supla/supla-cloud:ci-php8.2
```

### PHP 8.3

```sh
docker build -t supla/supla-cloud:ci-php8.3 -f supla-cloud-ci-php8.3.Dockerfile .
docker push supla/supla-cloud:ci-php8.3
```
