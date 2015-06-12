#!/bin/bash

set -xe

index="$1"; shift;
peers="$@";

mkdir -p /usr/share/docker/plugins
docker rm -f weaveplugin || true
weave stop
weave stop-dns
weave launch -iprange 10.20.0.0/16 $peers
weave launch-dns 10.23.11.${index}/24

# setup routes
nsenter -n -t `pgrep weavedns` ip route add 10.20.0.0/16 dev ethwe

docker run \
    -d \
    --privileged \
    --net=host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/share/docker/plugins:/usr/share/docker/plugins \
    -v /proc:/hostproc \
    weaveworks/plugin \
    -nameserver=10.23.11.10 \
    -debug=true \
    -socket=/usr/share/docker/plugins/weave.sock
