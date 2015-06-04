#!/bin/sh

export TOOLS_REPO=${TOOLS_REPO:=https://github.com/binocarlos/unofficial-flocker-tools}
export TOOLS_BRANCH=${TOOLS_BRANCH:=install-plugin}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# return the private or public IP of a named node
function get-node-ip() {
  local node="$1"; shift;
  local field="$1"; shift;
  vagrant awsinfo -m $node -p | jq -r ".$field"
}

function get_aws_value() {
  local field="$1";
  cat $DIR/../.aws_secrets | grep $field | awk '{print $2}'
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
    -v /usr/share/docker.io/plugins:/usr/share/docker/plugins \
    weaveworks/plugin \
    -debug=true \
    -socket=/usr/share/docker/plugins/weave.sock $peers"
}

sshkey=$(get_aws_value keypair_path)
awsid=$(get_aws_value access_key_id)
awskey=$(get_aws_value secret_access_key)
awsregion=$(get_aws_value region)
awszone=$(get_aws_value zone)

# get the IP addresses of the nodes
masterip_private=$(get-node-ip master private_ip)
runner1ip_private=$(get-node-ip runner-1 private_ip)
runner2ip_private=$(get-node-ip runner-2 private_ip)
masterip_public=$(get-node-ip master public_ip)
runner1ip_public=$(get-node-ip runner-1 public_ip)
runner2ip_public=$(get-node-ip runner-2 public_ip)

# kick off the weave plugin on each node
start-weave-plugin master $runner1ip_private $runner2ip_private
start-weave-plugin runner-1 $masterip_private $runner2ip_private
start-weave-plugin runner-2 $masterip_private $runner1ip_private
