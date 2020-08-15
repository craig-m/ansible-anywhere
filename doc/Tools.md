# complementary tools

Is this an opinionated setup? Maybe. I find Ansible works better while also using these tools 🤹


#### redis

Of the various [cache plugins](https://docs.ansible.com/ansible/latest/plugins/cache.html) available, I opted for [Redis](https://redis.io/). Perfomance seemed slightly better when managing a large inventory over the default memory plugin.

From the Synopsis _"This cache uses JSON formatted, per host records saved in Redis"_, great so other programs/code can query this too.


#### molecule

[Molecule](https://molecule.readthedocs.io/en/latest/) is really, increadibly, useful when working on roles. Initially started by the Ansible community, the project was officially adopted by the Ansible project ([1](https://www.ansible.com/practical-ansible-testing-with-molecule)) 🧪

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

Reasons to use Invoke:

* run pre (eg: linting) or post (eg: tests) jobs with your task.
* turn really long commands into short ones - often I run ansible with the same sets of parameters.
* easily create some magic alias like `invoke deploy staging` for a chain of commands.

I tried makefiles and invoke suited my needs here so much better.


#### Containers

A container system, like Docker or Podman, is useful.

Molecule will run roles in containers to test them (by default - you can use VM too), via what they call a [driver](https://molecule.readthedocs.io/en/latest/configuration.html#driver).

So having a container setup inside the VM is very useful 🐳