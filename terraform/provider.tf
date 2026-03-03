# Standard Terraform block to define the provider requirements
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Ensures we use a stable 3.x version
    }
  }
}

# The provider block to configure the Azure Resource Manager (ARM)
provider "azurerm" {
  features {} # This block is required for the Azure provider to function
}