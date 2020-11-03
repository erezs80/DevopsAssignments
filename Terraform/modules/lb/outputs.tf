output "lb_id" {
  description = "the id for the azurerm_lb resource"
  value       = azurerm_lb.azlb.id
}

output "lb_frontend_ip_configuration" {
  description = "the frontend_ip_configuration for the azurerm_lb resource"
  value       = azurerm_lb.azlb.frontend_ip_configuration
}

output "lb_probe_ids" {
  description = "the ids for the azurerm_lb_probe resources"
  value       = azurerm_lb_probe.azlb.id
}

output "public_ip_id" {
  description = "the id for the azurerm_lb_public_ip resource"
  value       = azurerm_public_ip.azlb.id
}

output "backend_address_pool_id" {
    value = azurerm_lb_backend_address_pool.azlb.id
}

output "public_ip_address" {
  description = "the ip address for the azurerm_lb_public_ip resource"
  value       = azurerm_public_ip.azlb.ip_address
}

output "public_fqdn" {
  description = "the ip address for the azurerm_lb_public_ip resource"
  value       = azurerm_public_ip.azlb.fqdn
}