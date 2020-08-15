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


# turn off IPv6
cat <<EOF >/etc/sysctl.d/no-ipv6.conf
# no ipv6 - vagrant provision
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl net.ipv6.conf.all.disable_ipv6=1


mkdir -pv /opt/aa/


#
# done
#
sleep 2s && sync && sleep 2s
logit "finished $(basename -- "$0")"
