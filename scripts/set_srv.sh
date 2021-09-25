#!/bin/bash
# This script has to be executed in the server

####################
#     Variable     #
####################
INTNET_IP="10.10.8"		# Internal network IP

#################################
#     Network configuration     #
#################################
# Creates file where we specify open interfices and static or dynamic IP.
touch /etc/netplan/01-netcfg.yaml
cat << EOF >> /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system.
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: yes
      dhcp6: no
    enp0s8:
      dhcp4: no
      dhcp6: no
      addresses: [$INTNET_IP.1/24]
EOF

# Applies network changes
netplan apply

#########################
#        Routing        #
#########################
# Allows internal network to access Internet through this server.
iptables -A FORWARD -j ACCEPT
iptables -t nat -A POSTROUTING -s $INTNET_IP.0/24 -o enp0s3 -j MASQUERADE

########################
#        Docker        #
########################
# Adds one repository and updates repositories sources
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update

# Installs dependencies
Docker is already installed
apt install apt-transport-https ca-certificates curl software-properties-common

# Remove Docker if installed
if [ "$(which docker-ce)" != ""]; then
   apt-get remove docker docker-engine docker.io containerd runc
fi

# Installs Docker and Docker compose
apt install docker-ce
apt install docker-compose

# Sometimes Docker default network can cause conflict, so we're going to change default network.
touch /etc/docker/daemon.json
cat << EOF >> /etc/docker/daemon.json
{
  "default-address-pools":
  [
    {"base":"10.66.0.0/16","size":24}
  ]
}
EOF

# Restarts service and checks everything works fine
systemctl restart docker
systemctl status docker