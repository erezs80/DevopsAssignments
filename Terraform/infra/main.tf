# Configure the Azure Provider
provider "azurerm" {
    version = "~>2.0"
    features {}
}

# Create a resource group
resource "azurerm_resource_group" "RG" {
  name     = "terraform-test"
  location = "EastUS"
}

module "eastusvnet" {
    source                = "../modules/vnet"
    
    vnet_location         = "EastUS"
    vnet_name             = "eastus-vnet"
    RG_name               = azurerm_resource_group.RG.name
    address_prefix        = ["10.0.0.0/16"]
}

module "northeuvnet" {
    source                = "../modules/vnet"
    
    vnet_location         = "NorthEurope"
    vnet_name             = "northeu-vnet"
    RG_name               = azurerm_resource_group.RG.name
    address_prefix        = ["10.1.0.0/16"]
}

module "eastussubnet" {
    source                = "../modules/subnet"

    virtual_network_name             = module.eastusvnet.vnet_name
    resource_group_name               = azurerm_resource_group.RG.name
    name           = "esatus-subnet"
    subnet_address_prefix = ["10.0.1.0/24"]
}

module "northeusubnet" {
    source                = "../modules/subnet"

    virtual_network_name             = module.northeuvnet.vnet_name
    resource_group_name               = azurerm_resource_group.RG.name
    name           = "northeu-subnet"
    subnet_address_prefix = ["10.1.1.0/24"]
}

module "eastusavas" {
    source                = "../modules/availabilitySet"

    availability_set_name = "eastus-as"
    RG_name               = azurerm_resource_group.RG.name
    vnet_location         = "EastUS"    
}

module "northeuas" {
    source                = "../modules/availabilitySet"

    availability_set_name = "northeu-as"
    RG_name               = azurerm_resource_group.RG.name
    vnet_location         = "NorthEurope"    
}

module "eastuslb" {
    source = "../modules/lb"

    resource_group_name               = azurerm_resource_group.RG.name
    ip_name                           = "eastus-pip"
    vnet_location                     = "EastUS"
    lb_name                           = "eastus-lb"  
}

module "northeulb" {
    source = "../modules/lb"

    resource_group_name               = azurerm_resource_group.RG.name
    ip_name                           = "northeu-pip"
    vnet_location                     = "NorthEurope"
    lb_name                           = "northeu-lb"  
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

module "eastusvms" {
    source                  = "../modules/vm"

    vnet_location           = "EastUS"
    RG_name                 = azurerm_resource_group.RG.name
    vm_names                = ["app1", "app2"]
    subnet_id               = module.eastussubnet.subnet_id
    availability_set_id     = module.eastusavas.availability_set_id
    backend_address_pool_id = module.eastuslb.backend_address_pool_id
    ssh_pub                 = tls_private_key.ssh.public_key_openssh 
}

module "northeuvms" {
    source                  = "../modules/vm"

    vnet_location           = "NorthEurope"
    RG_name                 = azurerm_resource_group.RG.name
    vm_names                = ["app1", "app2"]
    subnet_id               = module.northeusubnet.subnet_id
    availability_set_id     = module.northeuas.availability_set_id 
    backend_address_pool_id = module.northeulb.backend_address_pool_id
    ssh_pub                 = tls_private_key.ssh.public_key_openssh  
}

module "trafficmanager" {
    source = "../modules/traffic-manager"

    RG_name         = azurerm_resource_group.RG.name
    traffic_name    = "testmevaronisdev"
}

module "eastusendpoint" {
    source = "../modules/traffic-endpoints"

    endpoint_name           = "eastus-endpoint"
    RG_name                 = azurerm_resource_group.RG.name
    traffic_profile_name    = "testmevaronisdev"
    lb_ip                   = module.eastuslb.public_ip_address
    vnet_location           = "EastUS"    
}

module "northeuendpoint" {
    source = "../modules/traffic-endpoints"

    endpoint_name           = "northeu-endpoint"
    RG_name                 = azurerm_resource_group.RG.name
    traffic_profile_name    = "testmevaronisdev"
    lb_ip                   = module.northeulb.public_ip_address
    vnet_location           = "NorthEurope"    
}