#!/bin/bash

# this is the second stage where we install everything onto
# a running Amazon instance
export DEBIAN_FRONTEND=noninteractive
set -ex

weave_release='0.11.2'

# vars
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/storage-driver-configuration-FLOC-1925/ubuntu-14.04"
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/0.4.1dev3/ubuntu-14.04"
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/missing-size-default-FLOC-2084/ubuntu-14.04"
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/master/ubuntu-14.04"
BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/more-valid-state-invalidation-FLOC-2135/ubuntu-14.04"
CGROUPSFS_FOLDER="http://ftp.uk.debian.org/debian/pool/main/c/cgroupfs-mount"
CGROUPSFS_BINARY="cgroupfs-mount_1.2_all.deb"
COMPILED_FILES="/vagrant/compiled/files"
PLUGIN_REPO="https://github.com/robhaswell/flocker-docker-plugin"
PLUGIN_BRANCH="setup.py-LABS-93"

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
  build-essential \
  libssl-dev \
  libffi-dev \
  git

# there is no package for cgroupfs-mount on Ubuntu 14.04 so we install manually
cd ~ && wget $CGROUPSFS_FOLDER/$CGROUPSFS_BINARY && dpkg -i $CGROUPSFS_BINARY

# install flocker
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli

# copy weave script
curl -L -o /usr/bin/weave https://github.com/weaveworks/weave/releases/download/v$weave_release/weave
chmod a+x /usr/bin/weave

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
docker pull weaveworks/weave:$weave_release
docker pull weaveworks/weavedns:$weave_release
docker pull weaveworks/weaveexec:$weave_release
docker pull binocarlos/ubunturedis:latest
docker pull binocarlos/moby-counter:latest
docker pull clusterhq/experimental-volumes-gui:latest
docker pull gliderlabs/alpine:latest
docker load -i $COMPILED_FILES/plugin.tar

# install compose
git clone --depth 15 --single-branch --branch volume_driver https://github.com/lukemarsden/compose /root/compose
(cd /root/compose; pip install -r requirements.txt; python setup.py install)

# nuke docker engine id
stop docker.io
rm -f /etc/docker/key.json
