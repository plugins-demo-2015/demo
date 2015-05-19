VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/ubuntu-14.10-amd64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/utopic/current/utopic-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network "private_network", type: "dhcp"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
  end

  %w(builder tester-1 tester-2).each do |i|
    config.vm.define vm_name = i do |config|
      config.vm.hostname = vm_name

      if vm_name == 'builder' then
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
      else
      end
      ## Who the hell thinks official images has to have both of these?
      config.vm.provision :shell, :inline => 'apt-get remove puppet chef'
    end
  end
end

begin
  load 'Vagrantfile.local'
rescue LoadError
end
