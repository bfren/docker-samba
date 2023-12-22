FROM bfren/alpine-s6:alpine3.19-5.1.1

LABEL org.opencontainers.image.source="https://github.com/bfren/docker-samba"

ARG BF_IMAGE
ARG BF_VERSION

EXPOSE 445

COPY ./overlay /

RUN bf-install

VOLUME [ "/files" ]
