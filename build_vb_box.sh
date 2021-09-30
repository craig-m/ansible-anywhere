#!/bin/bash
# Virtualbox build work in progress.

#
# vars
#

conf_f_packer="packer-conf/rocky.pkr.hcl"

LogStamp=$(date +%d%h%H%M)
packerlogloc="./logs/build.$LogStamp.packer.log"

export PACKER_LOG=3
export PACKER_LOG_PATH="$packerlogloc"


#
# Packer build
#

# test conf
echo "[*] validate packer conf"
packer validate -syntax-only ${conf_f_packer}

if [[ $? -ne "0" ]];
then
    echo "[*] error validatiing ${conf_f_packer}"
    exit 1
fi


# build box
packer build -only="virtualbox-iso.rocky-vb" ${conf_f_packer}

if [[ $? -ne "0" ]];
then
    echo "[*] error building"
    exit 1
fi


#
# Vagrant
#

vagrant validate Vagrantfile
