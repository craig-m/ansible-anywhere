#
# AnsibleAnywhere Vagrantfile
#

Vagrant.require_version ">= 2.2.7"

MY_VM_RAM = "2048"
MY_VM_CPU = "4"
MY_CODE_PATH = "/vagrant"
MY_MNT_OPT = ["dmode=775,fmode=644"]
VAGRANT_API_VER = "2"
VAGRANT_DISABLE_VBOXSYMLINKCREATE = 1


# Script to run during Vagrant config.trigger.after
$inlinescript_post = <<-SCRIPT
echo '-------------------------------------------------------------------';
uname -a;
myip=$(ip addr show eth0 | grep inet | grep -v "inet6" | awk '{print $2}')
echo "My IP: ${myip}";
myroute=$(ip route show | grep default)
echo "Route: ${myroute}";
echo '-------------------------------------------------------------------';
SCRIPT


Vagrant.configure("2") do |config|

    #
    # Box and VM config
    #

    config.vm.box = "centos/7"
    config.vm.box_check_update = false
    config.vm.hostname = "ansibleanywhere"
    config.vm.boot_timeout = 300
    config.ssh.keep_alive = true
    config.ssh.forward_agent = false
    config.ssh.insert_key = true
    config.ssh.compression = false


    #
    # VM provider specific configs
    #

    #   * we want to verify the integrity of the images, 
    #   using the command "vagrant box add centos/7" does not do this.
    #
    #   * need synced_folder flexibility for different OS / Provider combos.
    #
    config.vm.synced_folder ".", "/vagrant", disabled: true
    #
    # --- Virtual Box ---
    config.vm.provider :virtualbox do |vbox, override|
        override.vm.box_download_checksum_type = "sha256"
        override.vm.box_download_checksum = "de768cf0180d712a6eac1944bd78870c060999a8b6617f8f9af98ddbb9f2d271"
        override.vm.box_url = "https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1905_01.VirtualBox.box"
        vbox.memory = MY_VM_RAM
        vbox.cpus = MY_VM_CPU
        vbox.gui = false
        vbox.name = "ansibleanywhere"
        override.vm.synced_folder ".", MY_CODE_PATH, type: "virtualbox", mount_options: MY_MNT_OPT
    end
    # --- Windows Hyper-V ---
    config.vm.provider :hyperv do |hpv, override|
        override.vm.box_download_checksum_type = "sha256"
        override.vm.box_download_checksum = "8116101e3b56306626e848b4e4be3242480f0d30cf0a177e75bea3fbb51595bf"
        override.vm.box_url = "https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1905_01.HyperV.box"
        hpv.memory = MY_VM_RAM
        hpv.maxmemory = MY_VM_RAM
        hpv.cpus = MY_VM_CPU
        hpv.vmname = "ansibleanywhere"
        hpv.enable_virtualization_extensions = true
        override.vm.synced_folder ".", MY_CODE_PATH, type: "rsync", mount_options: MY_MNT_OPT
        #override.vm.synced_folder ".", MY_CODE_PATH, type: "smb", mount_options: MY_MNT_OPT, create: true
    end
    # --- VMWare Fusion ---
    config.vm.provider :vmware_desktop do |vmd, override|
        override.vm.box_download_checksum_type = "sha256"
        override.vm.box_download_checksum = "8749ba6b2d96e7ad861079113e30e78fa6d12ca17e2e1d78471b02d5d7fb35b2"
        override.vm.box_url = "https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1905_01.VMwareFusion.box"
        vmd.memory = MY_VM_RAM
        vmd.gui = false
        override.vm.synced_folder ".", MY_CODE_PATH, type: "rsync", mount_options: MY_MNT_OPT
    end
    # --- Libvirt ---
    config.vm.provider :libvirt do |libv, override|
        override.vm.box_download_checksum_type = "sha256"
        override.vm.box_download_checksum = "fb64ff0b466a897d457753c92485907f62f38ec9301ebf1cce1d4904272a5c34"
        override.vm.box_url = "https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1905_01.Libvirt.box"
        libv.memory = MY_VM_RAM
        libv.cpus = MY_VM_CPU
        libv.disk_bus = "virtio"
        #override.vm.synced_folder ".", MY_CODE_PATH, type: "rsync", mount_options: MY_MNT_OPT
        config.vm.synced_folder ".", MY_CODE_PATH, type: "nfs", mount_options: MY_MNT_OPT
    end  


    #
    # VM Provisioning tasks
    #

    config.vm.provision :shell,
        :privileged => false,
        inline: "echo 'Hello, AnsibleAnywhere vm.provision tasks running.'"

    config.vm.provision :shell, 
        :privileged => true, 
        :path => "vmsetup/vagrant_vm_setup.sh", 
        :binary => true, 
        name: "root setup script"

    config.vm.provision :shell,
        :privileged => false,
        :binary => true,
        :path => "vmsetup/install_pip_req.sh",
        name: "use python to install pip and requirements.txt"

    # If you let Vagrant handle the installation of Ansible for you, it first installs pip. Like this:
    #
    # DEFAULT_PIP_INSTALL_CMD = "curl https://bootstrap.pypa.io/get-pip.py | sudo python".freeze
    #
    # source: 
    # https://github.com/hashicorp/vagrant/blob/master/plugins/provisioners/ansible/cap/guest/pip/pip.rb
    # https://github.com/hashicorp/vagrant/issues/9584
    #
    # I would prefer not to "curl --[tls]--> sudo shell" and to use a set version of get-pip.
    #
    config.vm.provision "ansible_local" do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "playbook-aa-vm.yml"
        ansible.config_file = "/vagrant/vmsetup/ansible_vagrant.cfg"
        ansible.install = false
        ansible.verbose = false
    end


    #
    # Triggers on VM actions
    #

    config.trigger.after [:up, :provision, :resume, :reload] do |t|
        t.run_remote = {inline: $inlinescript_post, 
            :upload_path => "/home/vagrant/.inlinescript_post.sh", 
            :privileged => false}
    end

    config.trigger.before :destroy do |t|
        t.warn = "removing /vagrant/runner-output/artifacts/*"
        t.run_remote = {inline: "rm -rf -- /vagrant/runner-output/artifacts/*"}
        t.on_error = :continue
    end


    #
    # SSH Port Forwards to VM
    #

    #config.vm.network :forwarded_port, guest: 10880, host: 8080, id: 'websrv'


    #
    # Finished - VM Up message
    #

    config.vm.post_up_message = "----- AnsibleAnywhere VM is up -----"
end
