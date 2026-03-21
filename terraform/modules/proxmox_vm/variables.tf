variable "node_name" {
  description = "Nama node Proxmox (misal: pve)"
  type        = string
}

variable "vm_id" {
  description = "ID untuk VM baru"
  type        = number
  default     = null # Jika null, Proxmox akan mencarikan ID kosong secara otomatis
}

variable "vm_name" {
  description = "Nama VM baru"
  type        = string
}

variable "clone_vm_id" {
  description = "ID dari VM Template yang ingin di-clone (misal: 900)"
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
  description = "Ukuran disk dalam GB"
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

# --- Cloud-Init Variables ---
variable "ip_address" {
  description = "IP Address dengan CIDR (misal: 192.168.1.100/24) atau dhcp"
  type        = string
  default     = "dhcp"
}

variable "gateway" {
  description = "IP Gateway (misal: 192.168.1.1). Kosongkan jika DHCP"
  type        = string
  default     = ""
}

variable "dns_servers" {
  description = "Daftar DNS Servers"
  type        = list(string)
  default     = []
}

variable "ssh_public_keys" {
  description = "List SSH Public Key untuk dimasukkan ke VM"
  type        = list(string)
  default     = []
}

variable "ci_user" {
  description = "User Cloud-Init"
  type        = string
  default     = "ubuntu"
}

variable "user_data_file_id" {
  description = "ID File snippet user-data khusus jika butuh injeksi script lanjutan"
  type        = string
  default     = null
}