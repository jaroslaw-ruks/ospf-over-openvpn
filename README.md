# ospf-over-openvpn

Base on https://www.unixadm.org/needful-things/openvpn-ospf. Point is connect
multiple localization over openvpn and use ospf (bird) for detect new network.
In scenario only 1 point use public adres IP and it will be openvpn hub. 
I will try to create openvpn client with bird but only as "endpoint" client
without passing traffic. More generic and autodetec configuration then better :) 

## Network Schema

![alt pic/Network_Schema.dia](pic/Network_Schema.png)

### Idea

Use bird to "autodetect" another networks, make it quite secure (Openvpn). Make it easy, repeatable and generic. 

- 1 public IP address (VPN-HUB)
- rest of node can be hidden by nat
- create configration for endpoint: only import networks, don't inform rest about endpoint network configuration.

### Current State
Openvpn use TAP 
OSPF have broadcast connection.

To do:
- Change Openvpn to TUN and OSPF into PTMP instead Broadcast connection.
- Include init.sh script into Vagrant file (one command for pull setup)