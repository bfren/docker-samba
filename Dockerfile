FROM bfren/alpine-s6:alpine3.16-4.3.14

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-samba"

ARG BF_IMAGE
ARG BF_VERSION

EXPOSE 445

COPY ./overlay /

RUN bf-install

VOLUME [ "/files" ]
