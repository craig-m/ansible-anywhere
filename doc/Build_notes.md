Overview
========

Notes on various Host / HV combinations:

* Hyper-V (Win)
* VirtualBox (Mac, Lin, Win)
* LibVirt (Lin)


Hyper-V
=======

We will create a [Generation 2](https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/should-i-create-a-generation-1-or-2-virtual-machine-in-hyper-v#more-about-generation-2-virtual-machines) VM.

Enable Hyper-V if not already:

```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

On Windows Docker-Deskop runs a VM under HV, so it will already be enabled and running.


## setup

Before using Packer you must make an external switch that Packer can use.

In the file `centos8.json` edit `"switch_name": "PackerSwitch1",` to the name of your Switch.

## use

There are some great PowerShell [cmdlets](https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps) for Hyper-V.

On Win 10 launch PowerShell as Administrator:

```
& .\build_hv_box.ps1
```

A useful packer command (after running `vagrant up` to start the VMs) is `vagrant.exe rsync-auto` to keep the code in the vm in sync.


VirtualBox
===========

To quote Wikipedia: 

_Oracle VM VirtualBox (formerly Sun VirtualBox, Sun xVM VirtualBox and Innotek VirtualBox) is a free and open-source hosted hypervisor for x86 virtualization, developed by Oracle Corporation_

Note that "_Oracle defines personal use as the installation of the software on a single host computer for non-commercial purposes_" - not exactly free software.

## setup

Install on your host OS.

**MacOS**

Download the latest .dmg from https://www.virtualbox.org/wiki/Downloads

**Linux**

See notes for you distro, ou might be able to install from a default repo.

* https://wiki.centos.org/HowTos/Virtualization/VirtualBox
* https://help.ubuntu.com/community/VirtualBox
* https://wiki.debian.org/VirtualBox

Or you can build from source.

**Windows**

Download the latest .exe from https://www.virtualbox.org/wiki/Downloads

Note: You must disable Hyper-V - having both VB and HV installed at the same time will NOT work.

## use

ToDo


Libvirt
=======

ToDo
