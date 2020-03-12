#
# Vagrantfile
#
Vagrant.require_version ">= 2.2.5"
VAGRANT_API_VER = "2"
VAGRANT_DISABLE_VBOXSYMLINKCREATE = 1

MY_VM_RAM = "4096"
MY_VM_CPU = "4"
MY_CODE_PATH = "/vagrant"

# box config
Vagrant.configure("2") do |config|
    # the VM "box", and fixed version.
    config.vm.box = "centos/7"
    config.vm.box_version = "1905.1"
    config.vm.box_check_update = false

    config.vm.hostname = "ansibleanywhere"
    config.vm.boot_timeout = 300
    config.ssh.keep_alive = true

    # Disable synced_folder since there is no universal out-of-the-box way to do this.
    # see "Overriding Configuration" on https://www.vagrantup.com/docs/providers/configuration.html
    config.vm.synced_folder ".", "/vagrant", disabled: true


    #
    #  provider specific configs (not really the spirit of Vagrant)
    #
    # --- Virtual Box ---
    config.vm.provider :virtualbox do |vbox, override|
        vbox.memory = MY_VM_RAM
        vbox.cpus = MY_VM_CPU
        vbox.gui = false
        vbox.name = "ansibleanywhere"
        override.vm.synced_folder ".", MY_CODE_PATH, type: "virtualbox", mount_options: ["dmode=775,fmode=644"]
    end
    # --- Windows Hyper-V ---
    config.vm.provider :hyperv do |hpv, override|
        hpv.memory = MY_VM_RAM
        hpv.maxmemory = MY_VM_RAM
        hpv.cpus = MY_VM_CPU
        hpv.vmname = "ansibleanywhere"
        hpv.enable_virtualization_extensions = true
        override.vm.synced_folder ".", MY_CODE_PATH, type: "rsync", mount_options: ["dmode=775,fmode=644"]
        #override.vm.synced_folder ".", MY_CODE_PATH, type: "smb", mount_options: ["dmode=775,fmode=644,vers=3.0"], create: true
    end
    # --- VMWare desktop ---
    config.vm.provider :vmware_desktop do |vmd, override|
        vmd.memory = MY_VM_RAM
        vmd.gui = false
        override.vm.synced_folder ".", MY_CODE_PATH, type: "rsync", mount_options: ["dmode=775,fmode=644"]
    end
    # --- Libvirt ---
    config.vm.provider :libvirt do |libv, override|
        libv.memory = MY_VM_RAM
        libv.cpus = MY_VM_CPU
        libv.disk_bus = "virtio"
        override.vm.synced_folder ".", MY_CODE_PATH, type: "rsync", mount_options: ["dmode=775,fmode=644"]
    end  


    # Provisioning tasks for this VM
    config.vm.provision "ansible_local" do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "playbook-controlvm.yml"
    end

    config.vm.post_up_message = " ----- AnsibleAnywhere VM is up -----"
end
