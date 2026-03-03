# Azure Landing Zone Foundation

## Objective
Engineer a secure Azure landing zone using Infrastructure-as-Code (Terraform) following enterprise-grade security principles.

---

## Security Design Philosophy

### 1. Deny by Default
All Network Security Groups enforce explicit allow rules and implicit deny.

### 2. No Public Management Plane
Azure Bastion replaces public RDP/SSH exposure.

### 3. Fiscal Governance
Budget alerts prevent uncontrolled resource sprawl.

### 4. Infrastructure Immutability
Resources are declaratively defined and version controlled.

---

## Threat Model Addressed

- RDP brute-force attacks
- Lateral movement in flat VNets
- Budget abuse via resource sprawl
- Misconfigured inbound firewall rules

---

## Architecture Components

- Azure Virtual Network
- Segmented subnets
- Network Security Groups
- Azure Bastion
- Azure Budget Alerts