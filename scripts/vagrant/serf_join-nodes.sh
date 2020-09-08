#!/bin/bash

hostname=$(hostname)

case $hostname in
    centos8node1)
        echo "joining above"
        node_id_admin=$(getent hosts centos8admin.local | awk '{ print $1 }') && /usr/local/bin/serf join $node_id_admin
        node_id_2=$(getent hosts centos8node2.local | awk '{ print $1 }') && /usr/local/bin/serf join $node_id_2
        ;;
    centos8node2)
        echo "joining below"
        node_id_1=$(getent hosts centos8node1.local | awk '{ print $1 }') && /usr/local/bin/serf join $node_id_1
        ;;
    centos8node*)
        echo "joining first two"
        node_id_1=$(getent hosts centos8node1.local | awk '{ print $1 }') && /usr/local/bin/serf join $node_id_1
        node_id_2=$(getent hosts centos8node2.local | awk '{ print $1 }') && /usr/local/bin/serf join $node_id_2
esac

/usr/local/bin/serf members