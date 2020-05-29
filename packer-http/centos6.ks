install
cdrom
lang en_US.UTF-8
keyboard us
network --onboot yes --device eth0 --bootproto dhcp --noipv6 
rootpw hackme123
firewall --disabled
authconfig --enableshadow --passalgo=sha512
selinux --disabled
timezone UTC
bootloader --location=mbr
text
skipx
zerombr
clearpart --all --initlabel
autopart
auth  --useshadow  --enablemd5
firstboot --disabled
reboot --eject

%packages --ignoremissing
@Base
@Core
@Development Tools
@Infrastructure Servervg
hyperv-daemons
openssl-devel
readline-devel
zlib-devel
kernel-devel
vim
wget
curl
rsync
%end


%post
yum -y update

# vagrant
groupadd vagrant -g 999
useradd vagrant -g vagrant -G wheel -u 900 -s /bin/bash
echo "vagrant" | passwd --stdin vagrant

# sudo
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
%end
