# azure-landing-zone-foundation

Terraform-engineered Azure landing zone with secure networking, budget governance, and Bastion-based management access.

---

## Repository structure

```
azure-landing-zone-foundation/
├── terraform/
│   ├── main.tf          # Resource group and shared locals
│   ├── provider.tf      # AzureRM & AzureAD provider configuration
│   ├── variables.tf     # Input variables
│   ├── backend.tf       # Remote state backend (Azure Storage)
│   ├── vnet.tf          # Hub VNet, subnets, and NSG associations
│   ├── nsg.tf           # Network Security Groups
│   ├── bastion.tf       # Azure Bastion Host + Public IP
│   └── budgets.tf       # Azure Cost Management subscription budget
│
├── architecture/
│   └── landing-zone-diagram.drawio   # Architecture diagram (draw.io)
│
├── security-analysis/
│   └── threat-model.md               # STRIDE-based threat model
│
└── README.md
```

---

## Architecture overview

```
Internet
   │  HTTPS 443
   ▼
┌──────────────────────────────────────────────────────┐
│  Azure Subscription                                   │
│                                                       │
│  ┌────────────────────────────────────────────────┐  │
│  │  rg-lz-prod-hub (Resource Group)               │  │
│  │                                                │  │
│  │  ┌──────────────────────────────────────────┐  │  │
│  │  │  vnet-lz-prod-hub  (10.0.0.0/16)         │  │  │
│  │  │                                          │  │  │
│  │  │  AzureBastionSubnet  10.0.255.0/26       │  │  │
│  │  │  └─ Azure Bastion (Standard)             │  │  │
│  │  │     └─ Public IP (Static/Standard)       │  │  │
│  │  │                                          │  │  │
│  │  │  snet-management     10.0.1.0/24         │  │  │
│  │  │  └─ NSG: Allow SSH/RDP from Bastion only │  │  │
│  │  │     Deny all other inbound               │  │  │
│  │  │                                          │  │  │
│  │  │  snet-workload       10.0.2.0/24         │  │  │
│  │  │  └─ NSG: Allow from management only      │  │  │
│  │  │     Allow HTTPS outbound to AzureCloud   │  │  │
│  │  │     Deny all other inbound               │  │  │
│  │  └──────────────────────────────────────────┘  │  │
│  │                                                │  │
│  │  Cost Management Budget (monthly)              │  │
│  │  └─ Alert at 80 % and 100 % of budget          │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

---

## Prerequisites

| Requirement | Version |
|-------------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | >= 1.5.0 |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | >= 2.50 |
| Azure subscription with Owner or Contributor + User Access Administrator roles | — |

---

## Quick start

### 1. Create the Terraform state backend

Before running Terraform for the first time, create the Azure Storage resources for remote state:

```bash
LOCATION="eastus"
RG="rg-tfstate"
SA="sttfstate"           # must be globally unique; change if taken
CONTAINER="tfstate"

az group create -n $RG -l $LOCATION
az storage account create -n $SA -g $RG -l $LOCATION \
  --sku Standard_LRS --min-tls-version TLS1_2 \
  --allow-blob-public-access false
az storage container create -n $CONTAINER --account-name $SA
```

Update `terraform/backend.tf` with the storage account name you chose.

### 2. Authenticate

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

For CI/CD pipelines use federated OIDC credentials and set the following environment variables:

```
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
ARM_CLIENT_ID
ARM_USE_OIDC=true
```

### 3. Deploy

```bash
cd terraform

terraform init
terraform plan \
  -var="subscription_id=<SUBSCRIPTION_ID>" \
  -var="tenant_id=<TENANT_ID>" \
  -var='budget_alert_emails=["ops@example.com"]'

terraform apply \
  -var="subscription_id=<SUBSCRIPTION_ID>" \
  -var="tenant_id=<TENANT_ID>" \
  -var='budget_alert_emails=["ops@example.com"]'
```

---

## Input variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `subscription_id` | `string` | — | Azure Subscription ID |
| `tenant_id` | `string` | — | Azure AD Tenant ID |
| `environment` | `string` | `prod` | `dev`, `staging`, or `prod` |
| `location` | `string` | `eastus` | Azure region |
| `project` | `string` | `lz` | Short project identifier |
| `tags` | `map(string)` | `{}` | Additional resource tags |
| `vnet_address_space` | `list(string)` | `["10.0.0.0/16"]` | Hub VNet address space |
| `subnet_management_prefix` | `string` | `10.0.1.0/24` | Management subnet CIDR |
| `subnet_workload_prefix` | `string` | `10.0.2.0/24` | Workload subnet CIDR |
| `subnet_bastion_prefix` | `string` | `10.0.255.0/26` | Bastion subnet CIDR |
| `budget_amount` | `number` | `500` | Monthly budget in USD |
| `budget_alert_emails` | `list(string)` | `[]` | Notification emails |
| `budget_alert_thresholds` | `list(number)` | `[80, 100]` | Alert thresholds (%) |

---

## Security

See [security-analysis/threat-model.md](security-analysis/threat-model.md) for the full STRIDE-based threat model and risk register.

Key controls implemented by this landing zone:

- **No direct RDP/SSH** from the internet – all management access flows through Azure Bastion over HTTPS/443.
- **Deny-by-default NSGs** on management and workload subnets (priority 4096 explicit deny-all inbound).
- **Remote state** stored in Azure Storage with RBAC access control.
- **Budget governance** with configurable monthly alerts.

---

## Architecture diagram

Open [architecture/landing-zone-diagram.drawio](architecture/landing-zone-diagram.drawio) in [draw.io](https://app.diagrams.net/) or the VS Code draw.io extension.

---

## License

This project is licensed under the MIT License.
