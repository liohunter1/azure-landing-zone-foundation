terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate"
    container_name       = "tfstate"
    key                  = "landing-zone/terraform.tfstate"

    # Authenticate via environment variables:
    # ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET
    # or ARM_USE_OIDC=true for federated identity (recommended for CI/CD)
  }
}
