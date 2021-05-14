# This Vagrantfile is packaged with the box.
# The options in here are combined with those in 
# ../Vagrantfile during vagrant runtime.

Vagrant.require_version ">= 2.2.15"


# inline script used by action trigger
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

    config.vm.box = "{{ .BoxName }}"

    config.vm.hostname = "centos8vm"
    config.vm.box_check_update = false
    config.vm.boot_timeout = 300
    config.ssh.username = "root"
    config.ssh.guest_port = 22
    config.ssh.insert_key = true
    config.ssh.keep_alive = true
    config.ssh.forward_agent = false
    config.ssh.compression = false

    def is_windows
        RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
    end


    #
    # VM provider specific configs
    # https://www.vagrantup.com/docs/multi-machine/
    #

    # --- Hyper-V ---
    config.vm.provider :hyperv do |hpv, override|
        hpv.memory = 4096
        hpv.maxmemory = 4096
        hpv.cpus = 4
        hpv.linked_clone = false
        # allows for nested VMs
        hpv.enable_virtualization_extensions = true
    end

    # --- VirtualBox ---
    config.vm.provider :virtualbox do |vbox, override|
        vbox.gui = false
        vbox.name = "centos8vm"
        vbox.network "private_network", type: "dhcp", name: "vboxnet3"
    end

    # --- Libvirt ---
    config.vm.provider :libvirt do |libv, override|
        libv.disk_bus = "virtio"
        #config.vagrant.plugins = ["vagrant-libvirt"]
    end

    # --- VMWare ---
    ["vmware_fusion", "vmware_workstation", "vmware_desktop"].each do |provider|
    config.vm.provider provider do |vmw, override|
        vmw.ssh_info_public = true
        vmw.whitelist_verified = true
        vmw.gui = false
        vmw.vmx["cpuid.coresPerSocket"] = "1"
        vmw.vmx["memsize"] = "2048"
        vmw.vmx["numvcpus"] = "2"
    end
    end


    #
    # SSH Port Forwards
    #

    # centos8vm
    config.vm.define "centos8vm" do |mainvm|
        config.vm.network :forwarded_port,
            guest: 8989, host: 8989,
            auto_correct: true,
            id: 'webalt'
    end


    #
    # action Triggers
    # https://www.vagrantup.com/docs/triggers/
    #

    config.trigger.after [:up, :provision, :resume, :reload] do |t|
        t.run_remote = {inline: $inlinescript_post, :privileged => false}
    end


    #
    # Finished
    #

    config.vm.post_up_message = "----- CentOS 8 box -----"

end

# -*- mode: ruby -*-
# vi: set ft=ruby :
