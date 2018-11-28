FROM scratch
WORKDIR /
COPY --from=stedo/armel-deps:builder /cust /cust/
COPY --from=stedo/armel-deps:lighttpd /cust /cust/
COPY --from=stedo/armel-deps:mosquitto /cust /cust/
COPY --from=stedo/armel-deps:lua /cust /cust/
