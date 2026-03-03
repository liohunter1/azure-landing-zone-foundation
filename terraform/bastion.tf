# ---------------------------------------------------------------------------
# Public IP for Azure Bastion
# ---------------------------------------------------------------------------

resource "azurerm_public_ip" "bastion" {
  name                = "pip-${local.name_prefix}-bastion"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = local.common_tags
}

# ---------------------------------------------------------------------------
# Azure Bastion Host
# ---------------------------------------------------------------------------

resource "azurerm_bastion_host" "hub" {
  name                = "bas-${local.name_prefix}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  scale_units         = 2

  # Native client support and tunnelling require SKU = Standard
  tunneling_enabled        = true
  shareable_link_enabled   = false
  ip_connect_enabled       = false
  copy_paste_enabled       = true
  file_copy_enabled        = true

  ip_configuration {
    name                 = "ipconf-bastion"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = local.common_tags
}
