#!/bin/bash

# Avahi is a free zero-configuration networking implementation, 
# including a system for multicast DNS/DNS-SD service discovery.
#
# we can resolve <hostname>.local domains with in on our LAN.
# example: ping centos8node2.local
#
# Docs: https://www.avahi.org/

# this is done at vagrant provision, not in packer, so we have unqiue hostnames.

yum update
yum install -y -q avahi avahi-libs avahi-compat-libdns_sd nss-mdns
cp -v /usr/share/doc/avahi/ssh.service /etc/avahi/services/
systemctl enable --now avahi-daemon.service

# allow firewall port
firewall-cmd --zone=public --add-service mdns --permanent
firewall-cmd --reload
firewall-cmd --list-services

systemctl reload avahi-daemon

systemctl show -p SubState avahi-daemon | grep -q running && echo "avahi-daemon installed and running"