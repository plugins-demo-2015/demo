$install_docker = <<SCRIPT
cp /vagrant/.build/docker/bundles/1.7.0-dev/binary/docker-1.7.0-dev /usr/bin/docker
cp /vagrant/.build/weave/weave /usr/bin/
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq install cgroupfs-mount cgroup-lite xz-utils git
groupadd docker
usermod -a -G docker vagrant
cp /vagrant/docker.conf /etc/init/
#cp /vagrant/{docker,weave-docker-plugin}.conf /etc/init/
/sbin/start docker
#/sbin/start weave-docker-plugin
SCRIPT
