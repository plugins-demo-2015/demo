#!/bin/sh
vagrant ssh builder -c 'make -C src/github.com/docker/docker clean'
vagrant ssh builder -c 'make -C src/github.com/weaveworks/docker-plugin clean'
