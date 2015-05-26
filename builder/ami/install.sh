#!/bin/bash

add-apt-repository -y ppa:zfs-native/stable
apt-get update

FLOCKER_COMMIT='b2390369dd79fc1605c9661e20766479aeb3a644'
FLOCKER_ZPOOL_SIZE = '10G'
FLOCKER_PREFIX = '/var/opt/flocker'

wget -qO- https://get.docker.com/ | sh

apt-get install -y \
  git \
  cgroupfs-mount \
  cgroup-lite \
  xz-utils \
  python-setuptools \
  python-dev \
  libffi-dev \
  libssl-dev \
  libc6-dev \
  zfsutils

cd ~/
wget https://pypi.python.org/packages/source/m/machinist/machinist-0.2.0.tar.gz
tar zxfv machinist-0.2.0.tar.gz
cd machinist-0.2.0
python setup.py install

cd ~/
wget https://pypi.python.org/packages/source/e/eliot/eliot-0.7.1.tar.gz
tar zxfv eliot-0.7.1.tar.gz
cd eliot-0.7.1
python setup.py install

cd /opt
git clone https://github.com/clusterhq/flocker
cd flocker
git checkout $FLOCKER_COMMIT
pip install cffi
python setup.py install