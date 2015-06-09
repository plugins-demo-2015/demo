#!/bin/bash

# install ZFS ready for Flocker
export DEBIAN_FRONTEND=noninteractive
set -e

add-apt-repository -y ppa:zfs-native/stable
apt-get update
apt-get -y install libc6-dev
apt-get -y install zfsutils