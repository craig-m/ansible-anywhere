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
# to do - https://github.com/Neo23x0/auditd
