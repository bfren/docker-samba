FROM quay.io/bfren/alpine-s6:alpine3.23-6.1.0

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-samba"

ARG BF_IMAGE
ARG BF_PUBLISHING
ARG BF_VERSION

EXPOSE 445

COPY ./overlay /

RUN bf-install

VOLUME [ "/files" ]
