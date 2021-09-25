#!/bin/bash
# This script is to be run in Ubuntu or Debian.
# Run it with sudo command: sudo bash dhcp_server.sh.

#######################
#      Variables      #
#######################
INTNET_IP="10.10.8"		# IP of internal network.
NET_DOMAIN="icr.itb"		# Domain

######################
#        Main        #
######################
# Install DHCP server
apt update
apt -y install isc-dhcp-server

# Copy DHCP configuration file
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.orig

# Dumps into config file all content 
cat << EOF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;

# DNS server
option domain-name-servers $INTNET_IP.1;

# Domain name
option domain-name "$NET_DOMAIN.";

# enp0s3 information
subnet 10.0.2.0 netmask 255.255.255.0 {
}

# enp0s8 information
subnet $INTNET_IP.0 netmask 255.255.255.0 {
   range $INTNET_IP.3 $INTNET_IP.100;
   range $INTNET_IP.103 $INTNET_IP.254;
   option routers $INTNET_IP.1;
   option subnet-mask 255.255.255.0;
   option broadcast-address $INTNET_IP.255;

   host bdd {
      hardware ethernet 00:00:00:00:00:00;
      fixed-address $INTNET_IP.2;
   }

   host eq1 {
      hardware ethernet 00:00:00:00:00:01;
      fixed-address $INTNET_IP.101;
   }

   host eq2 {
      hardware ethernet 00:00:00:00:00:02;
      fixed-address $INTNET_IP.102;
   }
}

# docker0 information
subnet 10.66.0.0 netmask 255.255.255.0 {
}
EOF

# Modifies file to indicate in which interface DHCP server works
sed -i 's/INTERFACES="/INTERFACES="enp0s8 /g' /etc/default/isc-dhcp-server

# Starts service and checks everything is working fine
systemctl start isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl status isc-dhcp-server