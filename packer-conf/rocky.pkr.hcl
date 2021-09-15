# Rock Linux Packer HCL

#
# ------ Varibles ------
#

packer {
  required_version = ">= 1.7.0"
}

variable "box_version" {
  type    = string
  default = "0.1.0"
}

variable "checksum" {
  type    = string
  default = "sha256:ffe2fae67da6702d859cfb0b321561a5d616ce87a963d8a25b018c9c3d52d9a4"
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
  default = "Rocky-8.4-x86_64-dvd1.iso"
}

variable "isolable" {
  type    = string
  default = "Rocky-8-4-x86_64-dvd"
}

variable "mirror" {
  type    = string
  default = "https://mirrors.cogentco.com/pub/"
}

variable "name" {
  type    = string
  default = "crgm/rockyvm"
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

variable "ssh_root_pass" {
  type    = string
  default = "1root2pass3word4"
}

variable "iso_add_user_name" {
  type    = string
  default = "sysadmin"
}
variable "iso_add_user_pass" {
  type    = string
  default = "testing123obvs"
}

variable "url" {
  type    = string
  default = "linux/rocky/8.4/isos/x86_64/"
}

#
# ------ Source blocks ------
#

source "hyperv-iso" "rocky-hyperv" {
  boot_command           = ["<wait5>c<wait5><wait5>setparams 'kickstart'<wait><enter>", "linuxefi /images/pxeboot/vmlinuz text noipv6 modprobe.blacklist=floppy inst.stage2=hd:LABEL=Rocky-8-4-x86_64-dvd inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky.ks<enter> initrdefi /images/pxeboot/initrd.img<wait><enter> boot<wait><enter>"]
  boot_wait              = "15s"
  cpus                   = 8
  disk_size              = "8000"
  enable_dynamic_memory  = false
  enable_secure_boot     = false
  generation             = 2
  guest_additions_mode   = false
  headless               = false
  http_content           = {
    "/rocky.ks"          = templatefile( "./rocky.ks.pkrtpl", { root_pass = var.ssh_root_pass, new_user_name = var.iso_add_user_name, new_user_pass = var.iso_add_user_pass } )
  }
  iso_checksum           = "${var.checksum}"
  iso_target_path        = "./iso/${var.isofilename}"
  iso_url                = "${var.mirror}${var.url}${var.isofilename}"
  memory                 = 4096
  output_directory       = "temp/output-rocky/"
  shutdown_command       = "${var.shutdown_cmd}"
  ssh_handshake_attempts = 10
  ssh_password           = "${var.ssh_root_pass}"
  ssh_port               = "${var.ssh_port}"
  ssh_timeout            = "120m"
  ssh_username           = "${var.ssh_user_name}"
  switch_name            = "PackerSwitch"
  temp_path              = "temp/"
  vm_name                = "rocky-hv-build"
}

# not tested yet:
source "qemu" "rocky-libvirt" {
  accelerator            = "kvm"
  boot_command           = ["<wait5>c<wait10>inst.stage2=hd:LABEL=${var.isolable} inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky.ks<enter><wait>boot<enter>"]
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
  http_content           = {
    "/rocky.ks"          = templatefile( "./rocky.ks.pkrtpl", { my_pass = var.ssh_user_pass, my_user = var.ssh_user_name, root_pass = var.ssh_root_pass } )
  }
  iso_checksum           = "${var.checksum}"
  iso_url                = "${var.mirror}${var.url}${var.isofilename}"
  memory                 = 4096
  net_device             = "virtio-net"
  output_directory       = "output-rocky/"
  qemu_binary            = "qemu-system-x86_64"
  qemuargs               = [["-drive", "if=none,file=output-rocky/rocky-libvirt,id=drive0,cache=unsafe,discard=unmap,detect-zeroes=unmap,format=qcow2"]]
  shutdown_command       = "${var.shutdown_cmd}"
  ssh_handshake_attempts = 5
  ssh_password           = "${var.ssh_root_pass}"
  ssh_port               = "${var.ssh_port}"
  ssh_timeout            = "15m"
  ssh_username           = "${var.ssh_user_name}"
  use_default_display    = true
  vm_name                = "rocky-libvirt"
  vnc_port_max           = 5901
  vnc_port_min           = 5900
}

# not tested yet:
source "virtualbox-iso" "rocky-vb" {
  boot_command           = ["<wait5>c<wait10><wait10>inst.stage2=hd:LABEL=${var.isolable} inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rocky.ks<enter><wait>boot<enter>"]
  boot_wait              = "25s"
  cpus                   = 8
  disk_size              = "8000"
  guest_additions_mode   = "disable"
  headless               = false
  http_content           = {
    "/rocky.ks"          = templatefile( "./rocky.ks.pkrtpl", { my_pass = var.ssh_user_pass, my_user = var.ssh_user_name, root_pass = var.ssh_root_pass } )
  }
  iso_checksum           = "${var.checksum}"
  iso_target_path        = "./iso/${var.isofilename}"
  iso_url                = "${var.mirror}${var.url}${var.isofilename}"
  memory                 = 4096
  output_directory       = "temp/output-rocky/"
  shutdown_command       = "${var.shutdown_cmd}"
  ssh_handshake_attempts = 5
  ssh_password           = "${var.ssh_root_pass}"
  ssh_port               = "${var.ssh_port}"
  ssh_timeout            = "15m"
  ssh_username           = "${var.ssh_user_name}"
  vm_name                = "rocky-vb"
}

#
# ------ Building ------
#

build {
  sources = [ 
    "source.hyperv-iso.rocky-hyperv", 
    "source.qemu.rocky-libvirt", 
    "source.virtualbox-iso.rocky-vb"
  ]

  provisioner "shell" {
    environment_vars  = [ 
      "s_cos8vm_id=${var.pack_cos8vm_id}", 
      "s_cos8vm_boxv=${var.box_version}"
    ]
    execute_command   = "{{ .Vars }} bash '{{ .Path }}'"
    expect_disconnect = false
    scripts           = [
      "scripts/packer/base.sh", 
      "scripts/packer/update.sh", 
      "scripts/packer/install_ansible.sh", 
      "scripts/packer/cleanup.sh"
    ]
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
    include              = [
      "templates/info.json",
      "scripts/clean-vm.sh",
      "scripts/test.sh"
    ]
    output               = "boxes/rocky.${var.box_version}.box"
    vagrantfile_template = "templates/vagrantfile.rocky.rb"
    vagrantfile_template_generated = false
  }
  post-processor "manifest" {
    output     = "boxes/manifest.json"
    strip_path = true
  }
  post-processor "checksum" {
    output         = "boxes/{{ .BuildName }}.${var.box_version}.checksum"
  }
}
