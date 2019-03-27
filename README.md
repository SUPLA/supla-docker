# SUPLA-Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/supla/supla-cloud.svg)](https://hub.docker.com/r/supla/supla-cloud/) [![Docker Build Status](https://img.shields.io/docker/build/supla/supla-cloud.svg)](https://hub.docker.com/r/supla/supla-cloud/)
 
| SUPLA-Cloud        | SUPLA-Core           |
| ------------- |:-------------|
| [![Current Supla-Cloud version](https://img.shields.io/github/release/SUPLA/supla-cloud.svg)](https://github.com/SUPLA/supla-cloud/releases/latest) | [![Current SUPLA-Server version](https://img.shields.io/github/release/SUPLA/supla-core.svg)](https://github.com/SUPLA/supla-core/releases/latest) |

Your home connected. With Docker. www.supla.org

![SUPLA-Docker](https://github.com/SUPLA/supla-docker/raw/master/supla-docker.png)

## Installation (video)

[![SUPLA Installation Video](https://img.youtube.com/vi/MBgRUE_5dFU/0.jpg)](https://www.youtube.com/watch?v=MBgRUE_5dFU)

## Installation

1. Install [Docker CE](https://docs.docker.com/engine/installation/) 17.06+, [docker-compose](https://docs.docker.com/compose/install/) 1.17+ and Git.
   The following _should_ work (as root):
   ```
   apt-get -y install git curl
   curl -sSL https://get.docker.com | sh
   curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
   ```
   * if you have problems getting docker-compose into you Raspberry Pi, try an alternative method:
     ```
     apt-get -y install python-pip && pip install docker-compose
     ```
1. Clone this repository.
   ```
   git clone https://github.com/SUPLA/supla-docker.git
   ```
1. Generate sample config by running
   ```
   ./supla-docker/supla.sh
   ```
   Review the settings in `./supla-docker/.env` file.
1. Start SUPLA!
   ```
   ./supla-docker/supla.sh start
   ```
   
## Creating an user account
Before you launch the containers, set the `FIRST_USER_EMAIL` and `FIRST_USER_PASSWORD` settings in the `.env` file. 
The account will be automatically created for you. You can remove these settings afterwards not to expose your password.

If the containers are started already, you can create new user account interactively with:
```
./supla-docker/supla.sh create-confirmed-user
```

## Upgrading to the newest version
```
cd supla-docker
git pull
./supla.sh upgrade
```

## Launching in proxy mode

If you either
 * already have another dockerized application running on ports 80 or 443 or
 * do not own a valid SSL certificate for your domain but still wants your cloud instance to be accepted by the browsers
 
 then you should run the SUPLA containers in proxy mode. Here's how.
 
1. Execute all installation steps but the last one (do not start the application yet). If you have started it already, stop it with `./supla.sh stop`.
1. Clone and run the [docker-compose-letsencrypt-nginx-proxy-companion](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion#how-to-use-it) according to the instructions on their site. Clone it outside the `supla-docker` directory. An example desired directory structure is as follows:
    ```
    /some/apps/directory/
      supla-docker/
      docker-compose-letsencrypt-nginx-proxy-companion/
    ```
1. In the file `supla-docker/.env` find the following configuration
    ```
    COMPOSE_FILE=docker-compose.yml:docker-compose.standalone.yml
    ``` 
    and change it to 
    ```
    COMPOSE_FILE=docker-compose.yml:docker-compose.proxy.yml
    ```
1. In the file `supla-docker/.env` make sure that `CLOUD_DOMAIN` is valid domain name that should point to the SUPLA instance (can not be an IP address!) and the `ADMIN_EMAIL` is a correct e-mail address.
1. Start SUPLA!
   ```
   ./supla-docker/supla.sh start
   ```

If everything went smoothly, you should be able to access SUPLA Cloud by going to the configured domain name and it should introduce you a valid SSL certificate from [Let's Encrypt](https://letsencrypt.org/).

## Troubleshooting

### On any problems, check logs first
```
docker logs --since=5m supla-cloud
docker logs --since=5m supla-server
docker logs --since=5m supla-db
```
Moreover, if you are running in the proxy mode, you might also be interested in logs from the [proxy containers](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion/blob/master/.env.sample#L12-L14).

### Cannot start service supla-cloud: driver failed programming external connectivity on endpoint supla-cloud (***): Error starting userland proxy: listen tcp 0.0.0.0:443: bind: address already in use

It means that you have another application running on the port 80 or 443. You can either
* turn it off and try to launch SUPLA again or
* change the ports that supla-cloud container listens on in the .env file or
* try to run them both with proxy configuration described above.
