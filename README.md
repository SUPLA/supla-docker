# SUPLA-Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/supla/supla-cloud.svg)](https://hub.docker.com/r/supla/supla-cloud/) [![Docker Build Status](https://img.shields.io/docker/build/supla/supla-cloud.svg)](https://hub.docker.com/r/supla/supla-cloud/)
 
| SUPLA-Cloud        | SUPLA-Core           |
| ------------- |:-------------|
| [![Latest release](https://img.shields.io/github/release/SUPLA/supla-cloud.svg)](https://github.com/SUPLA/supla-cloud/releases/latest)  | [![Latest release](https://img.shields.io/github/release/SUPLA/supla-core.svg)](https://github.com/SUPLA/supla-core/releases/latest) |

Your home connected. With Docker. www.supla.org

![SUPLA-Docker](https://github.com/SUPLA/supla-docker/raw/master/supla-docker.png)

## Installation

1. Install [Docker CE](https://docs.docker.com/engine/installation/) 17.06+, [docker-compose](https://docs.docker.com/compose/install/) 1.17+ and Git.
   The following _should_ work (as root):
   ```
   apt-get -y install git
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
1. Start SUPLA!
   ```
   ./supla-docker/supla.sh start
   ```
   
## Creating an user account
```
./supla-docker/supla.sh create-confirmed-user
```
