resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.vnet_location
  resource_group_name = var.RG_name
  address_space       = var.address_prefix

  tags = {
    environment = "Demo"
  }
}