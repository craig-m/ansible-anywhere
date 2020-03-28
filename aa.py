#!/usr/bin/env python3

import os
import sys
import platform

def aai_env_check():
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

def aai_env_setup():
    """ ansible anywhere project files """
    dirstore = '/vagrant/gitignore/'
    if not os.path.exists(dirstore):
        os.makedirs(dirstore)
    # files in VM there? Will be mounted (eg vboxsf) or copied (eg rsync)
    if not os.path.exists('/vagrant/vmsetup/'): 
        print("Missing vmsetup dir")
        sys.exit(1)

# AA-I
aai_env_check()
aai_env_setup()

# print("\nAnsibleAnywhere\n")