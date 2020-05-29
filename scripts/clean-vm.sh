#!/bin/bash
# remove all build items

rm -fv /root/original-ks.cfg
rm -fv /root/anaconda-ks.cfg
rm -fv /root/readme.txt

rm -rfv /etc/centos8vm/

dnf clean all

# done
echo "clean script finished"
sleep 2s && sync && sleep 2s
