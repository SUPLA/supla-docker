FROM debian:stretch

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        make \
        gcc \
        g++ \
        default-libmysqlclient-dev \
        libssl-dev \
        wget \
        supervisor \
        ca-certificates \
        ssl-cert \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

ENV LIBRESSL_VERSION=3.4.2
RUN cd /usr/src \
    && wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz \
    && tar zxvf libressl-${LIBRESSL_VERSION}.tar.gz && rm libressl-${LIBRESSL_VERSION}.tar.gz \
    && cd libressl-${LIBRESSL_VERSION} \
    && ./configure --prefix=/usr/src/libressl \
    && make && make install

ENV SERVER_VERSION=v22.11
RUN git clone https://github.com/SUPLA/supla-core.git --branch ${SERVER_VERSION} /src \
    && cd /src/supla-scheduler/Release && make all SSLDIR=/usr/src/libressl \
    && cd /src/supla-server/Release && make all SSLDIR=/usr/src/libressl \
    && cp /src/supla-scheduler/Release/supla-scheduler /src/supla-server/Release/supla-server /usr/local/bin \
    && rm -fr /src \
    && mkdir -p /etc/supla-server

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supla.cfg /etc/supla-server/supla.cfg.initial
COPY server-entrypoint.sh /usr/bin/server-entrypoint

ENTRYPOINT ["/usr/bin/server-entrypoint"]
CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
