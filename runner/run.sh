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

# bring up the cluster
vagrant up --parallel

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

# clone https://github.com/lukemarsden/unofficial-flocker-tools
# generate cluster.yml
# run deploy.py
rm -rf $DIR/unofficial-flocker-tools
git clone -b $TOOLS_BRANCH $TOOLS_REPO $DIR/unofficial-flocker-tools

# write the cluster.yml that will control the tools
cat << EOF > $DIR/unofficial-flocker-tools/cluster.yml
cluster_name: flockerdemo
agent_nodes:
 - {public: $masterip_public, private: $masterip_private}
 - {public: $runner1ip_public, private: $runner1ip_private}
 - {public: $runner2ip_public, private: $runner2ip_private}
control_node: $masterip_public
users:
 - flockerdemo
os: ubuntu
private_key_path: $sshkey
agent_config:
  version: 1
  control-service:
     hostname: $masterip_public
     port: 4524
  dataset:
    backend: "aws"
    region: "$awsregion"
    zone: "$awszone"
    access_key_id: "$awsid"
    secret_access_key: "$awskey"
EOF

# this step will get the core flocker services running
# and upload the certs required
cd $DIR/unofficial-flocker-tools && ./deploy.py cluster.yml
# this step will get the flocker plugin running
# and upload the certs required
cd $DIR/unofficial-flocker-tools && \
DOCKER_BINARY_URL="http://storage.googleapis.com/experiments-clusterhq/docker-binaries/docker-volumes-network-combo" \
DOCKER_SERVICE_NAME=docker.io \
PLUGIN_REPO=https://github.com/clusterhq/flocker-docker-plugin \
PLUGIN_BRANCH=maximum-size \
./plugin.py cluster.yml
# tell head node about the other 2
## TODO: we can just do this once weaveworks/docker-plugin#8 is fixed
##vagrant ssh master -c "weave connect $runner1ip $runner2ip"

# kick off the weave plugin on each node
start-weave-plugin master $runner1ip_private $runner2ip_private
start-weave-plugin runner-1 $masterip_private $runner2ip_private
start-weave-plugin runner-2 $masterip_private $runner1ip_private
