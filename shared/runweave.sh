#!/bin/bash

set -xe

index="$1"; shift;
peers="$@";

sudo mkdir -p /usr/share/docker/plugins
sudo docker rm -f weaveplugin || true
sudo weave reset
sudo weave launch -iprange 10.20.0.0/16 $peers
sudo weave launch-dns 10.23.11.${index}/24

# setup routes
WEAVEDNS_PID=$(sudo docker inspect --format='{{ .State.Pid }}' weavedns)
[ ! -d /var/run/netns ] && sudo mkdir -p /var/run/netns
sudo ln -s /proc/$WEAVEDNS_PID/ns/net /var/run/netns/$WEAVEDNS_PID
sudo ip netns exec $WEAVEDNS_PID sudo ip route add 10.20.0.0/16 dev ethwe
sudo rm -f /var/run/netns/$WEAVEDNS_PID

sudo docker run \
    -d \
    --privileged \
    --net=host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/share/docker/plugins:/usr/share/docker/plugins \
    -v /proc:/hostproc \
    weaveworks/plugin \
    -nameserver=10.23.11.${index} \
    -debug=true \
    -socket=/usr/share/docker/plugins/weave.sock