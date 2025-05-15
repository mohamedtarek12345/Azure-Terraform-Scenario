resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.name_prefix}-sql-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-sql-connection"
    private_connection_resource_id = var.sql_server_id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.name_prefix}-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
