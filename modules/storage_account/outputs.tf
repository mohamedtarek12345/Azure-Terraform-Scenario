output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.storage_account.primary_access_key
  sensitive = true
}

output "fileshare_name" {
  value = azurerm_storage_share.storage_share.name
}
