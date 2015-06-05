#!/bin/sh

export TOOLS_REPO=${TOOLS_REPO:=https://github.com/binocarlos/unofficial-flocker-tools}
export TOOLS_BRANCH=${TOOLS_BRANCH:=install-plugin}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $DIR/utils.sh

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

# clone $TOOLS_REPO
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
PLUGIN_REPO=https://github.com/clusterhq/flocker-docker-plugin \
PLUGIN_BRANCH=maximum-size \
./plugin.py cluster.yml
