FROM debian:11.9

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

ENV SERVER_VERSION=v24.06.01
RUN git clone https://github.com/SUPLA/supla-core.git --branch ${SERVER_VERSION} /src \
    && cd /src \
    && git config user.email "foo@bar.com" \
    && git cherry-pick 1fb8cc00fc13580375527c8d1c60290f8e1ad7c6 \
    && cd /src/supla-scheduler/Release \
    && make all \
    && cd /src/supla-server/Release && make all \
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
