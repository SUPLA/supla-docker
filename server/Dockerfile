FROM debian:jessie

RUN apt-get update && \
    apt-get install -y git make gcc g++ libmysqlclient-dev libssl-dev wget && \
    wget https://www.openssl.org/source/openssl-1.0.1t.tar.gz && \
    tar -zxvf openssl-1.0.1t.tar.gz && \
    (cd openssl-1.0.1t && ./config enable-ssl2 --prefix=/usr/local && make depend) \
    && apt-get autoremove \
    && rm -r /var/lib/apt/lists/*

ARG SERVER_VERSION=1.8.5
RUN git clone https://github.com/SUPLA/supla-core.git /src && \
    cd /src && git checkout v$SERVER_VERSION && \
    (cd /src/supla-dev/Release && make all) && \
    (cd /src/supla-scheduler/Release && make all) && \
    (cd /src/supla-server/Release && make all) && \
    (cd /src/supla-console-client/Debug && make all) && \
    cp /src/supla-dev/Release/supla-dev /src/supla-scheduler/Release/supla-scheduler /src/supla-server/Release/supla-server /src/supla-console-client/Debug/supla-console-client /usr/local/bin
