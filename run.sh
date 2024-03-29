#!/bin/sh

IMAGE=`cat VERSION`

docker buildx build \
    --load \
    --progress plain \
    --build-arg BF_IMAGE=samba \
    --build-arg BF_VERSION=${IMAGE} \
    -f Dockerfile \
    -t samba-dev \
    . \
    && \
    docker run -it -e BF_DEBUG=1 -v `pwd`/shares-conf-sample.json:/files/shares.json samba-dev sh
