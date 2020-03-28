FROM alpine:3.11 as build
ARG version=2.0.20
ARG vcs_ref
ARG build_data
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor=tmorin \
      org.label-schema.license=MIT \
      org.label-schema.build-date="$build_data" \
      org.label-schema.vcs-ref="$vcs_ref" \
      org.label-schema.vcs-url="https://github.com/tmorin/docker-image-keepalived"

ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

RUN apk --no-cache add --virtual build-dependencies \
    autoconf \
    curl \
    gcc \
    ipset-dev \
    iptables-dev \
    libnftnl-dev \
    libnfnetlink-dev \
    libnl3-dev \
    make \
    musl-dev \
    openssl-dev

RUN curl -o keepalived.tar.gz -SL http://keepalived.org/software/keepalived-${version}.tar.gz \
    && mkdir -p /build \
    && tar -xzf keepalived.tar.gz --strip 1 -C /build \
    && cd /build \
    && ./configure --disable-dynamic-linking --prefix=/keepalived \
    && make \
    && make install

FROM alpine:3.11

RUN apk --no-cache add --virtual runtime-dependencies \
    bash \
    ipset \
    iptables \
    libnftnl \
    libnfnetlink \
    libnl3 \
    openssl

COPY --from=build /keepalived /
COPY ./rootfs .

CMD ["--log-detail", "--dump-conf", "--use-file", "/etc/keepalived/keepalived.alternative.conf"]
ENTRYPOINT ["/entrypoint.sh"]
