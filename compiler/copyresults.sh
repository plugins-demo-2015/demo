#!/bin/sh

# copy the results of the compilation out into the amibuilder folder ready for the next step

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
AMI_TARGET_DIR="$DIR/../amibuilder/compiled/files"
VAGRANT_TARGET_DIR="$DIR/../vagrantbuilder/compiled/files"
DOCKER_NAME="1.7.0-dev"

copy-files() {
    local TARGET_DIR="$1";
    mkdir -p $TARGET_DIR
    echo "Copying docker"
    cp $DIR/.build/docker/bundles/$DOCKER_NAME/binary/docker-$DOCKER_NAME $TARGET_DIR/docker
    echo "Copying images"
    cp $DIR/.build/docker-plugin/*.tar $TARGET_DIR
}

copy-files $AMI_TARGET_DIR
copy-files $VAGRANT_TARGET_DIR