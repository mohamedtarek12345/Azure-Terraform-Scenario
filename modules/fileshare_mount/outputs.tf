output "fileshare_mount_extension_id" {
  description = "IDs of the Windows fileshare mount VM extensions"
  value       = { for k, v in azurerm_virtual_machine_extension.fileshare_mount_windows : k => v.id }
}
