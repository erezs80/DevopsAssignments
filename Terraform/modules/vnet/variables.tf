variable "vnet_location" {
  description = "The Azure location"
}

variable "vnet_name" {
    description = "The vnet name"
}

variable "RG_name" {
    description = "Resource group name"
}

variable "address_prefix" {
    description = "Vnet address prefix"
    type = list
}