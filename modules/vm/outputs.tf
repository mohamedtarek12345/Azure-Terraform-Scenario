output "vm_name" {
  value = var.name
}

output "nic_id" {
  value = azurerm_network_interface.nic.id
}

output "public_ip" {
  value = length(azurerm_public_ip.pip) > 0 ? azurerm_public_ip.pip[0].ip_address : null
}

output "windows_vm_id" {
  description = "Windows VM ID"
  value       = var.os_type == "Windows" ? azurerm_windows_virtual_machine.win[0].id : null
}

output "linux_vm_id" {
  description = "Linux VM ID"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.linux[0].id : null
}

output "storage_account_key" {
  value = var.storage_account_key
}
