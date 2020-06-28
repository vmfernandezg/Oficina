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

resource "azurerm_network_security_group" "main" {
    name                = "myNetworkSecurityGroup"
    location            = "westeurope"
    resource_group_name = "${azurerm_resource_group.main.name}"
    
    security_rule {
        name                       = "Access-SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  
     security_rule {
        name                       = "Access-http"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  #network_security_group_id = "${azurerm_network_security_group.main.id}"

ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.main.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.0.1.6"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = "${azurerm_network_interface.main.id}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"
}

#resource "azurerm_managed_disk" "datadisk" {
  #name                 = "${var.prefix}-Linux-datadisk"
  #location             = "${azurerm_resource_group.main.location}"
  #resource_group_name  = "${azurerm_resource_group.main.name}"
  #storage_account_type = "Standard_LRS"
  #create_option        = "Empty"
  #disk_size_gb         = "32767"
#}

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

#storage_image_reference {
    #id = "/subscriptions/dd648d68-599e-4dc6-a4ee-988b14e75b34/resourceGroups/santalucia-imagenes-packer/providers/Microsoft.Compute/images/linux-image-packer"
#}

#storage_image_reference {
    #publisher = "OpenLogic"
    #offer     = "CentOS"
    #sku       = "7.5"
    #version   = "latest"
#}

storage_image_reference {
    id = "${data.azurerm_image.custom.id}"
}
  
storage_os_disk {
    name            = "${var.prefix}-Linux-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}

#storage_data_disk {
    #name              = "${var.prefix}-Linux-datadisk"
    #managed_disk_id   = "${azurerm_managed_disk.datadisk.id}"
    #managed_disk_type = "Standard_LRS"
    #disk_size_gb      = "1023"
    #create_option     = "Attach"
    #lun               = 0
#}
 
os_profile {
    computer_name  = "Prueba-Linux"
    admin_username = "arqsis"
    admin_password = "Password1234#"
}
    
os_profile_linux_config {
    disable_password_authentication = false
        #ssh_keys {
        #path     = "/root/.ssh/authorized_keys"
        #key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCntFQwuKzxj+ETFd1H+YIrEn4JGy6WZI7Q02whS/2xzIyEvN3g/Le72HtORhwY2gE8uHJ1zcassOvvWkWctMq8LrZEYiJ1LgU3pImpz4qubHUs1HctQU0j6Pzr1e5dNMjUi3raPnRrf7EVhkA1S7JUglbE22kM/mTYmcHwbfz8evELuoePw/M4YS5tA9M7N52iQi4HxxCFZOJE12SftDuZlIIkMbLK/TmEWM7WNtWjZ3tqSGvLPynxE5GcHcmvJ37oIg8oVUmF5b1URWYyFzkHMK0Gq/PlvQUldVIQ8BnWqqJZ7DEeqbpUIF1gU3ychS0iJwVktnbKg8BikPh7S8bp root@bitnami-jenkins-0858"
  #}
}

}