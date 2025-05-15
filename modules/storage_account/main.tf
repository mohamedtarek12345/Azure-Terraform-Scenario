resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  tags = var.tags
}

resource "azurerm_storage_share" "storage_share" {
  name                 = var.fileshare_name
  storage_account_id = azurerm_storage_account.storage_account.id
  quota                = var.share_quota_gb
}
