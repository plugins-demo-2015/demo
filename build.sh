cd build
vagrant ssh -c 'make -C src/github.com/docker/docker'
vagrant ssh -c 'make -C src/github.com/weaveworks/weave'
