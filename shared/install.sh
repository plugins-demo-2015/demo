#!/bin/bash

# this is the second stage where we install everything onto
# a running Amazon instance
export DEBIAN_FRONTEND=noninteractive
set -ex

weave_release_old='0.11.2'
weave_release_new='1.0.1'

# vars
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/storage-driver-configuration-FLOC-1925/ubuntu-14.04"
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/0.4.1dev3/ubuntu-14.04"
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/missing-size-default-FLOC-2084/ubuntu-14.04"
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/master/ubuntu-14.04"
BASE_DEB_FOLDER="https://clusterhq-archive.s3.amazonaws.com/ubuntu/14.04/amd64"
CGROUPSFS_FOLDER="http://ftp.uk.debian.org/debian/pool/main/c/cgroupfs-mount"
CGROUPSFS_BINARY="cgroupfs-mount_1.2_all.deb"
COMPILED_FILES="/tmp/binaries"
PLUGIN_REPO="https://github.com/clusterhq/flocker-docker-plugin"
PLUGIN_BRANCH="master"

# deps
add-apt-repository -y ppa:james-page/docker
add-apt-repository -y "deb $BASE_DEB_FOLDER /"
apt-get -qq update

apt-get install -y \
  linux-image-extra-$(uname -r) \
  apt-transport-https \
  software-properties-common \
  cgroup-lite \
  xz-utils \
  python-dev \
  python-pip \
  python-openssl \
  build-essential \
  libssl-dev \
  libffi-dev \
  git

# there is no package for cgroupfs-mount on Ubuntu 14.04 so we install manually
cd ~ && wget $CGROUPSFS_FOLDER/$CGROUPSFS_BINARY && dpkg -i $CGROUPSFS_BINARY

# install flocker
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli

# copy weave scripts
curl -s -L -o /usr/bin/weave_$weave_release_old https://github.com/weaveworks/weave/releases/download/v$weave_release_old/weave
curl -s -L -o /usr/bin/weave_$weave_release_new https://github.com/weaveworks/weave/releases/download/v$weave_release_new/weave
chmod a+x /usr/bin/weave_$weave_release_old
chmod a+x /usr/bin/weave_$weave_release_new

# copy scope script
cp /tmp/binaries/scope /usr/bin/scope
chmod a+x /usr/bin/scope

# copy swarm binary
cp /tmp/binaries/swarm /usr/bin/swarm
chmod a+x /usr/bin/swarm

# install the flocker plugin from git using pip
pip install git+$PLUGIN_REPO@$PLUGIN_BRANCH

# setup docker - this involves removing the docker.io package installed alongside flocker
stop docker.io
cp $COMPILED_FILES/docker /usr/bin/docker
chmod a+x /usr/bin/docker
cp /tmp/dockerupstart.conf /etc/init/docker.io.conf
cp /tmp/dockerdefaults /etc/default/docker.io
start docker.io
sleep 5

docker pull busybox:latest
docker pull redis:latest
docker pull python:2.7
docker pull errordeveloper/iojs-minimal-runtime:v1.0.1
docker pull weaveworks/weave:$weave_release_old
docker pull weaveworks/weavedns:$weave_release_old
docker pull weaveworks/weaveexec:$weave_release_old
docker pull weaveworks/weave:$weave_release_new
docker pull weaveworks/weavedns:$weave_release_new
docker pull weaveworks/weaveexec:$weave_release_new
docker pull binocarlos/ubunturedis:latest
docker pull binocarlos/moby-counter:latest
docker pull clusterhq/experimental-volumes-gui:latest
docker pull gliderlabs/alpine:latest
docker load -i $COMPILED_FILES/plugin.$weave_release_old.tar
docker load -i $COMPILED_FILES/plugin.$weave_release_new.tar
docker load -i $COMPILED_FILES/scope.tar

# install compose
git clone --depth 15 --single-branch --branch publish_service https://github.com/binocarlos/compose /root/compose
(cd /root/compose; pip install -r requirements.txt; python setup.py install)

# nuke docker engine id
stop docker.io
rm -f /etc/docker/key.json
