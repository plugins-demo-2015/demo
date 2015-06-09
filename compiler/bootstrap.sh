#!/bin/sh

# this script will checkout docker and weave
# it will then merge the latest volume plugin code into the latest network plugin code
# this leaves us with the latest version of weave and docker in the .build folder

#DOCKER_WEAVE_FORK=${DOCKER_WEAVE_FORK:-"https://github.com/squaremo/docker"}
#DOCKER_WEAVE_FORK_BRANCH=${DOCKER_WEAVE_FORK_BRANCH:-"network_extensions"}

#DOCKER_FLOCKER_FORK=${DOCKER_FLOCKER_FORK:-"https://github.com/calavera/docker"}
#DOCKER_FLOCKER_FORK_BRANCH=${DOCKER_FLOCKER_FORK_BRANCH:-"plugin_discovery"}

#DOCKER_MASTER_COMMIT=${DOCKER_MASTER_COMMIT:-"093f57a26134c262b14de801dd577fbce93ad664"}

#DOCKER_MAIN_FORK=${DOCKER_MAIN_FORK:-"https://github.com/docker/docker"}
#DOCKER_MAIN_BRANCH=${DOCKER_MAIN_BRANCH:-"master"}

WEAVE_FORK=${WEAVE_FORK:-"https://github.com/squaremo/weave"}
WEAVE_BRANCH=${WEAVE_FORK_BRANCH:-"libnetwork_plugin"}

DOCKER_FORK=${DOCKER_FORK:-"https://github.com/docker/docker"}
DOCKER_BRANCH=${DOCKER_BRANCH:-"master"}

rm -rf .build/docker
rm -rf .build/weave

#git clone --branch=$DOCKER_WEAVE_FORK_BRANCH $DOCKER_WEAVE_FORK .build/docker
git clone --branch=$DOCKER_BRANCH $DOCKER_FORK .build/docker
git clone --branch=$WEAVE_BRANCH $WEAVE_FORK .build/weave

# rebase the network extension commits onto the master
#cd .build/docker
#git checkout $DOCKER_MASTER_COMMIT
#git remote add weave $WEAVE_FORK
#git fetch weave
#git checkout $DOCKER_WEAVE_FORK_BRANCH
#git rebase $DOCKER_MAIN_BRANCH
#git checkout $DOCKER_MAIN_BRANCH
#git merge $DOCKER_WEAVE_FORK_BRANCH