  # -*- mode: ruby -*-
# vi: set ft=ruby :
public_network = "public"
site1_network = "site1"
site2_network = "site2"
$init_script = <<-SHELL
export DEBIAN_FRONTEND=noninteractive;
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
apt-get update;
apt-get install tcpdump vim  -y
mkdir -p /root/.ssh/
cp /vagrant/files/{id_rsa,id_rsa.pub} /root/.ssh/
chmod 644 /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa
chmod 700 /root/.ssh
cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
cp /vagrant/files/config /root/.ssh/config
SHELL

$custom_site = <<-SHELL
internal=eth2
external=eth1

/sbin/iptables -t nat -A POSTROUTING -o $external -j MASQUERADE
/sbin/iptables -A FORWARD -i $external -o $internal -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i $internal -o $external -j ACCEPT

SHELL

$custom_client = <<-SHELL
ip route add 192.168.111.0/24 via $(hostname -I |awk '{print $2}' | sed 's/20/10/g')
apt-get install openvpn -y
cp /vagrant/files/client.conf /etc/openvpn/client/$(hostname).conf
sed -i -e 's/_IP_/'"$(hostname -I |awk -F. '{print $2}')"'/' /etc/openvpn/client/$(hostname).conf
sed -i -e 's/_HOSTNAME_/'"$(hostname)"'/' /etc/openvpn/client/$(hostname).conf
cp /vagrant/files/vpn/{dh2048.pem,ca.crt,`hostname`.{crt,key}} /etc/openvpn/client/
systemctl daemon-reload 
systemctl restart openvpn-client@$(hostname).service
SHELL

$custom_server = <<-SHELL
apt-get install openvpn -y
cp /vagrant/files/server.conf /etc/openvpn/server/
sed -i -e 's/_IP_/'"$(hostname -I | awk '{print $2}')"'/' /etc/openvpn/server/server.conf
systemctl daemon-reload 

conf=0
for file in /vagrant/files/vpn/{ca.{crt,key},dh2048.pem,{client{1,2},vpn-hub}.{key,crt}} 
do
if [[ ! -e $file  ]]
then
echo "missing config, create new one"
conf=1
break
fi
done
if  [[ $conf == 1 ]]
  then
    cd /usr/share/easy-rsa/ && . vars && ./clean-all && ln -s openssl-1.0.0.cnf openssl.cnf \
    && ./build-dh && ./pkitool --initca 
    cp /usr/share/easy-rsa/keys/{dh2048.pem,ca.crt} /etc/openvpn/server/
    cp /usr/share/easy-rsa/keys/{dh2048.pem,ca.{crt,key}} /home/vagrant/
    cd /usr/share/easy-rsa/ && . vars && ./pkitool --server vpn-hub
    cp /usr/share/easy-rsa/keys/vpn-hub.{crt,key} /etc/openvpn/server/
    cp /usr/share/easy-rsa/keys/vpn-hub.{crt,key} /home/vagrant/
    for node in client{1,2}
    do
      cd /usr/share/easy-rsa/ && . vars && ./pkitool $node
      cp /usr/share/easy-rsa/keys/$node.{crt,key} /home/vagrant/
    done
    cp /usr/share/easy-rsa/keys/{dh2048.pem,ca.crt} /home/vagrant/
    chown vagrant:vagrant /home/vagrant/*
  else
    cd /usr/share/easy-rsa/ && . vars &&  ln -s openssl-1.0.0.cnf openssl.cnf && ./clean-all
    cp /vagrant/files/vpn/{ca.{crt,key},dh2048.pem} /usr/share/easy-rsa/keys/
    chown root:root /usr/share/easy-rsa/keys/{ca.{crt,key},dh2048.pem}
    cp /vagrant/files/vpn/{dh2048.pem,ca.crt,vpn-hub.{key,crt}} /etc/openvpn/server/
fi 
systemctl daemon-reload 
systemctl restart openvpn-server@server.service
SHELL

$finnish = <<-SHELL
apt-get install bird -y
cp /vagrant/files/bird.conf /etc/bird/bird.conf
sed -i -e "s/_IP_/`hostname -I | awk '{print $NF}'`/g"  /etc/bird/bird.conf 
systemctl restart bird.service
SHELL

vm_box ="debian/stretch64"
Vagrant.configure("2") do |config|
  config.vm.define "vpn-hub" do |vpn|
    vpn.vm.box=vm_box
    vpn.vm.hostname = "vpn-hub"
    vpn.vm.network "private_network", ip:"192.168.111.10", netmask: "255.255.255.0", virtualbox__intnet: public_network
    vpn.vm.network "private_network", ip:"192.168.201.10", netmask: "255.255.255.0", virtualbox__intnet: vpn.vm.hostname
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
    site1.vm.network "private_network", ip:"192.168.111.20", netmask: "255.255.255.0", virtualbox__intnet: public_network
    site1.vm.network "private_network", ip:"192.168.211.10", netmask: "255.255.255.0", virtualbox__intnet: site1_network
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
    site1.vm.provision "custom_site", 
      type:"shell",
      preserve_order:true,
      inline: $custom_site,
      run: "once"
    #site1.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
  end
    config.vm.define "client1" do |client1|
    client1.vm.box=vm_box
    client1.vm.network "private_network", ip:"192.168.211.20", netmask: "255.255.255.0", virtualbox__intnet: site1_network
    client1.vm.network "private_network", ip:"192.168.212.10", netmask: "255.255.255.0", virtualbox__intnet: "client1"
    client1.vm.hostname = "client1"
    client1.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = client1.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    client1.vm.provision "shell", inline: $init_script, run: "once"
    client1.vm.provision "shell", inline: $custom_client, run: "once"
    client1.vm.provision "shell", inline: $finnish, run: "once"
    #client.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
  end
#=begin 
  config.vm.define "site2" do |site2|
    site2.vm.box=vm_box
    site2.vm.hostname = "site2"
    site2.vm.network "private_network", ip:"192.168.111.30", netmask: "255.255.255.0", virtualbox__intnet: public_network
    site2.vm.network "private_network", ip:"192.168.221.10", netmask: "255.255.255.0", virtualbox__intnet: site2_network
    site2.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = site2.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    site2.vm.provision "shell", inline: $init_script, run: "once"
    site2.vm.provision "shell", inline: $custom_site, run: "once"
    
    #site2.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
  end
    config.vm.define "client2" do |client2|
    client2.vm.box=vm_box
    client2.vm.network "private_network", ip:"192.168.221.20", netmask: "255.255.255.0", virtualbox__intnet: site2_network
    client2.vm.hostname = "client2"
    client2.vm.provider "virtualbox" do  |vbox_conf|
      vbox_conf.name = client2.vm.hostname
      vbox_conf.cpus = 1
      vbox_conf.memory = 512
      vbox_conf.gui = false
      vbox_conf.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--nonrotational", "on"]
      vbox_conf.customize ["modifyvm",:id,"--groups","/ospf-over-openvpn"]
    end
    client2.vm.provision "shell", inline: $init_script, run: "once"
    client2.vm.provision "shell", inline: $custom_client, run: "once"
    client2.vm.provision "shell", inline: $finnish, run: "once"
    #client.vm.provision "file", source: "./files/config", destination: "/root/.ssh/config"
  end
#=end
end


