output "lb_id" {
  value = azurerm_lb.lb.id
}

output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.lb.id
}

output "public_ip_id" {
  value = var.lb_type == "public" ? azurerm_public_ip.lb_pip[0].id : null
}
