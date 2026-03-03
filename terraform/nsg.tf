# ---------------------------------------------------------------------------
# Management subnet NSG
# ---------------------------------------------------------------------------

resource "azurerm_network_security_group" "management" {
  name                = "nsg-${local.name_prefix}-management"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  # Allow SSH/RDP only from the Bastion subnet
  security_rule {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.subnet_bastion_prefix
    destination_address_prefix = var.subnet_management_prefix
  }

  security_rule {
    name                       = "Allow-RDP-From-Bastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.subnet_bastion_prefix
    destination_address_prefix = var.subnet_management_prefix
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ---------------------------------------------------------------------------
# Workload subnet NSG
# ---------------------------------------------------------------------------

resource "azurerm_network_security_group" "workload" {
  name                = "nsg-${local.name_prefix}-workload"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  # Allow inbound from the management subnet only
  security_rule {
    name                       = "Allow-From-Management"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.subnet_management_prefix
    destination_address_prefix = var.subnet_workload_prefix
  }

  # Allow HTTPS outbound to Azure services
  security_rule {
    name                       = "Allow-HTTPS-Outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.subnet_workload_prefix
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
