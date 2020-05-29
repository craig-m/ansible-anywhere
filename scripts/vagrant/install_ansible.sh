#!/bin/bash
# https://wiki.centos.org/SpecialInterestGroup/ConfigManagementSIG
# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html


#
# functions
#

ansible_install() { 
    echo "installing ansible"

    dnf install -y -q centos-release-ansible-29.noarch
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-ConfigManagement
    dnf install -y -q ansible
    
    # test installed in path
    if [ ! -x "$(command -v ansible)" ];
    then
        echo "error running ansible";
        exit 1;
    fi
    
    # custom facts dir
    mkdir -v /etc/ansible/facts.d/
    chmod 0755 /etc/ansible/facts.d/
    chown root:root /etc/ansible/facts.d/

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
}


#
# actions
#

# install if missing
if [ ! -x "$(command -v ansible)" ];
then
    ansible_install
fi
