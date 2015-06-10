#!/bin/sh

DOCKER_WEAVE_FORK=${DOCKER_WEAVE_FORK:-"https://github.com/squaremo/docker"}
DOCKER_WEAVE_FORK_BRANCH=${DOCKER_WEAVE_FORK_BRANCH:-"plugins_demo"}
WEAVE_PLUGIN_FORK=${WEAVE_PLUGIN_FORK:-"https://github.com/weaveworks/docker-plugin"}
WEAVE_PLUGIN_FORK_BRANCH=${WEAVE_PLUGIN_FORK_BRANCH:-"master"}

if [ -d .build ]; then
    rm -rf .build
fi
git clone --depth 10 --branch=$DOCKER_WEAVE_FORK_BRANCH $DOCKER_WEAVE_FORK .build/docker
git clone --branch=$WEAVE_PLUGIN_FORK_BRANCH $WEAVE_PLUGIN_FORK .build/docker-plugin

vagrant up builder
