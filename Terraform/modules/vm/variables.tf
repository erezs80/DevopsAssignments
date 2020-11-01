variable "vnet_location" {
  description = "The Azure location"
}

variable "RG_name" {
    description = "Resource group name"
}

variable "vm_names" {
    description = "vm names list"
    type        = list
}

variable "subnet_id" {
    description = "Subnet ID"
}

variable "availability_set_id" {
    description = "availability set id"
}

variable "backend_address_pool_id" {
    description = "load balancer backend address pool id"
}