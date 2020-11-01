resource "azurerm_public_ip" "azlb" {
  name                         = var.ip_name
  location                     = var.vnet_location
  resource_group_name          = var.resource_group_name
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${var.ip_name}-lb"
  tags = {
    environment = "Demo"
  }
}

resource "azurerm_lb" "azlb" {
  name                = var.lb_name
  resource_group_name = var.resource_group_name
  location            = var.vnet_location
  sku                 = "Standard"
  tags = {
    environment = "Demo"
  }

  frontend_ip_configuration {
    name                          = "PublicIPAddress"
    public_ip_address_id          = azurerm_public_ip.azlb.id
  }
}

resource "azurerm_lb_backend_address_pool" "azlb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "azlb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.azlb.id
  name                = "hc"
  protocol            = "Http"
  port                = "80"
  request_path        = "/"
  interval_in_seconds = "15"
  number_of_probes    = "2"
}

resource "azurerm_lb_rule" "azlb" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.azlb.id
  name                           = "rule1"
  protocol                       = "Tcp"
  frontend_port                  = "80"
  backend_port                   = "80"
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.azlb.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.azlb.id
  depends_on                     = [azurerm_lb_probe.azlb]
}
