FROM debian:11.6

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
        libcurl4-openssl-dev \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p /var/log/supervisor

ENV LIBRESSL_VERSION=3.5.4
RUN cd /usr/src \
    && wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz \
    && tar zxvf libressl-${LIBRESSL_VERSION}.tar.gz && rm libressl-${LIBRESSL_VERSION}.tar.gz \
    && cd libressl-${LIBRESSL_VERSION} \
    && sed -ri 's/(\{ \global\:)/LIBRESSL \1/' configure \
    && ./configure --prefix=/usr/src/libressl \
    && make && make install

ENV SERVER_VERSION=v24.05
RUN git clone https://github.com/SUPLA/supla-core.git --branch ${SERVER_VERSION} /src \
    && cd /src/supla-scheduler/Release \
    && find ./ -name "*.mk" -exec sed -i s/-O2/-O0/ {} \; \
    && make all SSLDIR=/usr/src/libressl \
    && cd /src/supla-server/Release && make all SSLDIR=/usr/src/libressl \
    && cp /src/supla-scheduler/Release/supla-scheduler /src/supla-server/Release/supla-server /usr/local/bin \
    && rm -fr /src \
    && mkdir -p /etc/supla-server

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supla.cfg /etc/supla-server/supla.cfg.initial
COPY server-entrypoint.sh /usr/bin/server-entrypoint

HEALTHCHECK --interval=1m --timeout=5s --retries=3 --start-period=30s \
    CMD wget --no-verbose --tries=1 --spider http://supla-cloud/api/server-status || exit 1

ENTRYPOINT ["/usr/bin/server-entrypoint"]
CMD ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
