#!/bin/sh

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# run the weave plugin on a named node
# the peer IP addresses are passed as args
function start-weave() {
  local node="$1"; shift;
  local index="$1"; shift;
  local peers="$@";

  # make sure the plugins folder exists
  vagrant ssh $node -c "mkdir -p /usr/share/docker/plugins"

  # run the weave router
  vagrant ssh $node -c "weave launch -iprange 10.20.0.0/16 $peers"

  # run the weave DNS
  vagrant ssh $node -c "weave launch-dns 10.23.11.${index}/24"

  # start the weave plugin mounting the docker.sock
  # the plugin will start the weave container
  # we mount the plugins folder
  vagrant ssh $node -c "sudo docker run \
    -d \
    --privileged \
    --net=host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/share/docker/plugins:/usr/share/docker/plugins \
    -v /proc:/hostproc \
    weaveworks/plugin \
    -nameserver=10.23.11.${index} \
    -debug=true \
    -socket=/usr/share/docker/plugins/weave.sock"
}

master="172.16.70.250"
runner1="172.16.70.251"
runner2="172.16.70.252"

# kick off the weave plugin on each node
start-weave master 10 $runner1 $runner1
start-weave runner-1 11 $runner2 $master
start-weave runner-2 12 $runner1 $master
