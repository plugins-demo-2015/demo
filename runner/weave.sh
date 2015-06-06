#!/bin/sh

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $DIR/utils.sh

# run the weave plugin on a named node
# the peer IP addresses are passed as args
function start-weave-plugin() {
  local node="$1"; shift;
  local peers="$@";

  # make sure the plugins folder exists
  vagrant ssh $node -c "mkdir -p /usr/share/docker/plugins"

  # start the weave plugin mounting the docker.sock
  # the plugin will start the weave container
  # we mount the plugins folder
  vagrant ssh $node -c "sudo docker run -d \
    --name=weaveplugin \
    --privileged \
    --net=host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/share/docker/plugins:/usr/share/docker/plugins \
    weaveworks/plugin \
    -debug=true \
    -socket=/usr/share/docker/plugins/weave.sock $peers"
}

# get the IP addresses of the nodes
masterip_private=$(get-node-ip master private_ip)
runner1ip_private=$(get-node-ip runner-1 private_ip)
runner2ip_private=$(get-node-ip runner-2 private_ip)

# tell head node about the other 2
## TODO: we can just do this once weaveworks/docker-plugin#8 is fixed
##vagrant ssh master -c "weave connect $runner1ip $runner2ip"

# kick off the weave plugin on each node
start-weave-plugin master $runner1ip_private $runner2ip_private
start-weave-plugin runner-1 $masterip_private $runner2ip_private
start-weave-plugin runner-2 $masterip_private $runner1ip_private
