#!/bin/bash

# install ZFS ready for Flocker
export DEBIAN_FRONTEND=noninteractive
set -e

#add-apt-repository -y ppa:zfs-native/stable
#apt-get update
#apt-get -y install libc6-dev
#apt-get -y install zfsutils


# used the pinned, compiled version of ZFS
git clone https://github.com/binocarlos/flocker-base-install /tmp/flocker-base-install
source /tmp/flocker-base-install/ubuntu/install.sh
flocker-base-install