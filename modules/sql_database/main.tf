resource "azurerm_mssql_server" "sql" {
  name                         = "${var.name_prefix}-sqlserver"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "${var.name_prefix}-sqldb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}
