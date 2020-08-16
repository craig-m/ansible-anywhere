#!/bin/bash

# Avahi is a free zero-configuration networking implementation, 
# including a system for multicast DNS/DNS-SD service discovery.
#
# we can resolve <hostname>.local domains with in on our LAN.
#
# Docs: https://www.avahi.org/

yum update
yum install avahi avahi-libs -y
cp -v /usr/share/doc/avahi/ssh.service /etc/avahi/services/
systemctl enable --now avahi-daemon.service

firewall-cmd --zone=public --add-service mdns --permanent
firewall-cmd --reload
firewall-cmd --list-services

systemctl reload avahi-daemon
#systemctl status avahi-daemon
