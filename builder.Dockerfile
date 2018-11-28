FROM resin/armel-debian:jessie AS builder
RUN [ "cross-build-start" ]
WORKDIR /
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    autoconf \
    build-essential \
    cmake \
    dpkg-dev \
    g++-4.9 \
    gcc-4.9 \
    git \
    libc6-dev \
    libc-dev \
    libssl-dev \
    libtool \
    luarocks \
    make \
    screen \
    unzip \
    wget \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p \
    /cust/bin \
    /cust/lib/lighttpd \
    /cust/lib/terminfo/v \
    /cust/lua/resty \
    /cust/sbin
RUN cp /usr/bin/screen /cust/bin/screen && \
    cp /lib/terminfo/v/vt100 /cust/lib/terminfo/v/vt100
RUN [ "cross-build-end" ]
