#!/bin/bash

BASE_FOLDER="http://build.clusterhq.com/results/omnibus/storage-driver-configuration-FLOC-1925/ubuntu-14.04"
# BASE_FOLDER="https://clusterhq-archive.s3.amazonaws.com/ubuntu-testing/14.04/$(ARCH)"

apt-get -y install apt-transport-https software-properties-common
add-apt-repository -y ppa:james-page/docker
add-apt-repository -y "deb $BASE_FOLDER /"
apt-get update
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli