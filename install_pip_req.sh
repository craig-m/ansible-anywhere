#!/usr/bin/env bash


# This script will install system wide python3 with the OS package manager.
# It will then get + run get-pip.py to install pip (for the local user),
# and then install requirements.txt (under local users path).


#
# functions
#
logit() {
  echo -e "$1 \\n";
  logger "$1";
}


#
# Sanity checks
#
if [[ root = "$(whoami)" ]]; then
    logit "ERROR: do not run as root";
    exit 1;
fi
sudo true
if [ $? -eq 0 ]; then
    echo "can sudo ok"
else
    logit "ERROR: no sudo"
fi


#
# Get Python3 packages from dnf/apt/yum repo
# Ansible is written in Python, which is written in C, so we need a C compiler.
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
    logit "ERROR: python3 not in path" | logger
    exit 1
else
    pyver=$(python3 --version)
    logit "We are using ${pyver}" | logger
fi


#
# do the things
#

# install pip if missing
if [ ! -f ~/.local/bin/pip ]; then

    # vars
    pipget_file="get-pip.py"
    pipget_url="https://bootstrap.pypa.io/3.4/${pipget_file}"
    pipget_sha512_expect="3272604fc1d63725266e6bef87faa4905d06018839ecfdbe8d162b7175a9b3d56004c4eb7e979fe85e884fc3b8dcc509a6b26e7893eaf33b0efe608b444d64cf"
    pipget_temp=$(mktemp -d)
    pipget_local="${pipget_temp}/${pipget_file}"

    # download installer into temp dir
    curl --silent ${pipget_url} -o ${pipget_local}
    if [ $? -eq 0 ]; then
        logit "saved ${pipget_local}"
    else
        logit "ERROR: failed to get ${pipget_file}"
    fi

    # verify
    pipget_sha512_unknown=$(sha512sum ${pipget_local} | awk '{print $1}')
    if [ $pipget_sha512_unknown == $pipget_sha512_expect ]; then
        echo "good sha512 of get-pip.py"
    else
        echo "BAD checksum of get-pip.py"
        exit 1
    fi

    # install pip with get-pip.py
    cd ${pipget_temp}
    python3 ${pipget_file} --user
    ~/.local/bin/pip --version | grep "python 3." \
        || { logit "pip using wrong python version"; exit 1; }

fi

# location of requirements.txt
if [ -f ./requirements.txt ]; then
    pipreqloc="./requirements.txt"
elif [ -f /vagrant/requirements.txt ]; then
    pipreqloc="/vagrant/requirements.txt"
elif [ -f $HOME/requirements.txt ]; then
    pipreqloc="$HOME/requirements.txt"
else
    logit "could not find requirements.txt in any expected places"; 
fi


# install requirements.txt
logit "installing ${pipreqloc}"
~/.local/bin/pip install -r ${pipreqloc} --user \
    || { logit "pip could not install requirements.txt"; exit 1; }

# installed pacakges:
~/.local/bin/pip list


#
# test and exit
#
if ! [ -x "$(command -v invoke)" ]; then
    logit "ERROR: can not execute invoke bin"
    exit 1
else
    whereis invoke
    logit "finished installing requirements.txt"
fi
