Role Name
=========

An ansible test-role. For testing ansible is working, that we can connect to the host, and that we can use molecule.

This role was created with the command `molecule init role test-role`


Requirements
------------

Ansible.


Role Variables
--------------

None.


Dependencies
------------

An ansible target.


Example Playbook
----------------

None. All this role does is create one file:

```
- name: "create /tmp/justatestfile.txt"
  copy:
    content: '# test file'
    dest: /tmp/justatestfile.txt
    owner: root
    group: root
    mode: '0640'
    validate: /usr/bin/grep "test file" %s
  become: true
```


License
-------

None.


Author Information
------------------

C.