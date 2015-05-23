flocker_zpool_size = '10G'
flocker_prefix = '/var/opt/flocker'

$install_docker = <<SCRIPT
#cp /vagrant/.build/docker/bundles/1.7.0-dev/binary/docker-1.7.0-dev /usr/bin/docker
# this is the docker with DOCKER_EXPERIMENTAL=1
cp /vagrant/.build/docker/bundles/1.7.0-dev-experimental/binary/docker-1.7.0-dev-experimental /usr/bin/docker
cp /vagrant/.build/weave/weave /usr/bin/
export DEBIAN_FRONTEND=noninteractive
add-apt-repository -y ppa:zfs-native/stable
apt-get -qq update
apt-get -qq install cgroupfs-mount cgroup-lite xz-utils git libc6-dev zfsutils
groupadd docker
usermod -a -G docker vagrant
cp /vagrant/docker.conf /etc/init/
start docker
sleep 2
for i in /vagrant/.build/weave/*.tar
do docker load -i $i
done
SCRIPT

$create_flocker_zpool = <<SCRIPT
mkdir -p #{flocker_prefix}
truncate --size #{flocker_zpool_size} #{flocker_prefix}/pool-vdev
zpool create flocker #{flocker_prefix}/pool-vdev
SCRIPT
