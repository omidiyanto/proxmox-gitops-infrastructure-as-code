resource "proxmox_virtual_environment_vm" "this" {
  name      = var.vm_name
  node_name = var.node_name
  vm_id     = var.vm_id

  # Clone from VM Template (Golden Image) builded by Packer
  clone {
    vm_id = var.clone_vm_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.storage_pool
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    dynamic "dns" {
      for_each = length(var.dns_servers) > 0 ? [1] : []
      content {
        servers = var.dns_servers
      }
    }
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway != "" ? var.gateway : null
      }
    }

    user_account {
      username = var.ci_user
      keys     = var.ssh_public_keys
    }

    user_data_file_id = var.user_data_file_id
  }

  operating_system {
    type = "l26" 
  }
}