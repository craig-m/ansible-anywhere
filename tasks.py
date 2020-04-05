#!/usr/bin/env python3

#-----------------------------------------------------------------------------
# AnsibleAnywhere tasks.py (configuration in invoke.yml)
# To list tasks run "invoke -l" in this file's directory (usually "/vagrant/")
#-----------------------------------------------------------------------------

# standard python functions
import os
import sys
import platform
import time
import json
import re
import pprint
import shutil
# aa.py
import aa
# Invoke https://www.pyinvoke.org
from invoke import *


# Tasks ----------------------------------------------------------------------

@task
def aa_update(c):
    """ update AnsibleAnywhere OS, packages and Pip programs. """
    print("updating OS and packages")
    c.sudo('yum update -y')
    print("updating python pip packages")
    codebase = c.aai.dir_base
    with c.cd(codebase):
        c.run('python3 -m pip install update --user')
        c.run('~/.local/bin/pip install --upgrade pip --user')

@task
def rm_art(c):
    """ delete ansible-runner artifacts. """
    arts = c.aai.dir_base + "/runner-output/artifacts"
    print("cleaning up:",arts)
    files = os.listdir(arts)
    for artrm in files:
        # regex check folder has a uuid (rfc4122) name
        if re.match(r'^[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}$', artrm):
            #print('removing ' + arts + '/' + artrm)
            shutil.rmtree(arts + '/' + artrm)
    print("done.")

@task
def run_last_id(c):
    """ get UUID of most recent runner job. """
    arts = c.aai.dir_base + "/runner-output/artifacts"
    os.chdir(arts)
    artdir = sorted(os.listdir(os.getcwd()), key=os.path.getmtime)
    if len(artdir) == 0:
        print("no folders found.")
    else:
        oldest = artdir[0]
        newest = artdir[-1]
        print("run id:",newest)


@task(post=[run_last_id])
def aa_play(c):
    """ playbook that configures AnsibleAnywhere VM. """
    aarunplayyml = "playbook-aa-vm.yml"
    print("checking " + aarunplayyml)
    codebase = c.aai.dir_base
    with c.cd(codebase):
        c.run('ansible-lint ' + aarunplayyml + ' -v', pty=True)
    print("Using ansible_runner py int with " + aarunplayyml + " on localhost")
    import ansible_runner
    r = ansible_runner.run(
        artifact_dir = codebase + '/runner-output/artifacts', 
        private_data_dir = codebase, 
        inventory = codebase + '/localhost.ini', 
        playbook = codebase + "/" + aarunplayyml,
        quiet = 'true')
    print("\nFinal status:")
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(r.stats)
    print('\n')


# next 2 tasks run a role from "/vagrant/roles/<rolename>" on localhost

# ansible-runner bin
# https://ansible-runner.readthedocs.io/en/latest/standalone.html
@task(aliases=['arp'], post=[run_last_id])
def aa_role_run(c, rolename):
    """ run a single role on localhost with ansible-runner bin. """
    codebase = c.aai.dir_base
    rolebase = c.aai.dir_roles
    arts = c.aai.dir_base + "/runner-output/artifacts"
    print("ansible-runner: " + rolebase + "/" + rolename + "/")
    if not os.path.exists(rolebase + "/" + rolename):
        print("ERROR the role '" + rolename + "' does not exist!")
        sys.exit(1)
    c.run('ansible-runner \
        run --inventory ' + codebase + '/localhost.ini \
        --rotate-artifacts 20 -r ' + rolename + ' -v \
        --roles-path ' + rolebase + ' \
        --artifact-dir ' + arts + ' /home/vagrant/tmp/', pty=True)

# ansible-playbook
# https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html
@task(aliases=['aap'])
def aa_role_play(c, rolename):
    """ run a single role on localhost with ansible-playbook bin. """
    print("using '" + rolename + "' in playbook-run-single-role.yml")
    codebase = c.aai.dir_base
    rolebase = c.aai.dir_roles
    if not os.path.exists(rolebase + "/" + rolename):
        print("ERROR the role '" + rolename + "' does not exist!")
        sys.exit(1)
    with c.cd(codebase):
        c.run('ansible-playbook -i localhost.ini \
            -e "runtherole=' + rolename + '" \
            -v playbook-run-single-role.yml', pty=True)


# Molecule tasks
# https://molecule.readthedocs.io/en/latest/

@task
def mol(c, rolename):
    """ test an Ansible role with molecule. """
    print("testing " + rolename)
    rolebase = c.aai.dir_roles
    if not os.path.exists(rolebase + "/" + rolename):
        print('ERROR role does not exist')
        sys.exit(1)
    with c.cd(rolebase + "/" + rolename):
        c.run('molecule test', pty=True)

@task
def newrole(c, rolename):
    """ create a new ansible role. """
    rolebase = c.aai.dir_roles
    if len(rolename) >= 20:
        print('ERROR must be under 20 char')
        sys.exit(1)
    if re.match(r'^[a-z0-9-]+$', rolename):
        if not os.path.exists(rolebase + "/" + rolename):
            print("creating " + rolename)
            with c.cd(rolebase):
                c.run('molecule init role ' + rolename, pty=True)
        else:
            print('ERROR ' + rolename + ' exists already')
            sys.exit(1)
    else:
        print('ERROR name of role must only contain: lowercase, numbers, and dash ("-").')
        sys.exit(1)
