#!/bin/sh

# this script will checkout docker and weave
# it will then merge the latest volume plugin code into the latest network plugin code
# this leaves us with the latest version of weave and docker in the .build folder

DOCKER_WEAVE_FORK=${DOCKER_WEAVE_FORK:-"https://github.com/squaremo/docker"}
DOCKER_WEAVE_FORK_BRANCH=${DOCKER_WEAVE_FORK_BRANCH:-"network_extensions"}

DOCKER_FLOCKER_FORK=${DOCKER_FLOCKER_FORK:-"https://github.com/calavera/docker"}
DOCKER_FLOCKER_FORK_BRANCH=${DOCKER_FLOCKER_FORK_BRANCH:-"plugin_discovery"}
DOCKER_FLOCKER_FORK_REMOTE=${DOCKER_FLOCKER_FORK_REMOTE:-"calavera"}

DOCKER_MAIN_FORK=${DOCKER_MAIN_FORK:-"https://github.com/docker/docker"}
DOCKER_MAIN_BRANCH=${DOCKER_MAIN_BRANCH:-"master"}

WEAVE_FORK=${WEAVE_FORK:-"https://github.com/squaremo/weave"}
WEAVE_FORK_BRANCH=${WEAVE_FORK_BRANCH:-"libnetwork_plugin"}

rm -rf .build/docker
rm -rf .build/weave

#git clone --branch=$DOCKER_WEAVE_FORK_BRANCH $DOCKER_WEAVE_FORK .build/docker
git clone --branch=$DOCKER_MAIN_BRANCH $DOCKER_MAIN_FORK .build/docker
git clone --branch=$WEAVE_FORK_BRANCH $WEAVE_FORK .build/weave

# rebase the volume extension commits onto the network extension ones
#cd .build/docker
#git remote add $DOCKER_FLOCKER_FORK_REMOTE $DOCKER_FLOCKER_FORK
#git fetch $DOCKER_FLOCKER_FORK_REMOTE $DOCKER_FLOCKER_FORK_BRANCH:$DOCKER_FLOCKER_FORK_BRANCH
#git checkout $DOCKER_FLOCKER_FORK_BRANCH
#git rebase $DOCKER_WEAVE_FORK_BRANCH
#git checkout $DOCKER_WEAVE_FORK_BRANCH
#git merge $DOCKER_FLOCKER_FORK_BRANCH