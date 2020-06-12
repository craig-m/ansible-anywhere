#!/bin/bash

LogStamp=$(date \+\%d\%m\%y\%H\%M);
BuildLog="./logs/build.$LogStamp.log";
packerlogloc="./logs/build.$LogStamp.packer.log";

echo -e "BuildLog: ${BuildLog}\n";
echo -e "PackerLog: ${packerlogloc}\n";

export PACKER_LOG=3
export PACKER_LOG_PATH="$packerlogloc"
export PACKER_CACHE_DIR="./temp/cache/"

packer validate -var-file="packer-conf/centos8.var.json" "packer-conf/centos8_vbox.json"
packer build -var-file="packer-conf/centos8.var.json" "packer-conf/centos8_vbox.json"

ls -la -- ./boxes/


vagrant validate Vagrantfile

echo "finished"