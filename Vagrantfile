# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don"t touch unless you know what you"re doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # copied directly from vagrant init chef/centos-6.5
  config.vm.box = "chef/centos-6.5"

  # auto-update guest additions so we can ssh into the box
  config.vbguest.auto_update = true

  # vm nodes
  config.vm.define :node2 do |node2|
    node2.vm.hostname = "node2"
    node2.vm.network :private_network, ip: "192.168.101.12"
    node2.vm.network :private_network, ip: "192.168.102.12"
    node2.vm.provider :virtualbox do |vb|
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--groups", "/rac12cR1"]
      vb.customize ["createhd", "--filename", "shared.vdi", "--size", 10*1024, "--variant", "fixed"]
      vb.customize ["modifyhd", "shared.vdi", "--type", "shareable"]
      vb.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", "shared.vdi"]
    end
  end
  config.vm.define :node1 do |node1|
    node1.vm.hostname = "node1"
    node1.vm.network :private_network, ip: "192.168.101.11"
    node1.vm.network :private_network, ip: "192.168.102.11"
    node1.vm.provider :virtualbox do |vb|
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--groups", "/rac12cR1"]
      vb.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", "shared.vdi"]
    end
  end

  # run setup.sh
  config.vm.provision "shell", path: "setup.sh"

  # proxy
  #config.proxy.http     = "http://host:port"
  #config.proxy.https    = "http://host:port"
  #config.proxy.no_proxy = "localhost,127.0.0.1"
end
