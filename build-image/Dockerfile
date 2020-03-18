FROM alpine:3.10 AS jsonnet-builder
RUN apk add --no-cache git make g++

# Install jsonnetfmt
RUN git clone https://github.com/google/jsonnet && \
    git  -C jsonnet checkout v0.14.0 && \
    make -C jsonnet 2LDFLAGS=-static && \
    cp jsonnet/jsonnetfmt /usr/bin && \
    rm -fr jsonnet
