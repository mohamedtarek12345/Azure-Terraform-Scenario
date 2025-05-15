resource "azurerm_public_ip" "lb_pip" {
  count               = var.lb_type == "public" ? 1 : 0
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = var.lb_type == "public" ? azurerm_public_ip.lb_pip[0].id : null
    subnet_id            = var.lb_type == "private" ? var.subnet_id : null
    private_ip_address_allocation = var.lb_type == "private" ? "Dynamic" : null
  }
}

resource "azurerm_lb_backend_address_pool" "lb" {
  name                = "${var.name}-bepool"
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb" {
  name                = "${var.name}-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = var.lb_probe_port
}

resource "azurerm_lb_rule" "lb" {
  name                           = "${var.name}-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = var.lb_port
  backend_port                   = var.lb_port
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb.id]
  probe_id                       = azurerm_lb_probe.lb.id
}
