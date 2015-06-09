#!/bin/bash

# a test of creating and moving a volume using the HTTP API
set -e

name="$1"

if [[ -z "$name" ]]; then
    echo "please give a volume name"
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd $DIR/..

vagrant ssh runner-1 -c "sudo docker run -v $name:/data --volume-driver flocker busybox sh -c \"echo hello > /data/file.txt\""

sleep 10

vagrant ssh runner-2 -c "sudo docker run -v $name:/data --volume-driver flocker busybox sh -c \"cat /data/file.txt\""