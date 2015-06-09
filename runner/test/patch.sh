#!/bin/bash

# upload a new docker binary - patch flocker
# and get everything restarted
set -xe

runner1="23.22.54.22"
runner2="54.159.161.241"
master="54.158.86.20"
key="/Users/kai/.ssh/kai-demo.pem"
#binaryfolder="/Users/kai/projects/docker-plugins-demo/compiler/.build/docker/bundles/1.7.0-dev/binary"
#binaryname="docker-1.7.0-dev"
binaryfolder="/Users/kai/projects/docker-plugins-demo/runner/test"
binaryname="docker-1.7.0-dev-experimental"
flockerrepo="https://github.com/clusterhq/flocker"
flockerbranch="disconnnect-datasets-from-containers-FLOC-2163"
filechanged="node/agents/blockdevice.py"
flockerinstalled="/opt/flocker/lib/python2.7/site-packages/flocker"


patch-docker() {
    do-ssh $1 "sudo stop docker.io || true"
    scp -o stricthostkeychecking=no -i $key $binaryfolder/$binaryname root@$1:/usr/bin/docker
    do-ssh $1 "sudo start docker.io"
    do-ssh $1 "sudo stop flocker-plugin || true"
    do-ssh $1 "sudo start flocker-plugin"
}

do-ssh() {
    echo "ssh -o stricthostkeychecking=no -i $key ubuntu@$1 $2"
    ssh -o stricthostkeychecking=no -i $key root@$1 $2
}

patch-flocker() {
    do-ssh $1 "sudo rm -rf /home/ubuntu/flocker"
    do-ssh $1 "cd /home/ubuntu && git clone -b $flockerbranch $flockerrepo"
    do-ssh $1 "sudo stop flocker-dataset-agent || true"
    do-ssh $1 "sudo cp /home/ubuntu/flocker/flocker/$filechanged $flockerinstalled/$filechanged"
    do-ssh $1 "sudo rm $flockerinstalled/${filechanged}c"
    do-ssh $1 "sudo start flocker-dataset-agent"
}
for X in $master $runner1 $runner2; do
    #patch-flocker $X
    patch-docker $X
done