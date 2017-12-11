FROM debian:jessie

RUN apt-get update \
    && apt-get install -y git make gcc g++ libmysqlclient-dev libssl-dev wget \
    && wget https://www.openssl.org/source/openssl-1.0.1t.tar.gz \
    && tar -zxvf openssl-1.0.1t.tar.gz \
    && cd openssl-1.0.1t && ./config enable-ssl2 shared && make depend && make install \
    && rm -fr /openssl-1.0.1t* \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/*

ARG SERVER_VERSION=1.8.5
RUN git clone https://github.com/SUPLA/supla-core.git --branch v$SERVER_VERSION /src \
    && cd /src/supla-scheduler/Release && make all \
    && cd /src/supla-server/Release && make all \
    && cp /src/supla-scheduler/Release/supla-scheduler /src/supla-server/Release/supla-server /usr/local/bin \
    && rm -fr /src

COPY supla.cfg /etc/supla-server/supla.cfg

CMD ["/usr/local/bin/supla-server", ";", "/usr/local/bin/supla-scheduler", "-p", "/tmp/supla-scheduler.pid"]
