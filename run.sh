#!/bin/sh

IMAGE=`cat VERSION`

docker buildx build \
    --build-arg BF_IMAGE=samba \
    --build-arg BF_VERSION=${IMAGE} \
    -f Dockerfile \
    -t samba-dev \
    . \
    && \
    docker run -it samba-dev sh
