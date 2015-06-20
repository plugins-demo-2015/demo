#!/bin/sh

set -e

#export TOOLS_REPO=${TOOLS_REPO:=https://github.com/robhaswell/unofficial-flocker-tools}
#export TOOLS_BRANCH=${TOOLS_BRANCH:=setuptools}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

master="172.16.70.250"
runner="172.16.70.251"

# clone $TOOLS_REPO
# generate cluster.yml
# run deploy.py
#rm -rf /root/unofficial-flocker-tools
#git clone -b $TOOLS_BRANCH $TOOLS_REPO /root/unofficial-flocker-tools
#pip install /root/unofficial-flocker-tools

rm -rf $DIR/_certs && mkdir -p $DIR/_certs

# write the cluster.yml that will control the tools
cat << EOF > $DIR/_certs/cluster.yml
cluster_name: flockerdemovagrant
agent_nodes:
 - {public: $master, private: $master}
 - {public: $runner, private: $runner}
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
(cd $DIR/_certs && flocker-config cluster.yml)
# this step will get the flocker plugin running
# and upload the certs required
(cd $DIR/_certs && \
DOCKER_BINARY_URL="http://storage.googleapis.com/experiments-clusterhq/docker-binaries/docker-volumes-network-combo" \
DOCKER_SERVICE_NAME=docker.io \
PLUGIN_REPO=https://github.com/clusterhq/flocker-docker-plugin \
PLUGIN_BRANCH=master \
SKIP_DOCKER_BINARY=yes \
flocker-plugin-install cluster.yml)
