FROM alpine:3.12 as build
ARG version=2.0.20
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"
RUN apk --no-cache add --virtual build-dependencies \
    autoconf \
    automake \
    wget \
    gcc \
    make \
    tar \
    iptables-dev \
    ipset-dev \
    libnl3-dev \
    musl-dev \
    libnftnl-dev \
    libressl-dev \
    file-dev \
    net-snmp-dev \
    pcre2-dev
RUN wget -O keepalived.tar.gz https://github.com/acassen/keepalived/archive/v${version}.tar.gz
RUN mkdir -p /build
RUN tar -xzf keepalived.tar.gz --strip 1 -C /build
RUN cd /build \
    && ./build_setup \
    && ./configure --disable-dynamic-linking --prefix=/keepalived \
    && make \
    && make install

FROM alpine:3.12
ARG git_sha=""
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="tmorin" \
      org.label-schema.license="MIT" \
      org.label-schema.vcs-ref="$git_sha" \
      org.label-schema.vcs-url="https://github.com/tmorin/docker-image-keepalived"
RUN apk --no-cache add --virtual runtime-dependencies \
    bash \
    ipset \
    iptables \
    libnftnl \
    libnfnetlink \
    libnl3 \
    libressl
COPY --from=build /keepalived /
COPY ./rootfs .
CMD ["--log-detail", "--dump-conf", "--use-file", "/etc/keepalived/keepalived.alternative.conf"]
ENTRYPOINT ["/entrypoint.sh"]
