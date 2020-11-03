resource "azurerm_traffic_manager_endpoint" "traffic" {
  name                = var.endpoint_name
  resource_group_name = var.RG_name
  profile_name        = var.traffic_profile_name
  target              = var.lb_fqdn
  type                = "externalEndpoints"
  endpoint_location   = var.vnet_location
}