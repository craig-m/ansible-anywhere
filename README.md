# ansible-anywhere

Ansible is a pretty good tool 🔧

I really like it for some tasks that would otherwise be manual (or painful to do in bash).

The use cases of for configuration management tools are broard:

* setting up standalone machines (desktops or servers, physical or virtual)
* creating more [complex systems](https://github.com/donnemartin/system-design-primer) (cloud or local dev, just learning demo or production)
* managing Firewalls, Switches, WiFi - there are [Network Modules](https://docs.ansible.com/ansible/latest/network/index.html) for physical and virtual networks

Doing things in Ansible can be better ⚙

Ansible cannot run on a Windows host natively, you need A macOS, Linux or *BSD operating system.

The [CentOS project](https://en.wikipedia.org/wiki/CentOS) has been around for about 15 years, they  offically partnered [[1](https://www.redhat.com/en/about/press-releases/red-hat-and-centos-join-forces)] with [Red Hat](https://en.wikipedia.org/wiki/Red_Hat) back in 2014 (whose parent company as of 2019 is [IBM](https://en.wikipedia.org/wiki/IBM)).

In 2015 Red Hat acquired Ansible for a significant amount of money [[1](https://www.redhat.com/en/about/press-releases/red-hat-acquire-it-automation-and-devops-leader-ansible)], so running Ansible from CentOS seems like a good idea. Using RHEL incurs a cost [[1](https://access.redhat.com/articles/11258), [2](https://www.redhat.com/en/resources/Linux-rhel-subscription-guide)], and I might want to patch/update my VM.


## Virtual Machines

There are other tools I want to use Ansible with (like DB or Web server), but I do not want to run these kinds of services on my host system.

I need to run these daemons in isolation, and have my different projects stay private from each other, while keeping my Desktop/Laptop as clean of crummy software as possible (all code is bad code).

This is why I am using a VM, the offical [CentOS 7](https://app.vagrantup.com/centos/boxes/7/versions/1905.1) [Vagrant](https://www.vagrantup.com/) box, which is built for:

* VirtualBox (MacOS, Linux, Win, FreeBSD)
* VMWare desktop
* [libvirt](https://en.wikipedia.org/wiki/Libvirt) (Red Hat developed, manages KVM, Xen, VMware ESXi, QEMU)
* Hyper-V (Win 8-10, Server 2012)

You also need one of these virtualization programs installed on your desktop or server, and [Vagrant](https://www.vagrantup.com/downloads.html) of course. Really this is ansible-anywhere you can run a VM - because I **need** a VM on whatever OS I happen to be using (a few).

##### plugins

As per their [box release notes](https://blog.centos.org/2019/07/updated-centos-vagrant-images-available-v1905-01/) we also need this [plugin](https://www.vagrantup.com/docs/plugins/) if we use VirtualBox.

```
vagrant plugin install vagrant-vbguest
```

If you use LibVirt you'll need a plugin:

```
vagrant plugin install vagrant-libvirt
vagrant up --provider=libvirt
```


## setup

To bootstrap the environment 🚀

```
git clone https://github.com/craig-m/ansible-anywhere.git
cd ansible-anywhere/
```

If you use [Visual Studio Code](https://code.visualstudio.com/) you can use [tasks](https://code.visualstudio.com/docs/editor/tasks) to avoid logging into the VM or typing commands.

```
vagrant up
vagrant ssh
cd /vagrant/
invoke -l
```


From this point I can pull in code  (mine or [others](https://galaxy.ansible.com/)), and get on with my work 🛠


## complementary tools

Is this an opinionated setup? Maybe. I find Ansible works better while also using these tools 🤹


#### redis

Of the various [cache plugins](https://docs.ansible.com/ansible/latest/plugins/cache.html) available, I opted for [Redis](https://redis.io/). Perfomance seemed slightly better when managing a large inventory over the default memory plugin.

From the Synopsis _"This cache uses JSON formatted, per host records saved in Redis"_, great so other programs/code can query this too.


#### molecule

[Molecule](https://molecule.readthedocs.io/en/latest/) is really, increadibly, useful when working on roles. Initially started by the Ansible community, the project was officially adopted by the Ansible project ([src](https://www.ansible.com/practical-ansible-testing-with-molecule)).

_"Molecule project is designed to aid in the development and testing of Ansible roles."_

Consider working on a role and being able to run it on two different distros (deb and rpm), and run the role twice so it tests for idempotence. Having specific pytests for the role, all run automatically.


#### ansible-runner

The [ansible-runner](https://github.com/ansible/ansible-runner) code is described as:

_"a tool and python library that helps when interfacing with Ansible directly or as part of another system whether that be through a container image interface, as a standalone tool, or as a Python module that can be imported"_

This is a component of [AWX](https://github.com/ansible/awx) and [Tower](https://www.ansible.com/products/tower).

_"AWX provides a web-based user interface, REST API, and task engine built on top of Ansible. It is the upstream project for Tower, a commercial derivative of AWX."_


There is the "Red Hat® Ansible® Automation Platform" if you do not want, or unable to, host Tower yourself.

* https://www.redhat.com/en/resources/ansible-automation-platform-datasheet
* https://www.ansible.com/products/pricing


I use ansible-runner to capture all output from Ansible (and info about the state of the system at runtime - like facts). Ansible on its own has horrible logging and reporting, and does not log everything.


#### invoke

[Invoke](http://www.pyinvoke.org/) is a Python task execution tool & library. This can make our workflows easier - Invoke rules. You do not need to be particularly proficient in Python to use it.
