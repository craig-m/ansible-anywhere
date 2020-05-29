epel
=====

A role to setup the [EPEL](https://fedoraproject.org/wiki/EPEL) (Extra Packages for Enterprise Linux) Yum repository on CentOS 6/7/8.


Requirements
------------

CentOS 6/7/8 Linux (any arch).

Role Variables
--------------

Defaults:

* A place to download the RPM to: `epelinstdir: "/home/vagrant/downloads"`
* The URL to get it from: `epelrpmdlurl: "https://dl.fedoraproject.org/pub/epel/"`

Variables under `vars/main.yml` we have info about the RPM:

```
epelrpm: "epel-release-latest-{{ ansible_distribution_major_version }}.noarch.rpm"

epelsha6: "sha256:e5ed9ecf22d0c4279e92075a64c757ad2b38049bcf5c16c4f2b75d5f6860dc0d"
epelsha7: "sha256:d6bb83c00ab3af26ded56459e7d6fceabfef66efbe0780b4dedbe81d62c07cd5"
epelsha8: "sha256:8949517e8a84556d06dba8b030fb5bc4553474b352d7ce25799469aa9af4cc62"
```

Dependencies
------------

Yum.

Example Playbook
----------------

None.

License
-------

None.

Author Information
------------------

Crgm.