#!/bin/bash


# make verbose
#set -x


#
# --- functions ---
#
# log / dump output
logit() {
    printf "$1 \\n";
    logger "cvmsetup: $1";
}


logit "started $(basename -- "$0")"


# ssh
sed -ri 's/PermitRootLogin yes/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config


# gen SSH key pair for root
if [ ! -f /root/.ssh/vm_ecdsa.key ];
then
    ssh-keygen -b 521 -t ecdsa -f /root/.ssh/vm_ecdsa.key -q -N ""
fi

if [ ! -d /opt/aa/ ];
then
    mkdir -pv /opt/aa/
fi


#
# done
#
sleep 2s && sync && sleep 2s
logit "finished $(basename -- "$0")"
