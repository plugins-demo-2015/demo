go_path = "/usr/local/go/bin"

$install_build_deps = <<SCRIPT
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -qq --no-install-recommends \
  build-essential ethtool iputils-arping libpcap-dev git mercurial bc
curl -s https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz \
  | tar xz -C /usr/local
chown -R vagrant:vagrant ~vagrant/src
#{go_path}/go clean -i net
#{go_path}/go install -tags netgo std
SCRIPT

$tweak_user_env = <<SCRIPT
echo 'export GOPATH="${HOME}"' \
  >> ~vagrant/.profile
echo 'export PATH="${HOME}/bin:#{go_path}:${PATH}"' \
  >> ~vagrant/.profile
SCRIPT

$tweak_docker_daemon = <<SCRIPT
usermod -a -G docker vagrant
echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375"' >> /etc/default/docker
service docker restart
SCRIPT
