FROM stedo/armel-deps:builder
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
