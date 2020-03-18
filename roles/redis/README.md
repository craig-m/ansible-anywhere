Redis
=====

Simple role to install Redis, then start + enable + test the service.

Created by: `[vagrant@ansibleanywhere roles]$ molecule init role redis`


Requirements
------------

That redis is in your apt/yum/other repository. This role installs with the 'package' module.

Role Variables
--------------

No vars or defaults.

Dependencies
------------

None.

Example
-------

To connect to redis and list keys that, for example,  are ansible fact cache related:

```
redis-cli
KEYS ansible*
quit
```

License
-------

None.

Author Information
------------------

C.