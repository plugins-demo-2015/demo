#!/bin/sh
vagrant ssh builder -c 'export DOCKER_EXPERIMENTAL=1 && make -C src/github.com/docker/docker'
vagrant ssh builder -c 'make -C src/github.com/weaveworks/docker-plugin'
