resource "azurerm_network_interface" "nic" {
  count               = length(var.vm_names)
  name                = "${element(var.vm_names, count.index)}-${var.vnet_location}-nic"
  location            = var.vnet_location
  resource_group_name = var.RG_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = length(var.vm_names)
  name                = "${element(var.vm_names, count.index)}-${var.vnet_location}"
  resource_group_name = var.RG_name
  location            = var.vnet_location
  size                = "Standard_B2s"
  availability_set_id = var.availability_set_id
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_network_interface_backend_address_pool_association" "azlb" {
  count                   = length(var.vm_names)
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.backend_address_pool_id
}