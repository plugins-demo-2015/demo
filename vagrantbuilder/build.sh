#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
set -e

unixsecs=$(date +%s)
vagrant up
vagrant package
mv package.box vagrant${unixsecs}.box
echo "Vagrant box has been created"
echo vagrant${unixsecs}.box