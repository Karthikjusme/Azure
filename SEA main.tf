terraform {
  required_providers {
    azurerm = {                                                                                                                                                                                                          source = "hashicorp/azurerm"
      version = "2.68.0"
    }
  }
}

provider "azurerm" {

 features {}
}                                                                                                                                                                                                                                                                                                                                                                                                                                     variable "vmname1" {
  type = string
  default = "seawebserver1"
}
                                                                                                                                                                                                                   variable "vmname2" {
  type = string
  default = "seawebserver2"
}

variable "jumpvmname" {
  type = string
  default = "seajumpserver1"
}

## <https://www.terraform.io/docs/providers/azurerm/r/resource_group.html>
resource "azurerm_resource_group" "rg" {
  name     = "NilavembuRG_SEA"
  location = "southeastasia"
}

## <https://www.terraform.io/docs/providers/azurerm/r/availability_set.html>
resource "azurerm_availability_set" "aset" {
  name                = "sea-availabilityset1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  platform_fault_domain_count = 2
platform_update_domain_count = 2                                                                                                                                                                                   }                                                                                                                                                                                                                  
## <https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html>
resource "azurerm_virtual_network" "vnet" {
  name                = "sea-vNet"                                                                                                                                                                                   address_space       = ["10.10.0.0/16"]                                                               location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

## <https://www.terraform.io/docs/providers/azurerm/r/subnet.html>
resource "azurerm_subnet" "subnet1" {
  name                 = "websubnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.10.10.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "jumpsubnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.10.20.0/24"]
}


resource "azurerm_public_ip" "jumppip" {
  name                = "jump-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

}


## <https://www.terraform.io/docs/providers/azurerm/r/network_interface.html>
resource "azurerm_network_interface" "nic1" {
  name                = "webserver1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "webserver2-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"

}
}

resource "azurerm_network_interface" "jumpnic" {
name = "jumpserver-nic"
location            = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name                                                                                                                                                               
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.jumppip.id
}
}


 resource "azurerm_network_security_group" "seawebnsg" {
    name                = "SEA-WEB-NSG"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
      name                       = "HTTP"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    security_rule {
        name                       = "RDP"
        priority                   = 1100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }

}
  resource "azurerm_network_security_group" "jumpnsg" {
    name                = "SEA-Jump-NSG"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
      name                       = "RDP"
      priority                   = 1000
      direction                  = "Inbound"                                                                                                                                                                             access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }


  }


#VM Creation
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "sea-webserver1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "Karthick"
  admin_password      = "Aftertherain7"
  availability_set_id = azurerm_availability_set.aset.id
  network_interface_ids = [ azurerm_network_interface.nic1.id,
  ]
 disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "Ubuntuserver"
    sku       = "18.04-LTS"
    version   = "latest"
}

}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = var.vmname2
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "Karthick"
  admin_password      = "Aftertherain7"
  availability_set_id = azurerm_availability_set.aset.id
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]
 disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "Ubuntuserver"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "jumpvm" {
  name                = var.jumpvmname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "Karthick"
  admin_password      = "Aftertherain7"

  network_interface_ids = [
    azurerm_network_interface.jumpnic.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
   offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_interface_security_group_association" "webserver1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.seawebnsg.id
}
resource "azurerm_network_interface_security_group_association" "webserver2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.seawebnsg.id
}
resource "azurerm_network_interface_security_group_association" "jumpserver" {
  network_interface_id      = azurerm_network_interface.jumpnic.id
  network_security_group_id = azurerm_network_security_group.jumpnsg.id
}


resource "azurerm_public_ip" "lbpip" {
  name                = "sea-lb-pip"
  location            = "southeastasia"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
sku = "Standard"
}

resource "azurerm_lb" "lb1" {
  name                = "sea-lb1"
  location            = "southeastasia"
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
  frontend_ip_configuration {
    name                 = "Frontend-IP"
    public_ip_address_id = azurerm_public_ip.lbpip.id
  }

}
resource "azurerm_lb_backend_address_pool" "lbbp1" {
  loadbalancer_id = azurerm_lb.lb1.id
  name            = "BackEndAddressPool"
}


resource "azurerm_lb_backend_address_pool_address" "lbbpaddress" {
  name                    = "lbbeaddresspool"
  backend_address_pool_id = resource.azurerm_lb_backend_address_pool.lbbp1.id
  virtual_network_id      = resource.azurerm_virtual_network.vnet.id
  ip_address              = "10.10.10.4"
}

resource "azurerm_lb_backend_address_pool_address" "lbbpaddress2" {
name                    = "lbbeaddresspool2"
backend_address_pool_id = resource.azurerm_lb_backend_address_pool.lbbp1.id
virtual_network_id      = resource.azurerm_virtual_network.vnet.id
ip_address              = "10.10.10.5"
#ip_address              = "10.10.10.4"
}

resource "azurerm_lb_probe" "lbhp" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb1.id
  name                = "lb-hp1"
  port                = 80
}
resource "azurerm_lb_rule" "lbrule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb1.id
  name                           = "LB-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "Frontend-IP"
  load_distribution = "SourceIP"
backend_address_pool_id = resource.azurerm_lb_backend_address_pool.lbbp1.id
probe_id = azurerm_lb_probe.lbhp.id
}


resource "azurerm_storage_account" "example" {
  name                     = "nilavembustraccsea"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
enable_https_traffic_only = true
}
                                                                                  

                                                                                