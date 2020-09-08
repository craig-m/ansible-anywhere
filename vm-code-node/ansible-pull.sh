#!/bin/bash

echo "started ansible-pull.sh"

centos8admin_ip=$(getent hosts centos8admin.local | awk '{ print $1 }')

# the remote url _needs_ to be a git repo.

ansible-pull \
    --url http://${centos8admin_ip}:8080 \
    -i node-local.ini \
    centos8-nodes-playbook.yml

echo "finished ansible-pull.sh"