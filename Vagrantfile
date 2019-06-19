  # -*- mode: ruby -*-
# vi: set ft=ruby :
#system("openvpn --genkey --secret openvpn_key.key;done")
system("if [ ! -e ./files/id_rsa ]; then ssh-keygen -f ./files/id_rsa  -N ''; fi ;")
#puts system(`pwd`)
$init_script = <<-SHELL
export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get install tcpdump vim openvpn -y
mkdir -p /root/.ssh/
cp /vagrant/files/{id_rsa,id_rsa.pub} /root/.ssh/
chmod 644 /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa
chmod 700 /root/.ssh
cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
cp /vagrant/files/config /root/.ssh/config
SHELL

$custom_client = <<-SHELL
cp /vagrant/files/client.conf /etc/openvpn/client/$(hostname).conf
sed -i -e 's/_IP_/'"$(hostname -I |awk -F. '{print $2}')"'/' /etc/openvpn/client/$(hostname).conf
sed -i -e 's/_HOSTNAME_/'"$(hostname)"'/' /etc/openvpn/client/$(hostname).conf
rsync -avu -P vpn-hub:/usr/share/easy-rsa/keys/{dh2048.pem,ca.crt,`hostname`.{crt,key}} /etc/openvpn/client/
systemctl daemon-reload 
systemctl restart openvpn-client@$(hostname).service
SHELL

$custom_l2 = <<-SHELL
ip route add 192.168.101.0/24 via 192.168.202.1 dev eth1 
SHELL

$custom_server = <<-SHELL
cp /vagrant/files/server.conf /etc/openvpn/server/
sed -i -e 's/_IP_/'"$(hostname -I | awk '{print $2}')"'/' /etc/openvpn/server/server.conf
systemctl daemon-reload 
cd /usr/share/easy-rsa/ && . vars && ./clean-all && ln -s openssl-1.0.0.cnf openssl.cnf \
  && ./build-dh && ./pkitool --initca && ./pkitool --server vpn-hub

cp /usr/share/easy-rsa/keys/{dh2048.pem,ca.crt,vpn-hub.{crt,key}} /etc/openvpn/server/
for node in site{11,2} client
do
  cd /usr/share/easy-rsa/ && . vars && ./pkitool $node
done
systemctl daemon-reload 
systemctl restart openvpn-server@server.service
SHELL
$finnish = <<-SHELL
apt-get install bird -y
cp /vagrant/files/bird.conf /etc/bird/bird.conf
sed -i -e "s/_IP_/`hostname -I | awk '{print $NF}'`/g"  /etc/bird/bird.conf 
systemctl restart bird.service
SHELL

$custom_router = <<-SHELL
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth2 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT
SHELL

vm_box ="debian/stretch64"
Vagrant.configure("2") do |config|
  config.vm.define "vpn-hub" do |vpn|
    vpn.vm.box=vm_box
    vpn.vm.hostname = "vpn-hub"
    vpn.vm.network "private_network", ip:"192.168.101.10", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    vpn.vm.network "private_network", ip:"192.168.201.1", netmask: "255.255.255.0", virtualbox__intnet: vpn.vm.hostname
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
      inline:$init_script,
      run: "once"
    vpn.vm.provision "custom_server", 
      type:"shell",
      preserve_order:true,
      inline:$custom_server,
      run: "once"
    vpn.vm.provision "finnish", 
      type:"shell",
     preserve_order:true,
      inline:$finnish,
      run: "once"
    #vpn.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
  end
  

  config.vm.define "site1" do |site1|
    site1.vm.box=vm_box
    site1.vm.hostname = "site1"
    site1.vm.network "private_network", ip:"192.168.101.20", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    site1.vm.network "private_network", ip:"192.168.202.1", netmask: "255.255.255.0", virtualbox__intnet: site1.vm.hostname
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
      inline: $init_script,
      run: "once"
    site1.vm.provision "custom_router", 
      type:"shell",
      preserve_order:true,
      inline: $custom_client,
      run: "once"
    #site1.vm.provision "finnish", 
    #  type:"shell",
    #  preserve_order:true,
    #  inline:$finnish,
    #  run: "once"
    #site1.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
  end

    config.vm.define "site11" do |site11|
    site11.vm.box=vm_box
    site11.vm.hostname = "site11"
    site11.vm.network "private_network", ip:"192.168.202.2", netmask: "255.255.255.0", virtualbox__intnet: "site1"
    site11.vm.network "private_network", ip:"192.168.212.1", netmask: "255.255.255.0", virtualbox__intnet: site11.vm.hostname
    site11.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = site11.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    site11.vm.provision "custom_l2",
      type:"shell",
      preserve_order:true,
      inline:$custom_l2,
      run: "once"
    #site11.vm.provision "init_script",
    #  type:"shell", 
    #  preserve_order:true, 
    #  inline: $init_script,
    #  run: "once"
    #site11.vm.provision "custom_client", 
    #  type:"shell",
    #  preserve_order:true,
    #  inline: $custom_client,
    #  run: "once"

    site11.vm.provision "finnish", 
      type:"shell",
      preserve_order:true,
      inline:$finnish,
      run: "once"
    #site1.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
  end

  config.vm.define "site2" do |site2|
    site2.vm.box=vm_box
    site2.vm.hostname = "site2"
    site2.vm.network "private_network", ip:"192.168.101.30", netmask: "255.255.255.0", virtualbox__intnet: "ospf-over-openvpn"
    site2.vm.network "private_network", ip:"192.168.203.1", netmask: "255.255.255.0", virtualbox__intnet: site2.vm.hostname
    site2.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = site2.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    site2.vm.provision "shell", inline: $init_script, run: "once"
    site2.vm.provision "shell", inline: $custom_client, run: "once"
    site2.vm.provision "shell", inline: $finnish, run: "once"
    #site2.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
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
    client.vm.provision "shell", inline: $init_script, run: "once"
    client.vm.provision "shell", inline: $custom_client, run: "once"
    client.vm.provision "shell", inline: $finnish, run: "once"
    #client.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
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

