#!/bin/sh

IMAGE=`cat VERSION`

docker buildx build \
    --load \
    --build-arg BF_IMAGE=samba \
    --build-arg BF_VERSION=${IMAGE} \
    -f Dockerfile \
    -t samba-dev \
    . \
    && \
    docker run -it -v `pwd`/shares-conf-sample.json:/files/shares.json samba-dev sh
