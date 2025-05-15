output "subnet_id" {
  description = "ID of the created subnet"
  value       = azurerm_subnet.subnet.id
}
output "subnet_name" {
  description = "Name of the created subnet"
  value       = azurerm_subnet.subnet.name
}      
output "sub_add_prf" {
  description = "Address prefixes of the created subnet"
  value       = azurerm_subnet.subnet.address_prefixes
}
output "sub_rg_name" {
  description = "Resource group name of the created subnet"
  value       = azurerm_subnet.subnet.resource_group_name
}
output "sub_vnet_name" {
  description = "Virtual network name of the created subnet"
  value       = azurerm_subnet.subnet.virtual_network_name
}

