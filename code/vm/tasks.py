#!/usr/bin/env python3
# Invoke tasks.py file - https://www.pyinvoke.org

import os
import sys
import platform
import time
import json
import re
import pprint
import shutil
from invoke import *


def env_check():
    """ check the environment is ok """
    userid = os.getuid()
    if userid == 0:
        print ("ERROR do not run as root.")
        sys.exit(1)
    # check the x.x min version of python we can run under
    # https://docs.python.org/3.6/contents.html
    pyvmax = 3
    pyvmin = 6
    curpyvmax = sys.version_info.major
    curpyvmin = sys.version_info.minor
    if not (curpyvmax == pyvmax and curpyvmin >= pyvmin):
        print("You have python: \t{}.{}".format(curpyvmax, curpyvmin))
        print("Required at least: \t{}.{}".format(pyvmax, pyvmin))
        print("ERROR. Bye!")
        sys.exit(1)

env_check()


@task
def run_last_id(c):
    """ get UUID of most recent runner job. """
    arts = "/tmp/arts"
    os.chdir(arts)
    artdir = sorted(os.listdir(os.getcwd()), key=os.path.getmtime)
    if len(artdir) == 0:
        print("no folders found.")
    else:
        oldest = artdir[0]
        newest = artdir[-1]
        print("run id:",newest)


# Tasks ----------------------------------------------------------------------

ansiblebase = '/opt/code/ansible/'
rolebase = ansiblebase + 'roles/'


# ansible-runner bin
# https://ansible-runner.readthedocs.io/en/latest/standalone.html
@task(aliases=['arp'], post=[run_last_id])
def role_run(c, rolename):
    """ run a single role with ansible-runner bin. """
    if not os.path.exists(rolebase + rolename):
        print("ERROR the role '" + rolename + "' does not exist!")
        sys.exit(1)
    c.run('ansible-runner \
        run --inventory /etc/ansible/nodes.ini \
        --rotate-artifacts 20 -r ' + rolename + ' -v \
        --roles-path ' + rolebase + ' \
        --artifact-dir /tmp/arts /tmp/', pty=True)


# ansible-playbook
# https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html
@task(aliases=['aap'])
def role_play(c, rolename):
    """ run a single role with ansible-playbook bin. """
    print("using '" + rolename + "' in playbook-run-single-role.yml")
    with c.cd(ansiblebase):
        c.run('ansible-playbook -i /etc/ansible/nodes.ini \
            -e "runtherole=' + rolename + '" \
            -v playbook-run-single-role.yml', pty=True)
