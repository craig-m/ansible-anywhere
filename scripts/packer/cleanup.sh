#!/bin/sh


# --- functions ---
#
# log / dump output
logit() {
    printf "$1 \\n";
    logger "cvmsetup: $1";
}

logit "started $(basename -- "$0")"


rm -f /var/log/wtmp

rm -rf /tmp/*

# only 1 kernel
# dnf remove $(dnf repoquery --installonly --latest-limit=-1 -q) -y;

dnf autoremove -y
dnf clean all

rm -f /var/lib/systemd/random-seed

# done
sleep 2s && sync && sleep 2s
date --utc > /etc/centos8vm/build_time.txt
logit "finished $(basename -- "$0")"