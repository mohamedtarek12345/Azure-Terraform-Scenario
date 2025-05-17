output "fileshare_mount_extension_id" {
  description = "IDs of the fileshare mount VM extensions"
  value       = azurerm_virtual_machine_extension.fileshare_mount[*].id
}
