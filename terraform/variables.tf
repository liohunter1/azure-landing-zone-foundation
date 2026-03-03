# ---------------------------------------------------------------------------
# Core identity
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "The Azure Subscription ID to deploy resources into."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory Tenant ID."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming & location
# ---------------------------------------------------------------------------

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

variable "project" {
  description = "Short project identifier used in resource names."
  type        = string
  default     = "lz"
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

variable "vnet_address_space" {
  description = "Address space for the hub virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_management_prefix" {
  description = "Address prefix for the management subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_workload_prefix" {
  description = "Address prefix for the workload subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_bastion_prefix" {
  description = "Address prefix for the AzureBastionSubnet (must be /26 or larger)."
  type        = string
  default     = "10.0.255.0/26"
}

# ---------------------------------------------------------------------------
# Budget governance
# ---------------------------------------------------------------------------

variable "budget_amount" {
  description = "Monthly budget limit in USD."
  type        = number
  default     = 500
}

variable "budget_alert_emails" {
  description = "List of email addresses to notify when budget thresholds are reached."
  type        = list(string)
  default     = []
}

variable "budget_alert_thresholds" {
  description = "List of percentage thresholds (of budget_amount) at which alerts are sent."
  type        = list(number)
  default     = [80, 100]
}
