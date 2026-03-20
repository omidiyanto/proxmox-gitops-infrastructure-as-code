packer {
  required_plugins {
    proxmox = {
      version = "~> 1.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  vm_id                = var.vm_id
  vm_name              = var.vm_name
  template_description = "Managed by GitOps (Packer)"

  boot = "order=scsi0;ide2"

  boot_iso {
    iso_url          = var.iso_file == "" ? var.iso_url : null
    iso_file         = var.iso_file != "" ? var.iso_file : null
    iso_checksum     = var.iso_checksum
    unmount          = true
    iso_storage_pool = var.iso_storage_pool
  }

  os              = "l26"
  cores           = var.cpu_cores
  memory          = var.memory_mb
  scsi_controller = "virtio-scsi-pci"

  cloud_init              = true
  cloud_init_storage_pool = var.storage_pool
  qemu_agent              = true

  network_adapters {
    model    = "virtio"
    bridge   = var.network_bridge
    firewall = "false"
  }

  disks {
    disk_size    = var.disk_size
    format       = "raw"
    storage_pool = var.storage_pool
    type         = "scsi"
  }

  additional_iso_files {
    cd_files = [
      "http/user-data",
      "http/meta-data"
    ]
    cd_label         = "cidata" # Label ini sangat penting agar terdeteksi ds=nocloud
    iso_storage_pool = var.iso_storage_pool
    unmount          = true
  }

  boot_wait = "10s"

  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

  ssh_username               = "ubuntu"
  ssh_private_key_file       = "ssh_key_for_packer"
  ssh_timeout                = "60m"
  ssh_bastion_host           = var.proxmox_ip
  ssh_bastion_username       = "root"
  ssh_bastion_private_key_file = "ssh_key_for_packer"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Menunggu cloud-init...'; sleep 2; done",
      "sudo cloud-init clean",
      "sudo rm -rf /etc/cloud/cloud.cfg.d/*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo sync"
    ]
  }
}