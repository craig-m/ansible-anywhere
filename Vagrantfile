#
# CentOS 8 Vagrantfile
#


#
# Vars
#

# centos8admin options:
MY_VM_RAM = "4096"
MY_VM_CPU = "2"
MY_VM_CODE = "./vm-code-admin/"

# Enable the multi-machine setup? yes/no
MULTIVM = "yes"
# Number of Node VMs to create?
NODES = 2
# centos8node{i} options:
NODE_CPU = "2"
NODE_RAM = "2048"
NODE_CODE = "./vm-code-node/"

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
    config.vm.synced_folder ".", "/vagrant", disabled: true


    #
    # Virtual machines
    #


    # centos8admin
    config.vm.define "centos8admin" do |mainvm|

        config.vm.hostname = "centos8admin"
        config.ssh.forward_agent = false
        config.vm.disk :disk, size: "50GB", primary: true

        # provider specific conf
            # --- Windows Hyper-V ---
            mainvm.vm.provider :hyperv do |hpv, override|
                hpv.memory = MY_VM_RAM
                hpv.maxmemory = MY_VM_RAM
                hpv.cpus = MY_VM_CPU
                hpv.vmname = "centos8admin"
                # network
                config.vm.network "public_network",
                    bridge: "PackerSwitch"
                config.vm.network "private_network",
                    bridge: "PackerSwitch"
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

        # run centos8-admin-playbook.yml
        # (generic ansible roles used on adminvm)
        mainvm.vm.provision "ansible_local" do |ansible|
            ansible.groups = {
                "localhost" => ["centos8admin"]
            }
            ansible.compatibility_mode = "2.0"
            ansible.config_file = "ansible_vagrant.cfg"
            ansible.playbook = "centos8-admin-playbook.yml"
            ansible.provisioning_path =  CODE_MNT + "/ansible/"
            ansible.install = false
            ansible.verbose = false
        end

        # run centos8-admin-role.yml
        # (single file playbook - tasks specific to the adminvm)
        mainvm.vm.provision "ansible_local" do |ansible|
            ansible.groups = {
                "localhost" => ["centos8admin"]
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

                node.vm.hostname = "centos8node#{i}"
                node.vm.disk :disk, size: "2GB", name: "node_storage"

                # provider specific conf
                    # --- Windows Hyper-V ---
                    node.vm.provider :hyperv do |hpv, override|
                        hpv.vmname = "centos8node#{i}"
                        hpv.memory = NODE_RAM
                        hpv.cpus = NODE_CPU
                        # network
                        config.vm.network "public_network",
                            bridge: "PackerSwitch"
                        config.vm.network "private_network",
                            bridge: "PackerSwitch"
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
        inline: "echo 'Hello, First vm.provision task running.'"

    config.vm.provision :shell,
        :privileged => true, 
        :path => "scripts/vagrant/setup.sh",
        :upload_path => "/etc/centos8vm/setup.sh",
        :binary => true, 
        name: "vagrant vm setup.sh"

    config.vm.provision :shell,
        :privileged => true,
        :path => "scripts/vagrant/install_avahi.sh",
        :upload_path => "/etc/centos8vm/install_avahi.sh",
        :binary => true,
        name: "vagrant vm install_avahi.sh"

    config.vm.provision :shell,
        :privileged => true,
        :path => "scripts/vagrant/serf_install.sh",
        :upload_path => "/etc/centos8vm/serf_install.sh",
        :binary => true,
        name: "vagrant vm serf_install.sh"

    config.vm.provision :shell,
        :privileged => true,
        :path => "scripts/vagrant/serf_join-nodes.sh",
        :upload_path => "/etc/centos8vm/serf_join-nodes.sh",
        :binary => true,
        name: "vagrant vm serf_join-nodes.sh"

    config.vm.provision :shell,
        :privileged => true,
        :path => "scripts/test.sh",
        :upload_path => "/etc/centos8vm/test.sh",
        :binary => true,
        name: "vagrant vm test.sh"

end

# -*- mode: ruby -*-
# vi: ft=ruby :