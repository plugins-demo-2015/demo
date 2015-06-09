#!/bin/bash

# this is the second stage where we install everything onto
# a running Amazon instance
export DEBIAN_FRONTEND=noninteractive
set -e

# vars
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/storage-driver-configuration-FLOC-1925/ubuntu-14.04"
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/0.4.1dev3/ubuntu-14.04"
#BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/missing-size-default-FLOC-2084/ubuntu-14.04"
BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/master/ubuntu-14.04"
CGROUPSFS_FOLDER="http://ftp.uk.debian.org/debian/pool/main/c/cgroupfs-mount"
CGROUPSFS_BINARY="cgroupfs-mount_1.2_all.deb"
COMPILED_FILES="/vagrant/compiled/files"
PLUGIN_REPO="https://github.com/clusterhq/flocker-docker-plugin"
PLUGIN_BRANCH="maximum-size"

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
  git

# there is no package for cgroupfs-mount on Ubuntu 14.04 so we install manually
cd ~ && wget $CGROUPSFS_FOLDER/$CGROUPSFS_BINARY && dpkg -i $CGROUPSFS_BINARY

# install flocker
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli

# copy weave script
curl -L -o /usr/bin/weave https://github.com/weaveworks/weave/releases/download/latest_release/weave
chmod a+x /usr/bin/weave

# clone and install the flocker-docker-plugin
git clone -b $PLUGIN_BRANCH $PLUGIN_REPO /root/flocker-docker-plugin
pip install -r /root/flocker-docker-plugin/requirements.txt

# setup docker - this involves removing the docker.io package installed alongside flocker
stop docker.io
cp $COMPILED_FILES/docker /usr/bin/docker
chmod a+x /usr/bin/docker
cp /vagrant/docker.conf /etc/init/docker.io.conf
start docker.io
sleep 2

# import docker images (created by the compiler)
for i in $COMPILED_FILES/*.tar
do docker load -i $i
done

docker pull busybox:latest
docker pull redis:latest
docker pull python:2.7
docker pull errordeveloper/iojs-minimal-runtime:v1.0.1