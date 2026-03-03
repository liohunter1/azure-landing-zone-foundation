# ---------------------------------------------------------------------------
# Locals – consistent naming convention
# ---------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    {
      environment = var.environment
      project     = var.project
      managed_by  = "terraform"
    },
    var.tags,
  )
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "hub" {
  name     = "rg-${local.name_prefix}-hub"
  location = var.location
  tags     = local.common_tags
}
