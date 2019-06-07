# -*- mode: ruby -*-
# vi: set ft=ruby :
#system("openvpn --genkey --secret openvpn_key.key;done")
system("if [ ! -e id_rsa ]; then ssh-keygen -f ./id_rsa  -N ''; fi ;")
#puts system(`pwd`)
$init_script = <<-SHELL
export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get install tcpdump vim openvpn -y
cp /vagrant/openvpn_key.key /etc/openvpn/
mkdir -p /root/.ssh/
cp /vagrant/{id_rsa,id_rsa.pub} /root/.ssh/
chmod 644 /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa
chmod 700 /root/.ssh
cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
SHELL
$init_script= <<-SHELL
echo "init_script"
SHELL
$custom_client = <<-SHELL
cp /vagrant/client.conf /etc/openvpn/
sed -i -e 's/_IP_/'"$(hostname -I |awk -F. '{print $NF}')"'/' /etc/openvpn/client.conf
systemctl daemon-reload 
SHELL
$custom_client = <<-SHELL
echo "custom_client"
SHELL
$custom_server = <<-SHELL
cp /vagrant/server.conf /etc/openvpn/
sed -i -e 's/_IP_/'"$(hostname -I | awk '{print $NF}')"'/' /etc/openvpn/server.conf
systemctl daemon-reload 
cd /usr/share/easy-rsa/ && . vars && ./clean-all && ln -s openssl-1.0.0.cnf openssl.cnf \
  && ./build-dh && ./pkitool --initca && ./pkitool --server vpn-hub
SHELL
$custom_server = <<-SHELL
echo "custom_server"
SHELL
vm_box ="debian/stretch64"
Vagrant.configure("2") do |config|
  config.vm.define "vpn-hub" do |vpn|
    vpn.vm.box=vm_box
    vpn.vm.network "private_network", ip:"192.168.101.10", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    vpn.vm.hostname = "vpn-hub"
    vpn.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = vpn.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    vpn.vm.provision "init_script",
      type:"shell", 
      preserve_order:true, 
      inline:$init_script
    vpn.vm.provision "custom_server", 
      type:"shell",
      preserve_order:true,
      inline:$custom_server
  end
  

  config.vm.define "site-1" do |site1|
    site1.vm.box=vm_box
    site1.vm.network "private_network", ip:"192.168.101.20", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    site1.vm.hostname = "site-1"
    site1.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = site1.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    site1.vm.provision "init_script",
      type:"shell", 
      preserve_order:true, 
      inline: $init_script
    site1.vm.provision "custom_client", 
      type:"shell",
      preserve_order:true,
      inline: $custom_client
  end
  
  config.vm.define "site-2" do |site2|
    site2.vm.box=vm_box
    site2.vm.network "private_network", ip:"192.168.101.30", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    site2.vm.hostname = "site-2"
    site2.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = site2.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    site2.vm.provision "shell", inline: $init_script
    site2.vm.provision "shell", inline: $custom_client
  end

    config.vm.define "client" do |client|
    client.vm.box=vm_box
    client.vm.network "private_network", ip:"192.168.101.40", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    client.vm.hostname = "client"
    client.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = client.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    client.vm.provision "shell", inline: $init_script
    client.vm.provision "shell", inline: $custom_client
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
