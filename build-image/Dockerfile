# Build jsonnet
FROM alpine:3.11 AS jsonnet-builder
RUN apk add --no-cache git make g++
RUN git clone https://github.com/google/jsonnet && \
    git  -C jsonnet checkout v0.15.0 && \
    make -C jsonnet 2LDFLAGS=-static && \
    cp jsonnet/jsonnet /usr/bin && \
    cp jsonnet/jsonnetfmt /usr/bin

# Build jb
FROM golang:1.14.1-alpine3.11 AS jb-builder
RUN apk add --no-cache git make
RUN git clone https://github.com/jsonnet-bundler/jsonnet-bundler /jsonnet-bundler && \
    cd /jsonnet-bundler && \
    git checkout v0.2.0 && \
    make install

# Build tanka
FROM golang:1.14.1-alpine3.11 as tk-builder
ARG TANKA_VERSION=0.11.1
ARG TANKA_CHECKSUM="3b253ca7d7bf01189604c10a8f7cead20a553ddc04c813f0f836d80338cfad71  /usr/bin/tk"
RUN apk add --no-cache curl
RUN curl -fSL -o "/usr/bin/tk" "https://github.com/grafana/tanka/releases/download/v${TANKA_VERSION}/tk-linux-amd64"
RUN echo "${TANKA_CHECKSUM}" | sha256sum -c || (printf "wanted: %s\n   got: %s\n" "${TANKA_CHECKSUM}" "$(sha256sum /usr/bin/tk)"; exit 1)
RUN chmod +x /usr/bin/tk

FROM alpine:3.11
RUN apk add --no-cache git make libgcc libstdc++ zip
COPY --from=jsonnet-builder /usr/bin/jsonnetfmt /usr/bin
COPY --from=jsonnet-builder /usr/bin/jsonnet /usr/bin
COPY --from=jb-builder /go/bin/jb /usr/bin
COPY --from=tk-builder /usr/bin/tk /usr/bin
