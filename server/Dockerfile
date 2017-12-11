FROM debian:jessie

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        make \
        gcc \
        g++ \
        libmysqlclient-dev \
        libssl-dev \
        wget \
        supervisor \
        ca-certificates \
        ssl-cert \
    && wget https://www.openssl.org/source/openssl-1.0.1t.tar.gz \
    && tar -zxf openssl-1.0.1t.tar.gz \
    && cd openssl-1.0.1t && ./config enable-ssl2 --prefix=/usr/local shared && make depend && make install \
    && rm -fr /openssl-1.0.1t* \
    && cp /usr/local/lib/libcrypto.so.1.0.0 "$(ldconfig -p | grep libcrypto.so.1.0.0$ | awk '{ print $4 }')" \
    && cp /usr/local/lib/libssl.so.1.0.0 "$(ldconfig -p | grep libssl.so.1.0.0$ | awk '{ print $4 }')" \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

ARG SERVER_VERSION=1.8.5
RUN git clone https://github.com/SUPLA/supla-core.git --branch v$SERVER_VERSION /src \
    && cd /src/supla-scheduler/Release && make all \
    && cd /src/supla-server/Release && make all \
    && cp /src/supla-scheduler/Release/supla-scheduler /src/supla-server/Release/supla-server /usr/local/bin \
    && rm -fr /src \
    && mkdir -p /etc/supla-server

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supla.cfg /etc/supla-server/supla.cfg

CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
