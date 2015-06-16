#!/bin/sh

set -ex

weave_release='0.11.2'

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# run the weave plugin on a named node
# the peer IP addresses are passed as args
function start-weave() {
  local node="$1"; shift;
  local index="$1"; shift;
  local peers="$@";
  vagrant ssh $node -c "sudo bash /tmp/runweave.sh $index $peers"
}

master="172.16.70.250"
runner="172.16.70.251"

# kick off the weave plugin on each node
start-weave master 10 $runner
start-weave runner 11 $master
