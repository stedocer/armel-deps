FROM stedo/armel-deps:builder
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
