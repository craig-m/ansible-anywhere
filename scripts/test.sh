#!/bin/bash
# Test ks.centos8.cfg applied OK

# make verbose
#set -x

#sleep 10m;


#
# --- functions ---
#
# log / dump output
logit() {
    printf "$1 \\n";
    logger "cvmsetup: $1";
}
#
# test a command in path
c_testcmd() {
    if [ ! -x "$(command -v $1)" ];
    then
        logit "missing command: $1";
        exit 1;
    fi
}
#
c_testfile(){
    stat -t -- $1 || { logit 'ERROR missing $1'; exit 1; }
    # check owner
    if [ "$(stat -c '%U%G' -- $1)" != "rootroot" ];
    then
        logit "Bad ownership of $1";
        exit 1;
    fi
}

logit "started $(basename -- "$0")"


# Check SSHD just to be sure
sshd -t -f /etc/ssh/sshd_config || { logit 'Bad sshd_config'; exit 1; }


# files created
c_testfile /etc/sysctl.d/noipv6.conf
c_testfile /etc/centos8vm/build_time.txt
c_testfile /etc/modprobe.d/vm-noload.conf


# check programs installed
for checkitem in sudo curl wget rsync dos2unix
do
	c_testcmd $checkitem
done


# SELinux on?
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/index
/usr/sbin/sestatus -b | head -n1 | awk '{print $3}' | grep --quiet "enabled" || { logit 'ERROR SELinux disabled'; exit 1; }
/usr/sbin/getenforce | grep -i --quiet "Enforcing" || { logit 'ERROR SELinux not Enforcing'; exit 1; }

# firewall on?
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/securing_networks/using-and-configuring-firewalls_securing-networks
/usr/bin/firewall-cmd --state | grep --quiet "running" || { logit 'firewalld not running'; exit 1; }
/usr/bin/firewall-cmd --list-services | grep --quiet "ssh" || { logit 'firewalld ssh rule missing'; exit 1; }

# Auditd on?
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/auditing-the-system_security-hardening
/usr/sbin/auditctl -s | grep -q "enabled 1" || { logit 'auditd not running'; exit 1; }


# no Failed services
systemctl list-units | grep failed | wc -l | grep -q 0 || { logit 'failed system services'; exit 1; }
#systemctl list-units --state failed | wc -l | grep -q 0 || { logit 'failed system services'; exit 1; }


# network
grep -i --quiet "# Generated by NetworkManager" /etc/resolv.conf

# check kernel options
grep --quiet 2 /proc/sys/kernel/randomize_va_space || { logit 'alsr is turned off'; exit 1; }


# check file perms
if [ "$(stat -c '%a' /root/)" -ne "700" ];
then
    logit "root perm BAD";
    exit 1;
fi


#
# Hypervisor specific checks
#
whatvirt=$(virt-what)

if [ hyperv = $whatvirt ];
then
    # check UEFI enabled
    grep --quiet "64" /sys/firmware/efi/fw_platform_size || { logit 'no x86_64 EFI'; exit 1; }
    grep --quiet "/boot/efi vfat" /proc/mounts || { logit 'no x86_64 EFI'; exit 1; }

    # secure boot enabled
    #bootctl | head -n3 | grep --quiet "Secure Boot: enabled" || { logit 'secure boot not enabled'; exit 1; }
fi


#
# done
#
touch -f  /tmp/centos8_tested
echo "OK" > /tmp/centos8_tested

logit "finished $(basename -- "$0")"
