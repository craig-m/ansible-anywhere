#!/bin/bash

# Avahi is a free zero-configuration networking implementation, 
# including a system for multicast DNS/DNS-SD service discovery.
#
# we can resolve <hostname>.local domains with in on our LAN.
#
# Docs: https://www.avahi.org/

# this is done in vagrant, not in packer, so we have unqiue hostnames.

yum update
yum install -y -q avahi avahi-libs avahi-compat-libdns_sd nss-mdns
cp -v /usr/share/doc/avahi/ssh.service /etc/avahi/services/
systemctl enable --now avahi-daemon.service

# allow firewall port
firewall-cmd --zone=public --add-service mdns --permanent
firewall-cmd --reload
firewall-cmd --list-services

systemctl reload avahi-daemon
