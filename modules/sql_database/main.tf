resource "azurerm_mssql_server" "sql" {
  name                         = "${var.name_prefix}-sqlserver"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  minimum_tls_version         = "1.2"

  identity {
    type = "SystemAssigned"
  }

  timeouts {
    create = "2h"
    delete = "2h"
    update = "2h"
    read   = "5m"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_mssql_database" "sqldb" {
  name           = "${var.name_prefix}-sqldb"
  server_id      = azurerm_mssql_server.sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "S0"
  zone_redundant = false

  timeouts {
    create = "2h"
    delete = "2h"
    update = "2h"
    read   = "5m"
  }

  depends_on = [
    azurerm_mssql_server.sql
  ]
}
