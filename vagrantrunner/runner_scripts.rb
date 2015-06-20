$install_keys = <<SCRIPT
cp /vagrant/insecure_private_key /root/.ssh/id_rsa
cp /vagrant/insecure_public_key /root/.ssh/id_rsa.pub
cat /vagrant/insecure_public_key >> /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/id_rsa /root/.ssh/id_rsa.pub
SCRIPT

$prepare_flocker = <<SCRIPT
mkdir -p /etc/flocker
mkdir -p /tmp/flocker_certs
chmod a+w /tmp/flocker_certs
SCRIPT

$flocker_node = <<SCRIPT
apt-get -y install apt-transport-https software-properties-common
service flocker-container-agent restart
service flocker-dataset-agent restart
SCRIPT

$copy_certs = <<SCRIPT
sudo cp /tmp/flocker_certs/* /etc/flocker
SCRIPT

$flocker_plugin_master = <<SCRIPT
mkdir -p /usr/share/docker/plugins

cat <<EOF > /etc/init/flocker-docker-plugin.conf
# flocker-plugin - flocker-docker-plugin job file

description "Flocker Plugin service"
author "ClusterHQ <support@clusterhq.com>"

respawn
env FLOCKER_CONTROL_SERVICE_BASE_URL=https://172.16.70.250:4523/v1
env MY_NETWORK_IDENTITY=172.16.70.250
exec /usr/local/bin/flocker-docker-plugin
EOF
service flocker-docker-plugin restart
SCRIPT

$flocker_plugin_runner = <<SCRIPT
mkdir -p /usr/share/docker/plugins

cat <<EOF > /etc/init/flocker-docker-plugin.conf
# flocker-plugin - flocker-docker-plugin job file

description "Flocker Plugin service"
author "ClusterHQ <support@clusterhq.com>"

respawn
env FLOCKER_CONTROL_SERVICE_BASE_URL=https://172.16.70.250:4523/v1
env MY_NETWORK_IDENTITY=172.16.70.251
exec /usr/local/bin/flocker-docker-plugin
EOF
service flocker-docker-plugin restart
SCRIPT

$flocker_control = <<SCRIPT
cat <<EOF > /etc/init/flocker-control.override
start on runlevel [2345]
stop on runlevel [016]
EOF
echo 'flocker-control-api       4523/tcp                        # Flocker Control API port' >> /etc/services
echo 'flocker-control-agent     4524/tcp                        # Flocker Control Agent port' >> /etc/services
service flocker-control restart
ufw allow flocker-control-api
ufw allow flocker-control-agent
SCRIPT