output "fileshare_mount_extension_id" {
  description = "ID of the fileshare mount VM extension"
  value       = azurerm_virtual_machine_extension.fileshare_mount.id
}
