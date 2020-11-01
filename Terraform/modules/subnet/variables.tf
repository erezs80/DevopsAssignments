variable "name" {
    description = "Subnet name"
}

variable "subnet_address_prefix" {
    description = "Subnet address prefix"
    type        = list
}

variable "virtual_network_name" {
    description = "The vnet name"
}

variable "resource_group_name" {
    description = "Resource group name"
}