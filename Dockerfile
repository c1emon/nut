FROM alpine:edge

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.schema-version="1.0" \
    org.label-schema.description="This docker image implements Network UPS Tools (NUT) upsd daemon" \
    org.label-schema.name=nut \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=https://github.com/c1emon/nut

LABEL org.opencontainers.image.authors="cjw7360chen@gmail.com"

# 'nut' package is only available from testing branch -- add it to the repo list
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update --allow-untrusted && apk upgrade --allow-untrusted && \
    apk add --no-cache --allow-untrusted nut

COPY files/startup.sh /startup.sh

RUN [ -d /etc/nut ] && find /etc/nut/ -type f -exec mv {} {}.sample \; || false && \
    chmod 700 /startup.sh && \
    mkdir -p /var/run/nut && \
    chown nut:nut /var/run/nut && \
    chmod 700 /var/run/nut

ENTRYPOINT ["/startup.sh"]

EXPOSE 3493