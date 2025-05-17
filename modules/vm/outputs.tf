output "vm_name" {
  value = var.name
}

output "nic_id" {
  value = azurerm_network_interface.nic.id
}

output "public_ip" {
  value = length(azurerm_public_ip.pip) > 0 ? azurerm_public_ip.pip[0].ip_address : null
}

output "vm_ids" {
  description = "All VM IDs"
  value       = concat(
    [for vm in azurerm_windows_virtual_machine.win : vm.id],
    [for vm in azurerm_linux_virtual_machine.linux : vm.id]
  )
}

output "storage_account_key" {
  value = var.storage_account_key
}
