#
# Rocky Linux KickStart config
#

# use CDROM to install from
cdrom

# GUI or TXT
text

# locale
lang en_US.UTF-8
keyboard us
timezone UTC

skipx
eula --agreed
firstboot --disabled

#
# security options
#
selinux --enforcing
firewall --enabled --port=22:tcp,9090:tcp

# network setup
network --bootproto dhcp --noipv6 --hostname=rocky.localdomain --nameserver=1.1.1.1 --nameserver=1.0.0.1

# partitions and booting
zerombr
clearpart --all --initlabel
bootloader --location=mbr --append="net.ifnames=0 biosdevname=0 no_timer_check"
ignoredisk --only-use=sda
autopart --type=lvm

# root account
rootpw --plaintext 1root2pass3word4

# non-root user account
user --name=sysops --shell=/bin/bash --homedir=/home/sysops --plaintext --password=1user2pass3word4 --uid=5050 --gid=5050

# auth options
authconfig --enableshadow --passalgo=sha512

# System services on
services --enabled="chronyd"
services --enabled="sshd"
services --enabled="NetworkManager"
# disable:
services --disabled="cups"


#
# packages
#
%packages --instLangs=en --ignoremissing --excludedocs
@core
sudo
yum-utils
auditd
curl
wget
rsync
dos2unix
authconfig
unzip
setools
gnupg2
# do not install unnecessary firmware
-iwl7260-firmware
-iwl135-firmware
-iwl3160-firmware
-iwl2000-firmware
-iwl105-firmware
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-iwl2030-firmware
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6050-firmware
-libertas-usb8388-firmware
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-ql2500-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware
%end


#
# pre/post scripts
#

%pre --interpreter=/bin/bash
echo -e "pre script start"
echo foobar > /root/kspre.log
echo -e "pre script finished"
%end

%post --interpreter=/bin/bash
echo foobar > /root/kspost.log
%end


# Password Policy
%anaconda
pwpolicy root --minlen=10 --minquality=1 --notstrict --nochanges --notempty
%end

#%addon com_redhat_kdump --disable --reserve-mb='auto'
#%end

#
# done
#
reboot --eject
