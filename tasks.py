#!/usr/bin/env python3
# AnsibleAnywhere VM tasks file - Powered by Invoke https://www.pyinvoke.org/
# To use run "invoke -l"

"""
main
"""

import os
import sys
import platform
import time
import subprocess

def aai_env_check():
    """ no root """
    userid = os.getuid()
    if userid == 0:
        print ("ERROR do not run as root.")
        sys.exit(1)
    """ check the python version """
    if not (sys.version_info.major == 3 and sys.version_info.minor >= 5):
        print("Requires Python 3.5 or higher!")
        print("You have: {}.{}.".format(sys.version_info.major, sys.version_info.minor))
        sys.exit(1)

def aai_env_setup():
    dirstore = '/vagrant/gitignore/'
    if not os.path.exists(dirstore):
        os.makedirs(dirstore)

# AA-I
# print('\n --===[ AnsibleAnywhere Invoke tasks ]===-- \n')
aai_env_check()
aai_env_setup()
import ansible_runner
from invoke import *


"""
AA-I Tasks
"""

@task
def aa_update(c):
    """ Update AnsibleAnywhere OS, packages and Pip programs """
    print("updating OS and packages")
    c.run('sudo yum update -y')
    print("updating python pip packages")
    with c.cd('/vagrant/'):
        c.run('python3 -m pip install update --user')
        c.run('pip install --upgrade pip --user')

@task
def aa_rm_artifact(c):
    """ clean ansible-runner artifacts dir """
    print("cleaning up: \n")
    path = "/vagrant/runner-output/artifacts/"
    files = os.listdir(path)
    for artrm in files:
        c.run('rm -rf -- /vagrant/runner-output/artifacts/%r' % artrm)
    print("\ndone.\n")

@task
def runnerlastrun(c):
    """ find last ansible-runner artifacts """
    path = "/vagrant/runner-output/artifacts/"
    os.chdir(path)
    artdir = sorted(os.listdir(os.getcwd()), key=os.path.getmtime)
    #oldest = artdir[0]
    newest = artdir[-1]
    print("artifacts:", newest)


@task(post=[runnerlastrun])
def aa_play(c):
    """ run the playbook that configures AnsibleAnywhere VM """
    print("Using ansible_runner lib to run playbook-controlvm.yml on localhost")
    r = ansible_runner.run(
        private_data_dir='/vagrant/runner-output/', 
        inventory='/vagrant/localhost.ini', 
        playbook='/vagrant/playbook-controlvm.yml',
        quiet='true')
    print("\nFinal status:")
    print(r.stats)


# The next two tasks both run a role from "/vagrant/roles/ <supplied name> /" on this local VM.

# ansible-runner https://ansible-runner.readthedocs.io/en/latest/standalone.html
@task(post=[runnerlastrun])
def aa_role_run(c, rolename):
    """ Run a single role on AnsibleAnywhere VM with ansible-runner bin """
    print("ansible-runner: /vagrant/roles/%s on localhost" % rolename)
    with c.cd('/vagrant/'):
        c.run('ansible-runner run --quiet --inventory /vagrant/localhost.ini --rotate-artifacts 50 -r %s -v --roles-path /vagrant/roles/ --artifact-dir /vagrant/runner-output/artifacts/ /home/vagrant/tmp/' % rolename, pty=True)


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
