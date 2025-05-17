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
  value = [for vm in azurerm_linux_virtual_machine.linux : vm.id]
}

output "vm_id" {
  value = azurerm_windows_virtual_machine.win.id
}

output "storage_account_key" {
  value = azurerm_storage_account.storage_account.primary_access_key
}
