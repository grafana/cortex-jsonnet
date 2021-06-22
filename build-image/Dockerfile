# Build jsonnet
FROM alpine:3.13 AS jsonnet-builder
RUN apk add --no-cache git make g++
RUN git clone https://github.com/google/jsonnet && \
    git  -C jsonnet checkout v0.15.0 && \
    make -C jsonnet 2LDFLAGS=-static && \
    cp jsonnet/jsonnet /usr/bin && \
    cp jsonnet/jsonnetfmt /usr/bin

# Build jb
FROM alpine:3.13 AS jb-builder
ARG JSONNET_BUNDLER_VERSION=0.4.0
ARG JSONNET_BUNDLER_CHECKSUM="433edab5554a88a0371e11e93080408b225d41c31decf321c02b50d2e44993ce  /usr/bin/jb"
RUN apk add --no-cache curl
RUN curl -fSL -o "/usr/bin/jb" "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v${JSONNET_BUNDLER_VERSION}/jb-linux-amd64"
RUN echo "${JSONNET_BUNDLER_CHECKSUM}" | sha256sum -c || (printf "wanted: %s\n   got: %s\n" "${JSONNET_BUNDLER_CHECKSUM}" "$(sha256sum /usr/bin/jb)"; exit 1)
RUN chmod +x /usr/bin/jb

# Build tanka
FROM alpine:3.13 AS tk-builder
ARG TANKA_VERSION=0.11.1
ARG TANKA_CHECKSUM="3b253ca7d7bf01189604c10a8f7cead20a553ddc04c813f0f836d80338cfad71  /usr/bin/tk"
RUN apk add --no-cache curl
RUN curl -fSL -o "/usr/bin/tk" "https://github.com/grafana/tanka/releases/download/v${TANKA_VERSION}/tk-linux-amd64"
RUN echo "${TANKA_CHECKSUM}" | sha256sum -c || (printf "wanted: %s\n   got: %s\n" "${TANKA_CHECKSUM}" "$(sha256sum /usr/bin/tk)"; exit 1)
RUN chmod +x /usr/bin/tk

# Build mixtool
FROM golang:1.15-alpine AS mixtool-builder
RUN GO111MODULE=on go get github.com/monitoring-mixins/mixtool/cmd/mixtool@ae18e31161ea10545b9c1ac0d23c10122f2c12b5

FROM alpine:3.13
RUN apk add --no-cache git make libgcc libstdc++ zip findutils sed
COPY --from=jsonnet-builder /usr/bin/jsonnetfmt /usr/bin
COPY --from=jsonnet-builder /usr/bin/jsonnet /usr/bin
COPY --from=jb-builder /usr/bin/jb /usr/bin
COPY --from=tk-builder /usr/bin/tk /usr/bin
COPY --from=mixtool-builder /go/bin/mixtool /usr/bin

# Install yq.
# TODO We can install it via apk once alpine 3.14 or above will be released. Previous versions don't package v4.
RUN wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64 && \
    chmod +x /usr/bin/yq
