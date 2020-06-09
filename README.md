Overview
========

One of my development environments 🏭


# Linux

RHEL is usually "the work Linux", but running Red Hat Enterprise Linux (RHEL) incurs a cost [[1](https://access.redhat.com/articles/11258), [2](https://www.redhat.com/en/resources/Linux-rhel-subscription-guide)]. Thankfully there are some [derivativate distributions](https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux_derivatives) that are built from this same source code (without the non-free parts). We can use these for learning, development and testing as they are almost the same as RHEL.

The [CentOS project](https://en.wikipedia.org/wiki/CentOS) is one of these and has been around for about 15 years. They even offically partnered [[1](https://www.redhat.com/en/about/press-releases/red-hat-and-centos-join-forces)] with [Red Hat](https://en.wikipedia.org/wiki/Red_Hat) back in 2014, whose parent company as of 2019 is [IBM](https://en.wikipedia.org/wiki/IBM). In 2015 Red Hat acquired [Ansible](https://www.ansible.com/) (a small startup at the time) for a cool $100/150 million [[1](https://www.redhat.com/en/about/press-releases/red-hat-acquire-it-automation-and-devops-leader-ansible)]. 

Ansible (written in [python](https://www.python.org/)) cannot run on a Windows host natively, you need A macOS, Linux or *BSD operating system - so running Ansible from CentOS seems like a good idea.


## Linux setup

Ansible is a pretty good "configuration managment" (CM) tool 🔧

I really like it for some tasks that would otherwise be manual (writing, and certainly maintaining, yaml is easier than bash for some tasks).

Use cases of CM tools are broard:

* setting up standalone machines (desktops or servers, physical or virtual)
* creating more [complex systems](https://github.com/donnemartin/system-design-primer) (cloud or local dev, just learning demo or production)
* managing Firewalls, Switches, WiFi - there are [Network Modules](https://docs.ansible.com/ansible/latest/network/index.html) for physical and virtual networks

Doing things in Ansible can be better ⚙️


## Virtual Machines

There are other tools I want to use Ansible with (like DB or Web servers), but I do not want to run these kinds of services on my host system 🏰 (whatever that might be - Mac / Lin / Win).

I need to run these daemons in isolation, and have my different projects stay private from each other, while keeping my Desktop/Laptop as clean of crummy software as possible (all code is bad code).

This is why I am using a VM. I also want to run my Ansible roles against other machines, and have a real test system.


### packer

[packer](https://packer.io/) will take an [ISO image](https://en.wikipedia.org/wiki/ISO_image) and create Virtual Machine image from it. This is how Vagrant "boxes" are made 📦

You can build a box and run it locally, then then build another box (with the same base config) for a cloud hosting provider (Azure, AWS EC2, Google) - if you have the need. This saves us from having to manually install our OS (RHEL).


### vagrant

This tool [Vagrant](https://www.vagrantup.com/downloads.html) is an abstraction layer on top of virtualisation, vagrant is a wrapper that allows us to use Virtual Machines in a more portable way 🌏

_"Vagrant is a tool for building and distributing development environments."_

So we can interface with Vagrant to have a similar experience, no matter our host OS or hypervisor.


Requirements
============

What you need:

* 64 bit OS on hardware with [virtualization support](https://en.wikipedia.org/wiki/X86_virtualization)
* Check virtualization is enabled in your BIOS
* Hypervisor/Host Vagrant can use for a [Provider](https://www.vagrantup.com/docs/providers/)
* Lots of Ram and disk help

Packer and Vagrant are cross platform (MacOS, Win, Linux, BSD), you can download pre-made binaries courtesy of [Hashicorp](https://www.hashicorp.com/https://www.hashicorp.com/) or compile them from [source](https://github.com/hashicorp).


You can adjust the amount of Virtual Machines you need, and the specs for them, by editing the Vagrantfile:

```
# centos8vm "admin vm" options
MY_VM_RAM = "4096"
MY_VM_CPU = "4"
MY_VM_CODE = "./code/vm/"

# Enable the multi-machine setup? yes/no
MULTIVM = "yes"
# Number of Node VMs to create?
NODES = 2
# centos8node{i} options:
NODE_CPU = "2"
NODE_RAM = "4096"
NODE_CODE = "./code/node/"
```


### Status

Currently using [CentOS](https://www.centos.org/) version [8.1.1911](https://wiki.centos.org/Manuals/ReleaseNotes/CentOS8.1911) (released 15 January 2020).

What I have had time for so far.

| Host OS    | Hypervisor   | Status    | Tested    |
|------------|:------------:|:---------:|----------:|
| Win 10 Ent | Hyper-V      | done      | good      |
| Win 10 Ent | Virtual Box  | to start  | to test   |
| Mac OS     | Virtual Box  | to start  | to test   |
| Linux      | Virtual Box  | to start  | to test   |
| Linux      | Lib Virt     | done      | good      |


### use

See the doc/ directory.