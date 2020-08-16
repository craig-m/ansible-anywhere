# setup

First build the Vagrant Box image with Packer build script:

```
& .\build_hv_box.ps1
```

Then start the VMs and login to the main one:

```
vagrant up
vagrant ssh centos8admin
```

Note: Windows/HV you must run your terminal as administrator.

In another terminal you can run this to keep files in sync:

```
vagrant rsync-auto
```

## Using

When in the VM

```
sudo su -l vmuser
source ~/venv/bin/activate
cd /opt/code
invoke -l
```

Test this role with Molecule:

```
cd ansible/roles/test-role/
molecule list
molecule test
```

### cleanup

after a build to clean up:

```
vagrant destroy -f
rm logs\*.log
rm .\temp\
rm .\boxes\*.box
rm .\boxes\*.checksum
```