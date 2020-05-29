#!/bin/sh

#
# --- functions ---
#
# log / dump output
logit() {
    printf "$1 \\n";
    logger "cvmsetup: $1";
}


#
# get the latest updates before this
# vm is packaged into a vagrant box.
#

logit "started $(basename -- "$0")"

ulimit -Sn


# import centos project gpg key
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

# clean upate info
dnf clean all

# update
dnf upgrade -y && dnf update -y || { logit 'dnf upgrade failed'; exit 1; }


# done
sleep 2s && sync && sleep 2s
logit "finished $(basename -- "$0")"
