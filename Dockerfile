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
    upx-ucl \
    wget \
    zlib1g-dev && \
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



FROM builder AS armel-lighttpd
RUN [ "cross-build-start" ]
WORKDIR /
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz && \
    tar -xzf pcre-8.42.tar.gz && \
    cd pcre-8.42 && \
    ./configure && \
    make && make install
RUN cp -L /usr/local/lib/libpcre.so /cust/lib && \
    strip /cust/lib/libpcre.so

WORKDIR /
RUN wget https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.51.tar.gz && \
    tar -xzf lighttpd-1.4.51.tar.gz && \
    cd lighttpd-1.4.51 && \
    ./configure \
    --enable-shared \
    --libdir=/cust/lib/lighttpd \
    --sysconfdir=/cust/etc \
    --without-bzip2 \
    --without-mysql \
    --with-openssl \
    --with-openssl-libs=/usr/lib \
    --with-pcre \
    --with-zlib && \
    make && make install
RUN cp -L /usr/local/sbin/lighttpd /cust/sbin/lighttpd && \
    strip /cust/sbin/lighttpd && \
    strip /cust/lib/lighttpd/*.so && \
    rm /cust/lib/lighttpd/*.la
RUN upx-ucl \
    --best \
    --ultra-brute \
    /cust/sbin/lighttpd
RUN chmod u+x /cust/sbin/lighttpd
RUN [ "cross-build-end" ]



FROM builder as armel-mosquitto
RUN [ "cross-build-start" ]
WORKDIR /
RUN git clone --depth=1 https://github.com/eclipse/mosquitto.git && \
    cd mosquitto && \
    make \
    WITH_BRIDGE=no \
    WITH_BUNDLED_DEPS=yes \
    WITH_DOCS=no \
    WITH_EC=yes \
    WITH_EPOLL=yes \
    WITH_MEMORY_TRACKING=no \
    WITH_PERSISTENCE=no \
    WITH_SHARED_LIBRARIES=yes \
    WITH_SOCKS=yes \
    WITH_SRV=no \
    WITH_STATIC_LIBRARIES=no \
    WITH_STRIP=yes \
    WITH_SYS_TREE=no \
    WITH_SYSTEMD=no \
    WITH_THREADING=yes \
    WITH_TLS=yes \
    WITH_TLS_PSK=yes \
    WITH_UUID=no \
    WITH_WEBSOCKETS=no
RUN cp -L /mosquitto/src/mosquitto /cust/sbin/mosquitto && \
    cp -L /mosquitto/lib/libmosquitto.so* /cust/lib/ && \
    strip /cust/lib/libmosquitto.so* && \
    strip /cust/sbin/mosquitto
RUN upx-ucl \
    --best \
    --ultra-brute \
    /cust/sbin/mosquitto
RUN chmod u+x /cust/sbin/mosquitto
RUN [ "cross-build-end" ]



FROM builder as armel-lua
RUN [ "cross-build-start" ]
WORKDIR /
RUN wget http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz -O luajit.tar.gz && \
    tar -xzf luajit.tar.gz -C ./ --strip-components=1 && \
    make \
    XCFLAGS="-DLUAJIT_ENABLE_LUA52COMPAT" && \
    make install
RUN cp -L /usr/local/bin/luajit-2.1.0-beta3 /cust/bin/luajit && \
    strip /cust/bin/luajit && \
    chmod u+x /cust/bin/luajit
RUN cp -r /usr/local/share/luajit-2.1.0-beta3/jit /cust/lua/jit

WORKDIR /
RUN luarocks install luasec \
      OPENSSL_INCDIR=/usr/include \
      OPENSSL_LIBDIR=/usr/lib/arm-linux-gnueabi
RUN luarocks install compat52 && \
    luarocks install copas && \
    luarocks install luafilesystem && \
    luarocks install lua-MessagePack && \
    luarocks install luamqttc && \
    luarocks install lzlib \
      ZLIB_LIBDIR=/lib/arm-linux-gnueabi && \
    luarocks install serpent && \
    luarocks install sha1 && \
    luarocks install vstruct && \
    luarocks install xavante
RUN cp -r /usr/local/lib/lua/5.1/* /cust/lua/ && \
    cp -r /usr/local/share/lua/5.1/* /cust/lua/
RUN git clone --depth=1 https://github.com/openresty/lua-resty-websocket && \
    cp -r /lua-resty-websocket/lib/resty/* /cust/lua/resty/
RUN [ "cross-build-end" ]



FROM scratch
WORKDIR /
COPY --from=builder /cust /cust/
COPY --from=armel-lighttpd /cust /cust/
COPY --from=armel-mosquitto /cust /cust/
COPY --from=armel-lua /cust /cust/
