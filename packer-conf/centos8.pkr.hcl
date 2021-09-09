packer {
  required_version = ">= 1.7.0"
}

variable "box_version" {
  type    = string
  default = "0.4.01"
}

variable "checksum" {
  type    = string
  default = "sha256:0394ecfa994db75efc1413207d2e5ac67af4f6685b3b896e2837c682221fd6b2"
}

variable "description" {
  type    = string
  default = "AnsibleAnywhere Dev Env"
}

variable "http_dir" {
  type    = string
  default = "packer-http/"
}

variable "isofilename" {
  type    = string
  default = "CentOS-8.4.2105-x86_64-dvd1.iso"
}

variable "isolable" {
  type    = string
  default = "CentOS-8-4-2105-x86_64-dvd"
}

variable "mirror" {
  type    = string
  default = "http://mirror.internode.on.net/pub/"
}

variable "name" {
  type    = string
  default = "crgm/centos8vm"
}

variable "pack_cos8vm_id" {
  type    = string
  default = "${env("cos8vm_id")}"
}

variable "packer_webroot" {
  type    = string
  default = "packer-http"
}

variable "short_description" {
  type    = string
  default = "My Dev Env"
}

variable "shutdown_cmd" {
  type    = string
  default = "shutdown -P now"
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "ssh_user_name" {
  type    = string
  default = "root"
}

variable "ssh_user_pass" {
  type    = string
  default = "1root2pass3word4"
}

variable "url" {
  type    = string
  default = "centos/8.4.2105/isos/x86_64/"
}

source "hyperv-iso" "centos8-hyperv" {
  boot_command           = ["<wait5>c setparams 'kickstart'<wait><enter>", "linuxefi /images/pxeboot/vmlinuz text noipv6 modprobe.blacklist=floppy inst.stage2=hd:LABEL=${var.isolable} inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos8.ks<enter> initrdefi /images/pxeboot/initrd.img<wait><enter> boot<wait><enter>"]
  boot_wait              = "25s"
  cpus                   = 8
  disk_size              = "8000"
  enable_dynamic_memory  = false
  enable_secure_boot     = false
  first_boot_device      = "SCSI:0:1"
  generation             = 2
  guest_additions_mode   = false
  headless               = false
  http_directory         = "${var.packer_webroot}"
  iso_checksum           = "${var.checksum}"
  iso_target_path        = "./iso/${var.isofilename}"
  iso_url                = "${var.mirror}${var.url}${var.isofilename}"
  memory                 = 4096
  output_directory       = "temp/output-centos8/"
  secure_boot_template   = "MicrosoftUEFICertificateAuthority"
  shutdown_command       = "${var.shutdown_cmd}"
  ssh_handshake_attempts = 5
  ssh_password           = "${var.ssh_user_pass}"
  ssh_port               = "${var.ssh_port}"
  ssh_timeout            = "15m"
  ssh_username           = "${var.ssh_user_name}"
  switch_name            = "PackerSwitch"
  temp_path              = "temp/"
  vm_name                = "centos8-hv-build"
}

source "qemu" "centos8-libvirt" {
  accelerator            = "kvm"
  boot_command           = ["<wait5><tab>inst.stage2=hd:LABEL=${var.isolable} inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos8.ks<enter><wait>boot<enter>"]
  boot_wait              = "25s"
  cpus                   = 4
  disk_cache             = "unsafe"
  disk_compression       = true
  disk_discard           = "unmap"
  disk_interface         = "virtio-scsi"
  disk_size              = 32768
  display                = "none"
  format                 = "qcow2"
  headless               = true
  http_directory         = "${var.packer_webroot}"
  iso_checksum           = "${var.checksum}"
  iso_url                = "${var.mirror}${var.url}${var.isofilename}"
  memory                 = 4096
  net_device             = "virtio-net"
  output_directory       = "output-centos8/"
  qemu_binary            = "qemu-system-x86_64"
  qemuargs               = [["-drive", "if=none,file=output-centos8/centos8-libvirt,id=drive0,cache=unsafe,discard=unmap,detect-zeroes=unmap,format=qcow2"]]
  shutdown_command       = "${var.shutdown_cmd}"
  ssh_handshake_attempts = 5
  ssh_password           = "${var.ssh_user_pass}"
  ssh_port               = "${var.ssh_port}"
  ssh_timeout            = "15m"
  ssh_username           = "${var.ssh_user_name}"
  use_default_display    = true
  vm_name                = "centos8-libvirt"
  vnc_port_max           = 5901
  vnc_port_min           = 5900
}

source "virtualbox-iso" "centos8-vb" {
  boot_command           = ["<wait5><tab>inst.stage2=hd:LABEL=${var.isolable} inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos8.ks<enter><wait>boot<enter>"]
  boot_wait              = "25s"
  cpus                   = 8
  disk_size              = "8000"
  guest_additions_mode   = "disable"
  headless               = false
  http_directory         = "${var.packer_webroot}"
  iso_checksum           = "${var.checksum}"
  iso_target_path        = "./iso/${var.isofilename}"
  iso_url                = "${var.mirror}${var.url}${var.isofilename}"
  memory                 = 4096
  output_directory       = "temp/output-centos8/"
  shutdown_command       = "${var.shutdown_cmd}"
  ssh_handshake_attempts = 5
  ssh_password           = "${var.ssh_user_pass}"
  ssh_port               = "${var.ssh_port}"
  ssh_timeout            = "15m"
  ssh_username           = "${var.ssh_user_name}"
  vm_name                = "centos8-vb"
}

build {
  sources = ["source.hyperv-iso.centos8-hyperv", "source.qemu.centos8-libvirt", "source.virtualbox-iso.centos8-vb"]

  provisioner "shell" {
    environment_vars  = ["s_cos8vm_id=${var.pack_cos8vm_id}", "s_cos8vm_boxv=${var.box_version}"]
    execute_command   = "{{ .Vars }} bash '{{ .Path }}'"
    expect_disconnect = false
    scripts           = ["scripts/packer/base.sh", "scripts/packer/update.sh", "scripts/packer/install_ansible.sh", "scripts/packer/cleanup.sh"]
  }

  provisioner "shell" {
    expect_disconnect = true
    inline            = ["reboot now"]
    pause_before      = "5s"
    timeout           = "30s"
  }

  provisioner "shell" {
    execute_command   = "bash '{{ .Path }}'"
    expect_disconnect = false
    pause_before      = "5s"
    scripts           = ["scripts/test.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    include              = ["templates/info.json", "scripts/clean-vm.sh", "scripts/test.sh"]
    output               = "boxes/CentOS8.${var.box_version}.box"
    vagrantfile_template = "templates/vagrantfile.centos8.rb"
  }
  post-processor "manifest" {
    output     = "boxes/manifest.json"
    strip_path = true
  }
  post-processor "checksum" {
    output         = "boxes/{{ .BuildName }}.${var.box_version}.checksum"
  }
}
