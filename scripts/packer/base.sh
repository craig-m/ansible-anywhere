#!/bin/bash

# packer base.sh script - setup the newly installed system

# exit on error
set -e

# make verbose
#set -x

ulimit -Sn


#
# --- functions ---
#
# run cmd and output
runcmd() {
    cmdoutput=$(command $@)
    echo "output of '$@':\n$cmdoutput"
}
#
# log / dump output
logit() {
    printf "$1 \\n";
    logger "cvmsetup: $1";
}


#
# start / dump debug info
#
logit "started $(basename -- "$0")"

# dump info for debugging
echo "======================================================================"
echo "PACKER_BUILDER_TYPE $PACKER_BUILDER_TYPE"
echo "PACKER_BUILD_NAME $PACKER_BUILD_NAME"
echo "PACKER_HTTP_ADDR $PACKER_HTTP_ADDR"
echo "Box Version: $s_cos8vm_boxv"
pwd
runcmd uname -a
runcmd uptime
runcmd ip addr show
runcmd date
runcmd df -h
#cat /proc/mounts | grep -v cgroup | grep -v grep
echo "======================================================================"


#
# environment/safety checks
#
logit "doing safety checks"

# root user
if [[ root = "$(whoami)" ]];
then
    echo "running as root.";
else
    logit "need to run as root";
    exit 1;
fi

# check hostname
hostname | grep --quiet "centos8.localdomain" || { logit 'hostname not set'; exit 1; }

logit "safety checks passed"


#
# files / folders
#
mkdir -v "/etc/centos8vm"
chmod -v 770 /etc/centos8vm
# copy packer build uuid to VM image
echo $s_cos8vm_id > /etc/centos8vm/build_id.txt
cat -v -- /etc/centos8vm/build_id.txt
# gen a uuid for this VM image
vmuuid=$(uuidgen)
echo $vmuuid > /etc/centos8vm/vm_id.txt
cat -v -- /etc/centos8vm/vm_id.txt


#
# sys / net / os
#
# do not load these kernel modules
cat <<EOF >/etc/modprobe.d/vm-noload.conf
#
# do not load these kernel modules
#
blacklist ipv6
blacklist soundcore
blacklist pcspkr
blacklist snd
blacklist snd_intel8x0
blacklist snd_ac97_codec
blacklist snd_pcm
blacklist snd_timer
blacklist i2c_piix4
blacklist ppdev
blacklist joydev
EOF

# turn off IPv6
cat <<EOF >/etc/sysctl.d/noipv6.conf
# no ipv6 - ks.cfg
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl net.ipv6.conf.all.disable_ipv6=1

# remove link to NIC
sed -i '/^UUID/d'   /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0


#
# SSHD
#
logit "ssh config start"
# config
sed -ri 's/#AddressFamily any/AddressFamily inet/g' /etc/ssh/sshd_config
sed -ri 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g' /etc/ssh/sshd_config
sed -ri 's/#UseDNS no/UseDNS no/g' /etc/ssh/sshd_config
# enable password auth
#sed -ri 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# remove env vars
sed -i /AcceptEnv/d /etc/ssh/sshd_config
# test sshd
sshd -t -f /etc/ssh/sshd_config
# reload sshd
systemctl reload sshd
logit "ssh config finish"


#
# download assets in ./http/ on host from packer webserver
#
curl --silent --show-error http://$PACKER_HTTP_ADDR/banner/banner1.txt --output /etc/issue


#
# /root/ files and folders
#
gpg --list-keys
mkdir -pv /root/.ssh/
chmod 700 /root/.ssh/

# root ssh authorized keys
if [ ! -f /root/.ssh/authorized_keys ]; 
then
    touch -f /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/
    inseckey="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key";
    echo $inseckey >> /root/.ssh/authorized_keys
fi

chown -v -R root:root /root/*
chmod -v 700 /root/
restorecon -R /root/.ssh/


#
# EPEL
# https://fedoraproject.org/wiki/EPEL
#
dnf config-manager --set-enabled powertools
yum install epel-release -y
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8


#
# done
#
sleep 2s && sync && sleep 2s
logit "finished $(basename -- "$0")"
