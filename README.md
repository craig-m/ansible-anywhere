# ansible-anywhere

Ansible is a pretty good tool, I really like it for some tasks that would otherwise be manual (or done in awful scripts). For either standalone machines, or more [complex systems](https://github.com/donnemartin/system-design-primer), or even a rough proof-of-concept projects, doing things in Ansible can be better.

Ansible cannot run on a Windows host natively, you need A macOS, Linux or *BSD operating system.

The [CentOS project](https://en.wikipedia.org/wiki/CentOS) has been around for about 15 years, they are  offically partnered with [Red Hat](https://en.wikipedia.org/wiki/Red_Hat) (whose parent company as of 2019 is [IBM](https://en.wikipedia.org/wiki/IBM)). Back in 2015 Red Hat acquired Ansible for a significant amount of money, so running Ansible from CentOS seems like a good idea.


## Virtual Machines

There are other tools I want to use Ansible with (like DB or Web server), but I do not want to run these kinds of services on my host system. I need to run these daemons in isolation, and have my different projects stay private from each other, while keeping my Desktop/Laptop as clean of crummy software as possible.

This is why I am using a VM, the offical [CentOS 7](https://app.vagrantup.com/centos/boxes/7/versions/1905.1) Vagrant box, which is built for:

* VirtualBox
* VMWare desktop
* libvirt
* Hyper-v

You also need one of these virtualization programs installed on your desktop or server, and [Vagrant](https://www.vagrantup.com/downloads.html) of course. Really this is ansible-anywhere you can run a VM.

As per their [box release notes](https://blog.centos.org/2019/07/updated-centos-vagrant-images-available-v1905-01/) we also need this plugin if we use VirtualBox:


```
vagrant plugin install vagrant-vbguest
```


### setup

To bootstrap the environment:

```
git clone https://github.com/craig-m/ansible-anywhere.git
cd ansible-anywhere/
vagrant up
vagrant ssh
```

Not a single BASH script was executed for any of this system setup :-)

From this point I can pull in code  (mine or [others](https://galaxy.ansible.com/)), and get on with my Ansible work 🔧


## complementary tools

Is this an opinionated setup? Maybe. I find Ansible works better while also using these tools 🤹


#### redis

Of the various [cache plugins](https://docs.ansible.com/ansible/latest/plugins/cache.html) available, I opted for Redis. Perfomance seemed slightly better when managing a large inventory over the default memory plugin.

From the Synopsis _"This cache uses JSON formatted, per host records saved in Redis"_, great so other programs/code can query this too. 


#### molecule

[Molecule](https://molecule.readthedocs.io/en/latest/) is really, increadibly, useful when working on roles.

_"Molecule project is designed to aid in the development and testing of Ansible roles."_

Consider working on a role and being able to run it on two different distros (deb and rpm), and run the role twice so it tests for idempotence. Having specific pytests for the role, all run automatically.


#### ara

[ara](https://github.com/ansible-community/ara) provides a nice web interface and reporting to Ansible.

_"ARA Records Ansible playbooks and makes them easier to understand and troubleshoot."_


#### ansible-runner

The [ansible-runner](https://github.com/ansible/ansible-runner) code is described as

_"a tool and python library that helps when interfacing with Ansible directly or as part of another system whether that be through a container image interface, as a standalone tool, or as a Python module that can be imported"_

This is a component of [AWX](https://github.com/ansible/awx) and [Tower](https://www.ansible.com/products/tower). I use this to capture all output from Ansible (and info about the state of the system at runtime - like facts). Ansible on its own has horrible logging and reporting, and does not log everything.


#### invoke

[Invoke](http://www.pyinvoke.org/) is a Python task execution tool & library. It can make our workflows easier.


#### ansible-cmdb

[ansible-cmdb](https://ansible-cmdb.readthedocs.io/en/latest/usage/) takes the output of Ansible's fact gathering and converts it into a static HTML overview page.


---

# alternatives 

Explorations in portability.


### WSL

Ansible runs under the Windows Subsystem for Linux just fine.

However there are no CentOS or RHEL distributions available in the MS store. We could [roll our own WSL](https://github.com/Microsoft/WSL-DistroLauncher), but it seems like hard work.

The [lack of systemd](https://github.com/microsoft/WSL/issues/994) can be another annoying thing to code around - like this BASH snippet:

```
      case $MY_HOST_TYPE in
        vagrant)
          echo "[*] start Redis via systemd";
          systemctl start redis-server;
          systemctl enable redis-server;
        ;;
        wsl)
          echo "[*] start Redis via init.d";
          /etc/init.d/redis-server start;
          update-rc.d redis-server enable;
        ;;
      esac
```

Having the same systemd commands work on RHEL/CentOS or Ubuntu/Debian etc was a win for me, and WSL went backwards there. I thought we had depreciated init.d on Linux? Remember for a bit there when Ubuntu had upstart instead, sometimes I don't know what is going on anymore - but environment specific hacks become unwieldy fast (we want nice things, like clean portable code).

But anyway WSL1 is not quite a real Linux, nor can I run WSL on one (for portability and testing sake).


### Docker

Containers are sometimes very useful, but I choose not to run Ansible from inside a container.

I like using Redis to hold the Ansible fact cache, so this means using a multi-container system. Using Docker-Compose is fine, but not all container systems use this - like Podman (sure there are solutions to this like [podman-compose](https://github.com/containers/podman-compose)).

I have tried running different services accross containers for Ansible and it became cumbersome. I also feel that if I need to install systemd or a ssh-server into my containers I have defeated the point in using them.

If you are solely using Ansible, then running it from a container is probably a good option for you - check out [Ansible-silo](https://groupon.github.io/ansible-silo/).


### conclusion

WSL and docker work just fine for running Ansible. But these are not full Linux operating systems, somtimes you want minimalism and other times you need an entire kitchen.
