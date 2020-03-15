#!/usr/bin/env bash

# This script will install system wide python3 with the OS package manager.
# It will then get + run get-pip.py to install pip (for the local user),
# and then install requirements.txt (under local users path).


#
# Variables
#
pipget_file="get-pip.py"
pipget_url="https://bootstrap.pypa.io/3.4/${pipget_file}"
pipget_sha512_expect="3272604fc1d63725266e6bef87faa4905d06018839ecfdbe8d162b7175a9b3d56004c4eb7e979fe85e884fc3b8dcc509a6b26e7893eaf33b0efe608b444d64cf"
pipget_temp=$(mktemp -d)
pipget_local="${pipget_temp}/${pipget_file}"


#
# Sanity checks
#
if [[ root = "$(whoami)" ]]; then
  echo "ERROR: do not run as root";
  exit 1;
fi
sudo true
if [ $? -eq 0 ]; then
    echo "can sudo ok"
else
    echo "ERROR: no sudo"
fi


#
# Ansible is written in Python. 
# Python is written in C, so we need compiler too.
#
if [ -x "$(command -v dnf)" ]; then
    sudo dnf install -y gcc python3 python3-devel
fi
if [ -x "$(command -v yum)" ]; then
    sudo yum install -y gcc python3 python3-devel
fi
if [ -x "$(command -v apt)" ]; then
    sudo apt install -y gcc python3 python3-dev
fi
# check
if ! [ -x "$(command -v python3)" ]; then
    echo "ERROR: python3 not in path" | logger
    exit 1
else
    pyver=$(python3 --version)
    echo "We are using ${pyver}" | logger
fi


#
# do the things
#

# install pip
if [ ! -f "~/.local/bin/pip" ]; then
    # download installer into temp dir
    curl --silent ${pipget_url} -o ${pipget_local}
    if [ $? -eq 0 ]; then
        echo "saved ${pipget_local}" | logger
    else
        echo "ERROR: failed to get ${pipget_file}" | logger
    fi

    # verify
    pipget_sha512_unknown=$(sha512sum ${pipget_local} | awk '{print $1}')
    if [ $pipget_sha512_unknown == $pipget_sha512_expect ]; then
        echo "good"
    else
        echo "bad checksum"
        exit 1
    fi

    # install pip
    cd ${pipget_temp}
    python3 ${pipget_file} --user
    ~/.local/bin/pip --version
fi

# install requirements.txt
~/.local/bin/pip install -r /vagrant/requirements.txt --user


#
# test and exit
#
if ! [ -x "$(command -v ansible-playbook --version)" ]; then
    echo "ERROR: can not execute ansible-playbook" | logger
    exit 1
else
    whereis ansible
    echo "finished install ansible" | logger
fi
