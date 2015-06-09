#!/bin/sh

set -e

export TOOLS_REPO=${TOOLS_REPO:=https://github.com/binocarlos/unofficial-flocker-tools}
export TOOLS_BRANCH=${TOOLS_BRANCH:=install-plugin}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

master="172.16.70.250"
runner1="172.16.70.251"
runner2="172.16.70.252"

# clone $TOOLS_REPO
# generate cluster.yml
# run deploy.py
rm -rf $DIR/unofficial-flocker-tools
git clone -b $TOOLS_BRANCH $TOOLS_REPO $DIR/unofficial-flocker-tools

# write the cluster.yml that will control the tools
cat << EOF > $DIR/unofficial-flocker-tools/cluster.yml
cluster_name: flockerdemovagrant
agent_nodes:
 - {public: $master, private: $master}
 - {public: $runner1, private: $runner1}
 - {public: $runner2, private: $runner2}
control_node: $master
users:
 - flockerdemo
os: ubuntu
private_key_path: $DIR/insecure_private_key
agent_config:
  version: 1
  control-service:
     hostname: $master
     port: 4524
  dataset:
    backend: "zfs"
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
SKIP_DOCKER_BINARY=yes \
SKIP_INSTALL_PLUGIN=yes \
./plugin.py cluster.yml
