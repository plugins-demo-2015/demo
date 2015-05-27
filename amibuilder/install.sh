#!/bin/bash

# this is the second stage where we install everything onto
# a running Amazon instance
export DEBIAN_FRONTEND=noninteractive
set -e

# vars
BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/storage-driver-configuration-FLOC-1925/ubuntu-14.04"
CGROUPSFS_FOLDER="http://ftp.uk.debian.org/debian/pool/main/c/cgroupfs-mount"
CGROUPSFS_BINARY="cgroupfs-mount_1.2_all.deb"
COMPILED_FILES="/vagrant/compiled/files"

# deps
add-apt-repository -y ppa:zfs-native/stable
add-apt-repository -y ppa:james-page/docker
add-apt-repository -y "deb $BASE_DEB_FOLDER /"
apt-get -qq update

apt-get install -y \
  apt-transport-https \
  software-properties-common \
  cgroup-lite \
  xz-utils

# there is no package for cgroupfs-mount on Ubuntu 14.04 so we install manually
cd ~ && wget $CGROUPSFS_FOLDER/$CGROUPSFS_BINARY && dpkg -i $CGROUPSFS_BINARY

# install flocker
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli

# copy weave script
cp $COMPILED_FILES/weave /usr/bin/
chmod a+x /usr/bin/weave

# setup docker
service docker.io stop
cp $COMPILED_FILES/docker /usr/bin/docker
chmod a+x /usr/bin/docker
groupadd docker || true
usermod -a -G docker vagrant
cp /vagrant/docker.conf /etc/init/
start docker
sleep 2

# import docker images (created by the compiler)
for i in $COMPILED_FILES/*.tar
do docker load -i $i
done

docker pull busybox:latest redis:latest python:2.7 errordeveloper/iojs-minimal-runtime:v1.0.1