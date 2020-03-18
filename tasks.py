#!/usr/bin/env python3

#-----------------------------------------------------------------------------
# AnsibleAnywhere VM tasks.py - Powered by Invoke https://www.pyinvoke.org
# To list tasks run "invoke -l" in this file's directory.
#-----------------------------------------------------------------------------

import os
import sys
import platform
import time
import subprocess

def aai_env_check():
    # do not run as root user
    userid = os.getuid()
    if userid == 0:
        print ("ERROR do not run as root.")
        sys.exit(1)
    # check the x.x min version of python we can run under
    pyvmax = 3
    pyvmin = 5
    curpyvmax = sys.version_info.major
    curpyvmin = sys.version_info.minor
    if not (curpyvmax == pyvmax and curpyvmin >= pyvmin):
        print("You have python: \t{}.{}".format(curpyvmax, curpyvmin))
        print("Required at least: \t{}.{}".format(pyvmax, pyvmin))
        print("ERROR. Bye!")
        sys.exit(1)

def aai_env_setup():
    dirstore = '/vagrant/gitignore/'
    if not os.path.exists(dirstore):
        os.makedirs(dirstore)

# AA-I
aai_env_check()
aai_env_setup()

import ansible_runner
from invoke import *

# Tasks ----------------------------------------------------------------------


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
def aa_run_del_art(c):
    """ clean ansible-runner artifacts dir """
    print("cleaning up: \n")
    path = "/vagrant/runner-output/artifacts/"
    files = os.listdir(path)
    for artrm in files:
        c.run('rm -rf -- /vagrant/runner-output/artifacts/%r' % artrm)
    print("\ndone.\n")

@task
def aa_run_last_id(c):
    """ find newest ansible-runner artifacts """
    path = "/vagrant/runner-output/artifacts/"
    os.chdir(path)
    artdir = sorted(os.listdir(os.getcwd()), key=os.path.getmtime)
    oldest = artdir[0]
    newest = artdir[-1]
    print("artifacts:", newest)


@task(post=[aa_run_last_id])
def aa_play(c):
    """ run playbook that configures AnsibleAnywhere VM """
    print("Using ansible_runner python interface to run playbook-controlvm.yml on localhost")
    r = ansible_runner.run(
        private_data_dir='/vagrant/runner-output/', 
        inventory='/vagrant/localhost.ini', 
        playbook='/vagrant/playbook-controlvm.yml',
        quiet='true')
    print("\nFinal status:")
    print(r.stats)


# The next two tasks run a role from "/vagrant/roles/<role name>" on localhost

# ansible-runner bin
# doc https://ansible-runner.readthedocs.io/en/latest/standalone.html
@task(post=[aa_run_last_id])
def aa_role_run(c, rolename):
    """ Run a single role on localhost with ansible-runner bin """
    print("ansible-runner: /vagrant/roles/%s on localhost" % rolename)
    with c.cd('/vagrant/'):
        c.run('ansible-runner \
            run --quiet --inventory /vagrant/localhost.ini \
            --rotate-artifacts 50 -r %s -v \
            --roles-path /vagrant/roles/ \
            --artifact-dir /vagrant/runner-output/artifacts/ \
            /home/vagrant/tmp/' % rolename, pty=True)

# ansible-playbook
# doc https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html
@task
def aa_role_play(c, rolename):
    """ Run a single role on localhost with ansible-playbook """
    print("using %s role in playbook-run-single-role.yml" % rolename)
    with c.cd('/vagrant/'):
        c.run('ansible-playbook -i localhost.ini -e "runtherole=%s" -v \
            playbook-run-single-role.yml' % rolename, pty=True)


@task
def mol(c, rolename):
    """ test an Ansible role with molecule """
    print("testing %s" % rolename)
    with c.cd('/vagrant/roles/%s' % rolename):
        c.run('molecule test')
