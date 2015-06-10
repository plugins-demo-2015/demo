flocker_zpool_size = '10G'
flocker_prefix = '/var/opt/flocker'

docker_bin = '/vagrant/.build/docker/bundles/1.7.0-dev/binary/docker'
# /vagrant/.build/docker/bundles/1.7.0-dev-experimental/binary/docker-1.7.0-dev-experimental

$install_docker = <<SCRIPT
cp #{docker_bin} /usr/bin/docker
sudo curl --silent --location \
  --output /usr/bin/weave \
  https://github.com/weaveworks/weave/releases/download/v#$weave_release/weave
sudo chmod a+x /usr/bin/weave
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq install cgroupfs-mount cgroup-lite xz-utils git
groupadd docker
usermod -a -G docker vagrant
cp /vagrant/docker.conf /etc/init/
start docker
sleep 2
for i in /vagrant/.build/docker-plugin/*.tar
do docker load -i $i
done
SCRIPT

$create_flocker_zpool = <<SCRIPT
mkdir -p #{flocker_prefix}
truncate --size #{flocker_zpool_size} #{flocker_prefix}/pool-vdev
zpool create flocker #{flocker_prefix}/pool-vdev
SCRIPT
