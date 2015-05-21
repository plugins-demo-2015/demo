#!/bin/sh

DOCKER_FORK=${DOCKER_FORK:-"https://github.com/squaremo/docker"}
DOCKER_FORK_BRANCH=${DOCKER_FORK_BRANCH:-"network_extensions"}

WEAVE_FORK=${WEAVE_FORK:-"https://github.com/squaremo/weave"}
WEAVE_FORK_BRANCH=${WEAVE_FORK_BRANCH:-"libnetwork_plugin"}

git clone --branch=$DOCKER_FORK_BRANCH $DOCKER_FORK .build/docker
git clone --branch=$WEAVE_FORK_BRANCH $WEAVE_FORK .build/weave

vagrant up builder
