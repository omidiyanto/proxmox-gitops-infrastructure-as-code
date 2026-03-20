variable "proxmox_ip" { type = string }
variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" { type = string }

variable "proxmox_node" {
  type    = string
  default = "pve"
}

variable "vm_id" { type = number }
variable "vm_name" { type = string }
variable "cpu_cores" { type = number }
variable "memory_mb" { type = number }
variable "disk_size" { type = string }
variable "network_bridge" { type = string }
variable "storage_pool" { type = string }

variable "iso_url" {
  type    = string
  default = ""
}

variable "iso_file" {
  type    = string
  default = ""
}

variable "iso_checksum" { type = string }
variable "iso_storage_pool" { type = string }