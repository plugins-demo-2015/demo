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
WEAVEDNS_PID=$(docker inspect --format='{{ .State.Pid }}' weavedns)
[ ! -d /var/run/netns ] && sudo mkdir -p /var/run/netns
ln -s /proc/$WEAVEDNS_PID/ns/net /var/run/netns/$WEAVEDNS_PID
ip netns exec $WEAVEDNS_PID sudo ip route add 10.20.0.0/16 dev ethwe
rm -f /var/run/netns/$WEAVEDNS_PID

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
