Role Name
=========

This Installs [Docker-CE](https://docs.docker.com/install/linux/docker-ce/centos/) (community edition) on CentOS 7.

Created with: `[vagrant@ansibleanywhere roles]$ molecule init role docker-ce-centos`

Will setup the Yum repo `https://download.docker.com/linux/centos/docker-ce.repo` with stable repo (dev/nightly builds of docker are not here).

A copy of Dockers GPG key is included in the role.


Requirements
------------

CentOS 7.


Role Variables
--------------

None.


Dependencies
------------

CentOS 7.


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }


License
-------

BSD


Author Information
------------------

C.