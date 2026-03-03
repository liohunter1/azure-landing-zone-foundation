# ---------------------------------------------------------------------------
# Hub Virtual Network
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${local.name_prefix}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------

resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_management_prefix]
}

resource "azurerm_subnet" "workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_workload_prefix]
}

# AzureBastionSubnet must use this exact name and be /26 or larger.
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_bastion_prefix]
}

# ---------------------------------------------------------------------------
# Subnet ↔ NSG associations
# ---------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}
