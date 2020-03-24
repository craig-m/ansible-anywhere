docker-ce-centos
================

This role installs [Docker-CE](https://docs.docker.com/install/linux/docker-ce/centos/) (community edition) on CentOS 7.

Created with: `[vagrant@ansibleanywhere roles]$ molecule init role docker-ce-centos`

Will setup the Yum repo `https://download.docker.com/linux/centos/docker-ce.repo` with stable repo (dev/nightly builds of docker are not here).

A copy of Dockers GPG key is included in the role.


Requirements
------------

CentOS 7.


Role Variables
--------------

None. No defaults or vars.


Dependencies
------------

CentOS 7.


Example Playbook
----------------

```
    - docker-ce-centos
```

License
-------

None.


Author Information
------------------

C.