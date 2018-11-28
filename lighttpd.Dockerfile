FROM stedo/armel-deps:builder
RUN [ "cross-build-start" ]
WORKDIR /
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz && \
    tar -xzf pcre-8.42.tar.gz && \
    cd pcre-8.42 && \
    ./configure && \
    make && make install
RUN cp -a /usr/local/lib/libpcre.so* /cust/lib/ && \
    strip /cust/lib/libpcre.so*

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
RUN chmod u+x /cust/sbin/lighttpd
RUN [ "cross-build-end" ]
