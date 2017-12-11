# SUPLA-Docker
 
| SUPLA-Cloud        | SUPLA-Core           |
| ------------- |:-------------|
| [![Latest release](https://img.shields.io/github/release/SUPLA/supla-cloud.svg)](https://github.com/SUPLA/supla-cloud/releases/latest) | [![Latest release](https://img.shields.io/github/release/SUPLA/supla-core.svg)](https://github.com/SUPLA/supla-core/releases/latest) |

Your home connected. With Docker. www.supla.org

![SUPLA-Docker](./supla-docker.png)

## Installation

1. Install [Docker CE](https://docs.docker.com/engine/installation/) 17.06+ 
   and [docker-compose](https://docs.docker.com/compose/install/) 1.17+.
   The following _should_ work (as root):
   ```
   curl -sSL https://get.docker.com | sh
   apt-get -y install python-pip
   pip install docker-compose
   ```
1. Clone this repository.
   * For Raspberry Pi and other ARM-based devices choose the `raspberry` branch:
      ```
      git clone https://github.com/SUPLA/supla-docker.git --branch raspberry
      ```
   * On any other architecture, choose `common` branch:
      ```
      git clone https://github.com/SUPLA/supla-docker.git --branch common
      ```
1. Start SUPLA!
   ```
   ./supla-docker/supla.sh start
   ```
