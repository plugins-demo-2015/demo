#!/bin/sh

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd $DIR/unofficial-flocker-tools && \
DOCKER_BINARY_URL="http://storage.googleapis.com/experiments-clusterhq/docker-binaries/docker-volumes-network-combo" \
DOCKER_SERVICE_NAME=docker.io \
PLUGIN_REPO=https://github.com/clusterhq/flocker-docker-plugin \
PLUGIN_BRANCH=wait-for-uuid \
./plugin.py cluster.yml
