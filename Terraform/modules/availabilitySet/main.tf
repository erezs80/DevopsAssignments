resource "azurerm_availability_set" "as" {
  name                = var.availability_set_name
  location            = var.vnet_location
  resource_group_name = var.RG_name

  tags = {
    environment = "Demo"
  }
}