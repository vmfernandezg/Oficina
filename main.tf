provider "azurerm" {
  version = "~>2.0" 
  subscription_id = "${var.sub}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources-for-Linux"
  location = "westeurope"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "main" {
  name                = "SantaluciaPIP"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "santalucia-azurerm-resource"
}

output "main_public_ip" {
   value = "${azurerm_public_ip.main.fqdn}"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.main.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.1.6"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

data "azurerm_image" "custom" {
  name                = "linux-image-packer"
  resource_group_name = "santalucia-imagenes-packer"
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm-linux"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_A2_v2"

storage_image_reference {
    id = "${data.azurerm_image.custom.id}"
}
  
storage_os_disk {
    name            = "${var.prefix}-Linux-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}
 
os_profile {
    computer_name  = "Prueba-Linux"
    admin_username = "arqsis"
    admin_password = "Password1234!"
}
    
os_profile_linux_config {
    disable_password_authentication = false
}

}