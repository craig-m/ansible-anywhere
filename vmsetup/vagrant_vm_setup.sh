#!/usr/bin/bash

# The Virtual Machine image (Box) is an OS in a pre-installed (known) state.

# If you have an automation system, and you want a reproducible outcome
# then don't upgrade/patch to 'current'. Fixed verions are a trade off.
# https://reproducible-builds.org/
# https://www.kernel.org/doc/html/latest/kbuild/reproducible-builds.html


if [[ root = "$(whoami)" ]]; then
    echo "i am root";
else
    echo "need to run as root"
    exit 1;
fi

# check SELinux is still enabled
/usr/sbin/sestatus -b | head -n1 | awk '{print $3}' | grep -q "enabled" || { echo 'ERROR SELinux disabled'; exit 1; }
/usr/sbin/getenforce | grep -q "Enforcing" || { echo 'ERROR SELinux not Enforcing'; exit 1; }

# check auditd enabled
auditctl="/usr/sbin/auditctl"
/usr/bin/systemctl status auditd | grep -q "running" || { echo 'ERROR auditd disabled'; exit 1; }
${auditctl} -s | grep -q "enabled 1" || { echo 'ERROR auditd disabled'; exit 1; }


# get patches - not a deterministic setup
/usr/bin/yum upgrade -y


# Auditd rules ---------------------------------------------------------------
# auditd monitoring of vagrant user activitiy. Not persistent. Reboot clears.
# Thanks to https://github.com/Neo23x0/auditd !


## Kernel module loading and unloading
${auditctl} -a always,exit -F perm=x -F auid!=-1 -F path=/sbin/insmod -k modules
${auditctl} -a always,exit -F perm=x -F auid!=-1 -F path=/sbin/modprobe -k modules
${auditctl} -a always,exit -F perm=x -F auid!=-1 -F path=/sbin/rmmod -k modules
${auditctl} -a always,exit -F arch=b64 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules
${auditctl} -a always,exit -F arch=b32 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules
## Modprobe configuration
${auditctl} -w /etc/modprobe.conf -p wa -k modprobe

## KExec usage (all actions)
${auditctl} -a always,exit -F arch=b64 -S kexec_load -k KEXEC
${auditctl} -a always,exit -F arch=b32 -S sys_kexec_load -k KEXEC

## Special files
${auditctl} -a exit,always -F arch=b32 -S mknod -S mknodat -k specialfiles
${auditctl} -a exit,always -F arch=b64 -S mknod -S mknodat -k specialfiles

## Mount operations (only attributable)
${auditctl} -a always,exit -F arch=b64 -S mount -S umount2 -F auid!=-1 -k mount
${auditctl} -a always,exit -F arch=b32 -S mount -S umount -S umount2 -F auid!=-1 -k mount

# Change swap (only attributable)
${auditctl} -a always,exit -F arch=b64 -S swapon -S swapoff -F auid!=-1 -k swap
${auditctl} -a always,exit -F arch=b32 -S swapon -S swapoff -F auid!=-1 -k swap

## SELinux events that modify the system's Mandatory Access Controls (MAC)
${auditctl} -w /etc/selinux/ -p wa -k mac_policy

## Library search paths
${auditctl} -w /etc/ld.so.conf -p wa -k libpath

## Process ID change (switching accounts) applications
${auditctl} -w /bin/su -p x -k priv_esc
${auditctl} -w /usr/bin/sudo -p x -k priv_esc
${auditctl} -w /etc/sudoers -p rw -k priv_esc

## 32bit API Exploitation
### If you are on a 64 bit platform, everything _should_ be running
### in 64 bit mode. This rule will detect any use of the 32 bit syscalls
### because this might be a sign of someone exploiting a hole in the 32
### bit API.
${auditctl} -a always,exit -F arch=b32 -S all -k 32bit_api

## Suspicious activity
${auditctl} -w /usr/bin/wget -p x -k net_tool_use
${auditctl} -w /usr/bin/curl -p x -k net_tool_use

## Injection 
### These rules watch for code injection by the ptrace facility.
### This could indicate someone trying to do something bad or just debugging
${auditctl} -a always,exit -F arch=b32 -S ptrace -k tracing
${auditctl} -a always,e xit -F arch=b64 -S ptrace -k tracing
${auditctl} -a always,exit -F arch=b32 -S ptrace -F a0=0x4 -k code_injection
${auditctl} -a always,exit -F arch=b64 -S ptrace -F a0=0x4 -k code_injection
${auditctl} -a always,exit -F arch=b32 -S ptrace -F a0=0x5 -k data_injection
${auditctl} -a always,exit -F arch=b64 -S ptrace -F a0=0x5 -k data_injection
${auditctl} -a always,exit -F arch=b32 -S ptrace -F a0=0x6 -k register_injection
${auditctl} -a always,exit -F arch=b64 -S ptrace -F a0=0x6 -k register_injection

### Unsuccessful Creation
${auditctl} -a always,exit -F arch=b32 -S creat,link,mknod,mkdir,symlink,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation
${auditctl} -a always,exit -F arch=b64 -S mkdir,creat,link,symlink,mknod,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation
${auditctl} -a always,exit -F arch=b32 -S link,mkdir,symlink,mkdirat -F exit=-EPERM -k file_creation
${auditctl} -a always,exit -F arch=b64 -S mkdir,link,symlink,mkdirat -F exit=-EPERM -k file_creation

### Unsuccessful Modification
${auditctl} -a always,exit -F arch=b32 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification
${auditctl} -a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification
${auditctl} -a always,exit -F arch=b32 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification
${auditctl} -a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification
