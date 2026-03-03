# Azure Landing Zone Foundation

## Objective
Design and deploy a secure Azure landing zone using Terraform with strong governance, network isolation, and management plane protection.

---

## Architecture Overview
- Hub-and-Spoke VNet topology
- Dedicated management subnet
- Network Security Groups with deny-by-default posture
- Azure Bastion for secure VM access
- Budget alerts for FinOps governance

---

## Security Design Principles

### 1. Least Exposure
No public IP addresses on management or workload VMs.

### 2. Explicit Deny
All NSGs enforce deny-by-default inbound policy.

### 3. Fiscal Governance
Automated budget alerts prevent resource sprawl and anomaly spending.

---

## Threat Model Summary
Primary risks addressed:
- RDP brute force attacks
- Lateral movement across flat networks
- Budget abuse through resource sprawl
- Misconfigured inbound firewall rules

---

## Future Enhancements
- Azure Policy enforcement
- DDoS Protection Plan
- NAT Gateway for controlled egress# azure-landing-zone-foundation
erraform-engineered Azure landing zone with secure networking, budget governance, and Bastion-based management access.
