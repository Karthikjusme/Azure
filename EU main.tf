terraform {
  required_providers {
    azurerm = {                                                                                                                                                                                                          source = "hashicorp/azurerm"
      version = "2.68.0"
    }
  }
}

provider "azurerm" {

 features {}
}

variable "vmname1" {
  type = string
  default = "euwebserver1"
}


                                                                                                                                                                                                                   ## <https://www.terraform.io/docs/providers/azurerm/r/resource_group.html>
resource "azurerm_resource_group" "rg1" {
  name     = "NilavembuRG_EUS"
  location = "eastus2"
}                                                                                                                                                                                                                  
resource "azurerm_resource_group" "rg2" {
 name     = "NilavembuRG_SEA"
  location = "southeastasia"
}

                                                                                                                                                                                                                   ## <https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html>                                                                                                                                        resource "azurerm_virtual_network" "vnet" {
  name                = "eus-vNet"                                                                                                                                                                                   address_space       = ["10.20.0.0/16"]                                                                                                                                                                             location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "sea-vNet"                                                                                                                                                                                   address_space       = ["10.10.0.0/16"]
location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
}


## <https://www.terraform.io/docs/providers/azurerm/r/subnet.html>
resource "azurerm_subnet" "subnet1" {
  name                 = "websubnet1"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.20.10.0/24"]
}


resource "azurerm_public_ip" "webpip" {
  name                = "web-pip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "webnic" {
name = "${var.vmname1}-nic"
location            = azurerm_resource_group.rg1.location
resource_group_name = azurerm_resource_group.rg1.name                                                                                                                                                              
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webpip.id
}
}


 resource "azurerm_network_security_group" "euswebnsg" {
    name                = "EUS-WEB-NSG"
    location            = azurerm_resource_group.rg1.location
    resource_group_name = azurerm_resource_group.rg1.name

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


## <https://www.terraform.io/docs/providers/azurerm/r/windows_virtual_machine.html>
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "eus-webserver1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_D2ds_v4"
  admin_username      = "Karthick"
  admin_password      = "Aftertherain7"

  network_interface_ids = [ azurerm_network_interface.webnic.id,
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

  resource "azurerm_subnet_network_security_group_association" "euswebnsg" {
    subnet_id                 = azurerm_subnet.subnet1.id
   network_security_group_id = azurerm_network_security_group.euswebnsg.id
  }
resource "azurerm_virtual_network_peering" "vneteutovnetsea" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id
}

resource "azurerm_virtual_network_peering" "vnetseatovneteus" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.rg2.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}



resource "azurerm_storage_account" "storage" {
  name                     = "nilavembueusstracc"
  resource_group_name      = azurerm_resource_group.rg1.name
  location                 = azurerm_resource_group.rg1.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
enable_https_traffic_only = true
}

resource "azurerm_storage_share" "fileshare" {
  name                 = "salesdrive"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 32

  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2022-07-02T09:38:21.0000000Z"
      expiry      = "2022-07-02T10:38:21.0000000Z"
    }
  }
}

output "storageurl" {
  value = azurerm_storage_account.storage.primary_blob_endpoint
}

output "storagekey" {
  value = azurerm_storage_account.storage.primary_access_key
sensitive = true

}


               