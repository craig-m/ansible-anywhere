"""
AnsibleAnywhere tasks
powered by Invoke, a Python task execution tool https://www.pyinvoke.org/
"""

import os
import platform
import time
import subprocess
import ansible_runner
from invoke import *

user = os.getuid()
if user == 0:
    print ("Do not run as root.")
    quit()

print('\n --===[ AnsibleAnywhere tasks ]===-- \n')


@task
def aa_update(c):
    """ Update AnsibleAnywhere OS, packages and Pip programs """
    print("updating OS and packages")
    c.run('sudo yum update -y')
    print("updating python pip packages")
    with c.cd('/vagrant/'):
        c.run('ls -la requirements.txt')
        c.run('pip3 install update')

@task
def aa_rm_artifact(c):
    """ clean ansible-runner artifacts dir """
    print("deleting /vagrant/runner-output/artifacts/*")
    c.run('rm -rf -- /vagrant/runner-output/artifacts/*')
    print("done\n")


@task
def aa_play(c):
    """ run the playbook that configures AnsibleAnywhere VM """
    print("Using ansbile-runner to call playbook-controlvm.yml")
    r = ansible_runner.run(private_data_dir='/vagrant/runner-output/', 
        inventory='/vagrant/localhost.ini', 
        playbook='/vagrant/playbook-controlvm.yml')
    print("{}: {}".format(r.status, r.rc))
    print("Final status of :")
    print(r.stats)
    print("\n\n")


# The next two tasks run a role from "/vagrant/roles/ <supplied name> /" on this local VM.

# ansible-runner https://ansible-runner.readthedocs.io/en/latest/standalone.html
@task
def aa_role_run(c, rolename):
    """ Run a single role on AnsibleAnywhere VM with ansible-runner """
    print("running the role %s with ansible-runner" % rolename)
    with c.cd('/vagrant/'):
        c.run('ansible-runner run --inventory /vagrant/localhost.ini --rotate-artifacts 50 -r %s -v --roles-path /vagrant/roles/ --artifact-dir /vagrant/runner-output/artifacts/ /home/vagrant/tmp/' % rolename, pty=True)
    print("output from run saved to: /vagrant/runner-output/ ")
    with c.cd('/vagrant/runner-output/artifacts'):
        c.run('ls -td -- */ | head -n 1')
    print("\n\n")

# ansible-playbook https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html
@task
def aa_role_play(c, rolename):
    """ Run a single role on AnsibleAnywhere VM with ansible-playbook """
    print("using %s role in playbook-run-single-role.yml" % rolename)
    with c.cd('/vagrant/'):
        c.run('ansible-playbook -i localhost.ini -e "runtherole=%s" -v playbook-run-single-role.yml' % rolename, pty=True)


@task
def mol(c, rolename):
    """ test an Ansible role with molecule """
    print("testing %s" % rolename)
    with c.cd('/vagrant/roles/%s' % rolename):
        c.run('molecule test')