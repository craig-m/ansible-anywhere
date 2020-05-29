test role
=========

An ansible test-role. For testing ansible is working, that we can connect to the host and priv esc (create a temp file as root), and that we can use molecule.

Created by: `molecule init role test-role`


Requirements
------------

Ansible.


Role Variables
--------------

```
testfileloc: "/tmp/testfile.txt"
```


Dependencies
------------

An ansible target.


Example Playbook
----------------

None. All this role does is create one file:

```
- name: 'test file template'
  template:
    src: testfile_txt.j2
    dest: "{{ testfileloc }}"
    owner: root
    group: "{{ ansible_user_id }}"
    mode: 0664
    validate: 'grep "test file" %s'
  become: true
```


License
-------

None.


Author Information
------------------

C.