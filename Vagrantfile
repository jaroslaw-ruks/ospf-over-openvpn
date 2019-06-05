# -*- mode: ruby -*-
# vi: set ft=ruby :

$init_script = <<-SHELL
export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get install tcpdump vim openvpn -y
SHELL

vm_box ="debian/stretch64"
Vagrant.configure("2") do |config|
  config.vm.define "vpn-hub" do |conf|
    conf.vm.box=vm_box
    conf.vm.network "private_network", ip:"192.168.101.10", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    conf.vm.hostname = "vpn-hub"
    conf.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = conf.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    config.vm.provision "shell", inline: $init_script
  end
  config.vm.define "site-1" do |conf|
    conf.vm.box=vm_box
    conf.vm.network "private_network", ip:"192.168.101.20", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    conf.vm.hostname = "site-1"
    conf.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = conf.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
  end
  config.vm.define "site-2" do |conf|
    conf.vm.box=vm_box
    conf.vm.network "private_network", ip:"192.168.101.30", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    conf.vm.hostname = "site-2"
    conf.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = conf.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
  end
    config.vm.define "client" do |conf|
    conf.vm.box=vm_box
    conf.vm.network "private_network", ip:"192.168.101.40", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    conf.vm.hostname = "client"
    conf.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = conf.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
  end


  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"

  # config.vm.synced_folder "../data", "/vagrant_data"

  # config.vm.provider "virtualbox" do |vb|
  #   vb.gui = true
  #   vb.memory = "1024"
  # end
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end