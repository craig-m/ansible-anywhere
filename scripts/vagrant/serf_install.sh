#!/bin/bash

# Serf, by HashiCorp, is a decentralized solution for cluster 
# membership, failure detection, and orchestration.
# Docs: https://www.serf.io/docs/index.html


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
    wget -q $serf_url || exit 1
    file $serf_file | grep archive || exit 1
    sum_have=$(sha256sum $serf_file | awk '{print $1}')
    if [ $serf_sha == $sum_have ]; then
        echo "serf sha ok"
    else
        echo "error: got wrong file"
    fi
    unzip $serf_file || exit 1
    sudo cp -v serf $serf_loc
    file $serf_loc | grep 'ELF 64-bit LSB' || exit 1
    sudo chown root:root $serf_loc
    sudo chmod 755 $serf_loc
    $serf_loc version
    cd $my_pwd
}

echo "running install_serf.sh"

# root user
if [[ root = "$(whoami)" ]];
then
    echo "running as root.";
else
    echo "need to run as root";
    exit 1;
fi

if [ -f /usr/local/bin/serf ]; then
    echo "have serf already"
else
    getserf
    firewall-cmd --zone=public --add-port=7946/tcp --permanent;
    firewall-cmd --zone=public --add-port=7946/udp --permanent;
    firewall-cmd --reload;
    firewall-cmd --list-ports;
    mkdir -pv /etc/serf/
fi


# systemd script
cat <<EOF >/etc/systemd/system/serf.service
# Serf Agent (systemd service unit)
[Unit]
Description=Serf Agent
After=syslog.target
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/serf agent discover=cluster -syslog -config-dir=/etc/serf/
# Use SIGINT instead of SIGTERM so serf can depart the cluster.
KillSignal=SIGINT
# Restart on success, failure, and any emitted signals like HUP.
Restart=always
# Wait ten seconds before respawn attempts.
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# start
sudo systemctl start serf
sudo systemctl enable serf

serf_pif=$(pgrep serf)
echo "running with pid ${serf_pif}"

echo "finished install_serf.sh"