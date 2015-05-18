cd build
vagrant ssh -c 'make -C src/github.com/docker/docker clean'
vagrant ssh -c 'make -C src/github.com/weaveworks/weave clean'
