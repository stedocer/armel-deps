FROM stedo/armel-deps:builder
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
    luarocks install rs232 && \
    luarocks install serpent && \
    luarocks install sha1 && \
    luarocks install vstruct && \
    luarocks install xavante
RUN cp -r /usr/local/lib/lua/5.1/* /cust/lua/ && \
    cp -r /usr/local/share/lua/5.1/* /cust/lua/
RUN git clone --depth=1 https://github.com/openresty/lua-resty-websocket && \
    cp -r /lua-resty-websocket/lib/resty/* /cust/lua/resty/
RUN [ "cross-build-end" ]
