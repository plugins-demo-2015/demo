#!/bin/sh

# build the latest docker binary
# it will be spit out into .build/docker/bundles/1.7.0-dev-experimental/binary
vagrant ssh compiler -c 'export DOCKER_EXPERIMENTAL=1 && make -C src/github.com/docker/docker'
# build the latest weave binary - it will create .tar files for the docker images
# in .build/weave/{weave,weavedns,weaveexec,plugin}.tar
vagrant ssh compiler -c 'make -C src/github.com/weaveworks/docker-plugin'
