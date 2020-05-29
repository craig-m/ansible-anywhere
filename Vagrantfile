#
# CentOS 8 Vagrantfile
#


#
# Vars
#

# centos8vm "admin vm" options
MY_VM_RAM = "4096"
MY_VM_CPU = "4"
MY_VM_CODE = "./code/vm/"

# Enable the multi-machine setup? yes/no
MULTIVM = "yes"
# Number of Node VMs to create?
NODES = 2
# centos8node{i} options:
NODE_CPU = "2"
NODE_RAM = "4096"
NODE_CODE = "./code/node/"

# vagrant options
VAGRANT_API_VER = "2"
VAGRANT_DISABLE_VBOXSYMLINKCREATE = 1
CODE_MNT = "/opt/code"
CODE_MNT_OPT = ["dmode=775,fmode=644"]


Vagrant.configure("2") do |config|

    #
    # Box and VM config
    #

    config.vm.box = "centos8vm"
    config.ssh.username = "root"
    config.ssh.insert_key = true


    #
    # Virtual machines
    #

    # centos8vm
    config.vm.define "centos8vm" do |mainvm|
        config.vm.hostname = "centos8vm"
        # provider specific conf
            # --- Windows Hyper-V ---
            mainvm.vm.provider :hyperv do |hpv, override|
                hpv.memory = MY_VM_RAM
                hpv.maxmemory = MY_VM_RAM
                hpv.cpus = MY_VM_CPU
                hpv.vmname = "centos8vm"
                # file shares
                override.vm.synced_folder MY_VM_CODE, CODE_MNT,
                    type: "rsync",
                    mount_options: CODE_MNT_OPT
            end
            # --- Libvirt ---
            config.vm.provider :libvirt do |libv, override|
                # file shares
                override.vm.synced_folder MY_VM_CODE, CODE_MNT,
                    type: "rsync",
                    mount_options: CODE_MNT_OPT
            end
        # provision tasks (run AFTER the section below)
        mainvm.vm.provision :shell,
            :privileged => true, 
            :path => "scripts/vagrant/install_ansible.sh",
            :binary => true, 
            name: "install ansible"
        # run centos8-admin-playbook.yml
        mainvm.vm.provision "ansible_local" do |ansible|
            ansible.groups = {
                "localhost" => ["centos8vm"]
            }
            ansible.compatibility_mode = "2.0"
            ansible.config_file = "ansible_vagrant.cfg"
            ansible.playbook = "centos8-admin-playbook.yml"
            ansible.provisioning_path =  CODE_MNT + "/ansible/"
            ansible.install = false
            ansible.verbose = false
        end
        # run centos8-admin-role.yml
        mainvm.vm.provision "ansible_local" do |ansible|
            ansible.groups = {
                "localhost" => ["centos8vm"]
            }
            ansible.compatibility_mode = "2.0"
            ansible.config_file = "ansible.cfg"
            ansible.playbook = "centos8-admin-role.yml"
            ansible.provisioning_path =  CODE_MNT + "/ansible/"
            ansible.install = false
            ansible.verbose = true
        end
        # port forward
        config.vm.network :forwarded_port,
            guest: 9090, host: 9090,
            auto_correct: true,
            id: 'cockpit'
    end

    # centos8node{i}
    if MULTIVM == "yes"
        # loop over nodes
        (1..NODES).each do |i|
            # create the VM
            config.vm.define "centos8node#{i}" do |node|
                # VM config
                node.vm.hostname = "centos8node#{i}"
                # provider specific conf
                    # --- Windows Hyper-V ---
                    node.vm.provider :hyperv do |hpv, override|
                        hpv.vmname = "centos8node#{i}"
                        hpv.memory = NODE_RAM
                        hpv.cpus = NODE_CPU
                        # file shares
                        override.vm.synced_folder NODE_CODE, CODE_MNT,
                            type: "rsync",
                            mount_options: CODE_MNT_OPT
                    end
                    # --- Libvirt ---
                    config.vm.provider :libvirt do |libv, override|
                        # file shares
                        override.vm.synced_folder NODE_CODE, CODE_MNT,
                        type: "rsync",
                        mount_options: CODE_MNT_OPT
                    end
            end
        end
    end


    #
    # provision tasks (all VMs)
    #

    config.vm.provision :shell,
        inline: "echo 'Hello, vm.provision tasks running.'"

    config.vm.provision :shell,
        :privileged => true, 
        :path => "scripts/vagrant/setup.sh",
        :binary => true, 
        name: "vagrant vm setup.sh"

    config.vm.provision :shell,
        :privileged => true,
        :path => "scripts/test.sh",
        :upload_path => "/etc/centos8vm/test.sh",
        :binary => true,
        name: "vagrant vm test.sh"

end

# -*- mode: ruby -*-
# vi: ft=ruby :