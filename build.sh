#!/bin/sh
vagrant ssh builder -c 'make -C src/github.com/docker/docker'
vagrant ssh builder -c 'make -C src/github.com/weaveworks/weave'
