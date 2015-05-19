VAGRANTFILE_API_VERSION = "2"

$tester_vms = 3
$network = [172, 17, 85]

$cleanup = <<SCRIPT
export DEBIAN_FRONTEND=noninteractive
## Who the hell thinks official images have to have both of these?
apt-get -qq remove puppet chef
apt-get -qq autoremove
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/ubuntu-14.10-amd64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/utopic/current/utopic-server-cloudimg-amd64-vagrant-disk1.box"


  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
  end

  vms = (1..$tester_vms).map{ |a| "tester-#{a}" } << 'builder'

  ips = {}

  vms.each_with_index{ |i, x| ips[i] = ($network + [x+100]).join('.') }

  vms.each do |i|
    config.vm.define vm_name = i do |config|
      config.vm.hostname = vm_name

      config.vm.network "private_network", ip: ips[vm_name] # type: "dhcp"

      case vm_name
      when 'builder'

        config.vm.provider :virtualbox do |vb|
          vb.memory = 4096
          vb.cpus = 2
        end

        load 'builder_scripts.rb'
        config.vm.synced_folder "./.build/docker", "/home/vagrant/src/github.com/docker/docker"
        config.vm.synced_folder "./.build/weave", "/home/vagrant/src/github.com/weaveworks/weave"

        config.vm.provision :docker, :images => [ "ubuntu:14.04", "gliderlabs/alpine:latest" ]

        config.vm.provision :shell, :inline => $install_build_deps
        config.vm.provision :shell, :inline => $tweak_user_env, :privileged => false
        config.vm.provision :shell, :inline => $tweak_docker_daemon

      when /tester-\d/

        config.vm.provider :virtualbox do |vb|
          vb.memory = 2048
          vb.cpus = 2
        end

        load 'tester_scripts.rb'
        config.vm.provision :shell, :inline => $install_docker

        ips.each do |host,addr|
          config.vm.provision :shell,
            :inline => "weave connect #{addr}" if host !~ /builder|#{vm_name}/
        end

        config.vm.provision :docker do |d|
          d.pull_images "busybox:latest", "redis:latest"
          d.build_image "/vagrant/app", args: "-t app_web"
        end

      end
      config.vm.provision :shell, :inline => $cleanup
    end
  end
end

begin
  load 'Vagrantfile.local'
rescue LoadError
end
