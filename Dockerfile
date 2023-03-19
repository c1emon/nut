FROM ubuntu:22.04 as builder

ARG BRANCH=master

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list && \
    apt update && apt -y install git python3 curl build-essential automake libtool m4 autoconf libmodbus-dev

RUN mkdir /nut && \
    git clone https://github.com/networkupstools/nut.git /nut && \
    cd /nut && \
    git checkout ${BRANCH} && \
    ./autogen.sh && ./configure --with-serial=yes --with-modbus=yes --with-systemdsystemunitdir=no && make && \
    rm -rf /nut/drivers/*.c /nut/drivers/*.h /nut/drivers/*.o /nut/drivers/*.am /nut/drivers/*.la /nut/drivers/*.lo /nut/drivers/Makefile* && \
    rm -rf /nut/clients/*.c /nut/clients/*.h /nut/clients/*.o /nut/client/*.am /nut/clients/*.la /nut/clients/*.lo /nut/clients/Makefile* /nut/clients/*.cpp && \
    rm -rf /nut/server/*.c /nut/server/*.h /nut/server/*.o /nut/server/*.am /nut/server/*.la /nut/server/*.lo /nut/server/Makefile*

FROM ubuntu:22.04

WORKDIR /nut

RUN apt update && apt -y install libmodbus5

COPY --from=builder /nut/server server
COPY --from=builder /nut/drivers drivers
COPY --from=builder /nut/clients clients
COPY entry.sh /nut/

EXPOSE 3493

ENTRYPOINT [ "/nut/entry.sh" ]