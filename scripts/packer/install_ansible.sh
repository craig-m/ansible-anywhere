#!/bin/bash

# https://wiki.centos.org/SpecialInterestGroup/ConfigManagementSIG
# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

# exit on error
#set -e

#
# functions
#

ansible_install() { 
    echo "installing ansible"

    dnf install -y -q centos-release-ansible-29.noarch
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-ConfigManagement
    dnf install -y -q ansible

    # ansible-pull needs git
    dnf install -y -q git

    # test installed in path
    if [ ! -x "$(command -v ansible)" ];
    then
        echo "error running ansible";
        exit 1;
    fi

    # ansible dirs
    mkdir -pv /etc/ansible/{facts.d,roles}
    chmod -v 0755 /etc/ansible/{facts.d,roles}
    chown -v -R root:root /etc/ansible/{facts.d,roles}

    touch /etc/ansible/facts.d/cos8vm.fact
    chmod -v 0755 /etc/ansible/facts.d/cos8vm.fact
    chown root:root /etc/ansible/facts.d/cos8vm.fact

# ansible custom fact example script
cat <<EOF >/etc/ansible/facts.d/cos8vm.fact
#!/usr/bin/env python3
import os
import sys
import platform
import json

bid_file = open("/etc/centos8vm/build_id.txt")
bid_line = bid_file.read().replace("\n", "")
bid_file.close()

vid_file = open("/etc/centos8vm/vm_id.txt")
vid_line = vid_file.read().replace("\n", "")
vid_file.close()

# output
print(json.dumps({
    "build_id" : bid_line,
    "vm_id" : vid_line
}))
EOF

    echo "ansible installed"
}

ansible_remove() {
    echo "removing ansible"
    dnf remove -y ansible
    rm -fv -- /etc/ansible/ansible.cfg
    if [ -x "$(command -v ansible)" ];
    then
        echo "error removing ansible";
        exit 1;
    fi
    echo "ansible removed"
}

ansible_test() {
    echo "testing"
    ansible --version
}


#
# actions
#

# install if missing
if [ ! -x "$(command -v ansible)" ];
then
    ansible_install
    ansible_test
fi