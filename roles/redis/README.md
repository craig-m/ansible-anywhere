Redis
=====

Simple role to install [Redis](https://redis.io/), then start + enable + test the service.

Created by: `[vagrant@ansibleanywhere roles]$  redis`

Using Redis to hold ansible fact cache improves perfomance.

Requirements
------------

That redis is in your apt/yum/other repository. This role installs with the 'package' module.

On CentOS you can run `epel` role first.

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