variable "node_name" {
  description = "Proxmox Node Name (ex: pve)"
  type        = string
}

variable "vm_id" {
  description = "VM ID"
  type        = number
  default     = null 
}

variable "vm_name" {
  description = "VM Name"
  type        = string
}

variable "clone_vm_id" {
  description = "VM Template ID"
  type        = number
}

variable "cpu_cores" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 2048
}

variable "disk_size" {
  description = "Disk Size in GB"
  type        = number
  default     = 20
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

variable "ip_address" {
  description = "IP Address with CIDR (ex: 192.168.1.100/24) or dhcp"
  type        = string
  default     = "dhcp"
}

variable "gateway" {
  description = "IP Gateway (ex: 192.168.1.1). If DHCP, Let it empty"
  type        = string
  default     = ""
}

variable "dns_servers" {
  description = "DNS Servers list"
  type        = list(string)
  default     = []
}

variable "ssh_public_keys" {
  description = "SSH Public Key"
  type        = list(string)
  default     = []
}

variable "ci_user" {
  description = "User Cloud-Init"
  type        = string
  default     = "ubuntu"
}

variable "user_data_file_id" {
  description = "ID File snippet user-data for additional cloud-init scripts"
  type        = string
  default     = null
}