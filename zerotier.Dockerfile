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
    libtool \
    make && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /cust/sbin
RUN [ "cross-build-end" ]

FROM builder AS armel-zerotier
RUN [ "cross-build-start" ]
WORKDIR /
RUN git clone --depth=1 https://github.com/zerotier/ZeroTierOne.git && \
    cd ZeroTierOne && \
    make \
    CC=gcc-4.9 \
    CXX=g++-4.9
RUN cp /ZeroTierOne/zerotier-one /cust/sbin/zerotier-one && \
    strip /cust/sbin/zerotier-one
RUN [ "cross-build-end" ]


FROM scratch
COPY --from=armel-zerotier /cust /cust/
