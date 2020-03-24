#!/usr/bin/env python3

#-----------------------------------------------------------------------------
# AnsibleAnywhere tasks.py
# To list tasks run "invoke -l" in this file's directory. Usually "/vagrant/"
#-----------------------------------------------------------------------------

# standard python functions
import os
import sys
import platform
import time
import json
# aa.py
import aa
# Invoke https://www.pyinvoke.org
from invoke import *

def aai_checkroledir(rolename):
    """ check role exists before using it """
    rolebase = '/vagrant/roles/'
    if not os.path.exists(rolebase + rolename):
        print("The role '" + rolename + "' in " + rolebase + " does not exist!")
        sys.exit(1)

# Tasks ----------------------------------------------------------------------

@task
def aa_update(c):
    """ Update AnsibleAnywhere OS, packages and Pip programs """
    print("updating OS and packages")
    c.run('sudo yum update -y')
    print("updating python pip packages")
    with c.cd('/vagrant/'):
        c.run('python3 -m pip install update --user')
        c.run('~/.local/bin/pip install --upgrade pip --user')

@task
def run_del_art(c):
    """ clean ansible-runner artifacts dir """
    path = "/vagrant/runner-output/artifacts/"
    print("cleaning up:",path)
    files = os.listdir(path)
    for artrm in files:
        c.run('rm -rf -- /vagrant/runner-output/artifacts/' + artrm )
    print("done.")

@task
def run_last_id(c):
    """ find newest ansible-runner artifacts """
    path = "/vagrant/runner-output/artifacts/"
    os.chdir(path)
    artdir = sorted(os.listdir(os.getcwd()), key=os.path.getmtime)
    if len(artdir) == 0:
        print("no folders found.")
    else:
        oldest = artdir[0]
        newest = artdir[-1]
        print("run id:",newest)


@task(post=[run_last_id])
def aa_play(c):
    """ playbook that configures AnsibleAnywhere VM """
    aarunplayyml = "playbook-aa-vm.yml"
    print("checking " + aarunplayyml)
    with c.cd('/vagrant/'):
        c.run('ansible-lint ' + aarunplayyml + ' -v', pty=True)
    print("Using ansible_runner py int with " + aarunplayyml + " on localhost")
    import ansible_runner
    r = ansible_runner.run(
        private_data_dir='/vagrant/runner-output/', 
        inventory='/vagrant/localhost.ini', 
        playbook='/vagrant/' + aarunplayyml,
        quiet='true')
    print("\nFinal status:")
    import pprint
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(r.stats)
    print('\n')


# next 2 tasks run a role from "/vagrant/roles/<rolename>" on localhost

# ansible-runner bin
# https://ansible-runner.readthedocs.io/en/latest/standalone.html
@task(post=[run_last_id])
def aa_role_run(c, rolename):
    """ Run a single role on localhost with ansible-runner bin """
    print("ansible-runner: /vagrant/roles/" + rolename + "/")
    aai_checkroledir(rolename)
    with c.cd('/vagrant/'):
        c.run('ansible-runner \
            run --quiet --inventory /vagrant/localhost.ini \
            --rotate-artifacts 20 -r ' + rolename + ' -v \
            --roles-path /vagrant/roles/ \
            --artifact-dir /vagrant/runner-output/artifacts/ \
            /home/vagrant/tmp/', pty=True)

# ansible-playbook
# https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html
@task
def aa_role_play(c, rolename):
    """ Run a single role on localhost with ansible-playbook bin """
    print("using '" + rolename + "' in playbook-run-single-role.yml")
    aai_checkroledir(rolename)
    with c.cd('/vagrant/'):
        c.run('ansible-playbook -i localhost.ini \
            -e "runtherole=' + rolename + '" \
            -v playbook-run-single-role.yml', pty=True)


# Molecule tasks
# https://molecule.readthedocs.io/en/latest/

@task
def mol(c, rolename):
    """ test an Ansible role with molecule """
    aai_checkroledir(rolename)
    print("testing " + rolename)
    with c.cd('/vagrant/roles/' + rolename):
        c.run('molecule test', pty=True)

@task
def newrole(c, rolename):
    """ create a new role """
    if not os.path.exists('/vagrant/roles/' + rolename):
        print("creating " + rolename)
        with c.cd('/vagrant/roles/'):
            c.run('molecule init role ' + rolename, pty=True)
    else:
        print('ERROR ' + rolename + ' exists already')
        sys.exit(1)
