#!/bin/bash

# vars
serf_file="serf_0.8.2_linux_amd64.zip"
serf_url="https://releases.hashicorp.com/serf/0.8.2/$serf_file"
serf_sha="1977efc7ed44749e1ae6a0f9b4efca3024932187d83eb61de00ba19fd8146596"
serf_loc="/usr/local/bin/serf"

# install serf func
getserf() {
    my_temp_dir=$(mktemp -d)
    my_pwd=$(pwd)
    cd $my_temp_dir
    echo "my_temp_dir install $my_temp_dir"
    wget $serf_url
    file $serf_file | grep archive || exit 1
    sum_have=$(sha256sum $serf_file | awk '{print $1}')
    if [ $serf_sha == $sum_have ]; then
        echo "serf sha ok"
    else
        echo "error: got wrong file"
    fi
    unzip $serf_file
    sudo cp -v serf $serf_loc
    file $serf_loc | grep 'ELF 64-bit LSB' || exit 1
    sudo chown root:root $serf_loc
    sudo chmod 755 $serf_loc
    $serf_loc version
    cd $my_pwd
}

echo "running install_serf.sh"

if [ -f /usr/local/bin/serf ]; then
    echo "have serf already"
else
    getserf
fi

echo "finished install_serf.sh"