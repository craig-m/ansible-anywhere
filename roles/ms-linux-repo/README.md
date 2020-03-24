ms-linux-repo
=============

### Intro

Microsoft have a [Linux Repo](https://docs.microsoft.com/en-us/windows-server/administration/linux-package-repository-for-microsoft-software#manual-configuration). With (ms) software for Linux. Strange times.

Supported on:

* CentOS / RHEL 6 & 7
* Ubuntu *

You can install things like:

* PowerShell
* mdatp (Microsoft Defender Advanced Threat Protection for Endpoints)


##### role

This role was created with:

```
[vagrant@ansibleanywhere vagrant]$ invoke newrole ms-linux-repo
```

Requirements
------------

Your faith in MS.

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------

None.

#### using

See what repo we have configured (on CentOS/RHEL): `yum repolist`

Lets see what MS have for us by listing everything in their repo: `yum --disablerepo="*" --enablerepo="microsoft-com-prod" list available`


License
-------

None.

Author Information
------------------

C.