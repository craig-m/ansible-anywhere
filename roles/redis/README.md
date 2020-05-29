Redis
=====

Simple role to install [Redis](https://redis.io/), then start + enable + test the service.

Created by: `[vagrant@ansibleanywhere vagrant]$ invoke newrole redis`

Using Redis [cache plugin](https://docs.ansible.com/ansible/latest/plugins/cache/redis.html) to hold ansible fact cache improves perfomance.

Requirements
------------

That redis is in your apt/yum/other repository (installs with ansible's generic 'package' module).

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