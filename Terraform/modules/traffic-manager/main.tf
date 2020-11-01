resource "azurerm_traffic_manager_profile" "traffic" {
  name                = var.traffic_name
  resource_group_name = var.RG_name

  traffic_routing_method = "Performance"

  dns_config {
    relative_name = var.traffic_name
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = {
    environment = "Demo"
  }
}