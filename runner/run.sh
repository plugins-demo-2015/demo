#!/bin/sh

# return the private IP of a named node
function get-node-private-ip() {
  local node="$1"; shift;
  vagrant awsinfo -m $node -p | jq -r '.private_ip'
}

# run the weave plugin on a named node
# the peer IP addresses are passed as args
function start-weave-plugin() {
  local node="$1"; shift;
  local peers="$@";

  vagrant ssh $node -c "sudo docker run -d \
    --name=weaveplugin \
    --privileged \
    --net=host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/share/docker/plugins:/usr/share/docker/plugins \
    weaveworks/plugin \
    -debug=true \
    -socket=/usr/share/docker/plugins/weave.so $peers"
}

# bring up the cluster
vagrant up

# get the IP addresses of the nodes
masterip=$(get-node-private-ip master)
runner1ip=$(get-node-private-ip runner-1)
runner2ip=$(get-node-private-ip runner-2)

# kick off the weave plugin on each node
start-weave-plugin master $runner1ip $runner2ip
start-weave-plugin runner-1 $masterip $runner2ip
start-weave-plugin runner-2 $masterip $runner1ip
