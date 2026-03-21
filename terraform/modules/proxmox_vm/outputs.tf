output "vm_ipv4_address" {
  description = "VM IP Address"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses[1][0]
}

output "vm_name" {
  value = proxmox_virtual_environment_vm.this.name
}