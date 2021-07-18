
  
  resource "azurerm_network_security_group" "webnsg" {
    name                = "SEA -WEB-NSG"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
  
    security_rule {
      name                       = "HTTP"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "80"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    security_rule {
        name                       = "RDP"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "22"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
  

  }
  resource "azurerm_network_security_group" "jumpnsg" {
    name                = "SEA -WEB-NSG"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
  
    security_rule {
      name                       = "RDP"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "3389"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  
 
  }