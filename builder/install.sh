#!/bin/bash

# this is the second stage where we install everything onto
# a running Amazon instance
export DEBIAN_FRONTEND=noninteractive

# vars
FLOCKER_ZPOOL_SIZE = '10G'
FLOCKER_PREFIX = '/var/opt/flocker'

BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/storage-driver-configuration-FLOC-1925/ubuntu-14.04"

# deps
add-apt-repository -y ppa:zfs-native/stable
add-apt-repository -y ppa:james-page/docker
add-apt-repository -y "deb $BASE_DEB_FOLDER /"
apt-get -qq update

apt-get install -y \
  apt-transport-https \
  software-properties-common \
  cgroupfs-mount \
  cgroup-lite \
  xz-utils \
  libc6-dev \
  zfsutils

# zpool
mkdir -p $FLOCKER_PREFIX
truncate --size $FLOCKER_ZPOOL_SIZE $FLOCKER_PREFIX/pool-vdev
zpool create flocker $FLOCKER_PREFIX/pool-vdev

# install flocker
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli

# copy docker/weave binaries
cp /vagrant/.build/docker/bundles/1.7.0-dev-experimental/binary/docker-1.7.0-dev-experimental /usr/bin/docker
cp /vagrant/.build/weave/weave /usr/bin/

# setup docker
groupadd docker
usermod -a -G docker vagrant
cp /vagrant/docker.conf /etc/init/
start docker
sleep 2

# import docker images
for i in /vagrant/.build/weave/*.tar
do docker load -i $i
done