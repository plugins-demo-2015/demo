VAGRANTFILE_API_VERSION = "2"

$tester_vms = 3
$network = [172, 17, 85]

$cleanup = <<SCRIPT
export DEBIAN_FRONTEND=noninteractive
## Who the hell thinks official images have to have both of these?
/etc/init.d/chef-client stop
/etc/init.d/puppet stop
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

  vms.each_with_index do |i, x|
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
        config.vm.synced_folder "./.build/docker-plugin", "/home/vagrant/src/github.com/weaveworks/docker-plugin"

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

        ## This is the Weave plugin boostrap command
        know_peers = ips.select{|host, addr| addr if host !~ /builder|#{vm_name}/}.values
        config.vm.provision :shell, :inline => %w(weave launch -iprange 10.20.0.0/16).concat(know_peers).join(' ')
        config.vm.provision :shell, :inline => "weave launch-dns 10.23.11.#{10+x}/24"

        config.vm.provision :docker do |d|
          ## This image needs to be fetched and built for standard Compose demo
          ## UNCOMENT THIS LATER, WE NEED THESE FOR THE DEMO PART
          ## BUT NOW IT SPEEDS-UP PROVISIONING TEST CYCLES
          #d.pull_images "busybox:latest", "redis:latest", "python:2.7"
          #d.build_image "/vagrant/app", args: "-t app_web"

          d.run "weaveplugin",
            image: "weaveworks/plugin",
            args: %w(
              -d
              --privileged
              --net=host
              -v /var/run/docker.sock:/var/run/docker.sock
              -v /usr/share/docker/plugins:/usr/share/docker/plugins
              -v /proc:/hostproc
            ).join(' '),
            cmd: %W(
              -nameserver=10.23.11.#{10+x}
              -debug=true
              -socket=/usr/share/docker/plugins/weave.sock
            ).join(' ')
        end

        config.vm.provision :shell, :inline => "mkdir -p /etc/flocker"
        config.vm.provision :shell,
          :inline => "echo #{ips[vm_name]} > /etc/flocker/my_address"
        config.vm.provision :shell,
          :inline => "echo #{ips['tester-1']} > /etc/flocker/master_address"

        #config.vm.provision :shell, :inline => $create_flocker_zpool

      end
      config.vm.provision :shell, :inline => $cleanup
    end
  end
end

begin
  load 'Vagrantfile.local'
rescue LoadError
end
