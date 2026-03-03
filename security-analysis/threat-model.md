# Threat Model – Azure Landing Zone Foundation

## 1. Overview

| Field         | Value                                                   |
|---------------|---------------------------------------------------------|
| **System**    | Azure Landing Zone Foundation                           |
| **Version**   | 1.0                                                     |
| **Date**      | 2024-01-01                                              |
| **Framework** | STRIDE                                                  |
| **Scope**     | Hub VNet, Subnets, NSGs, Azure Bastion, Cost Management |

---

## 2. Architecture Summary

The landing zone consists of a single hub Virtual Network (10.0.0.0/16) split into three subnets:

| Subnet               | CIDR            | Purpose                                |
|----------------------|-----------------|----------------------------------------|
| AzureBastionSubnet   | 10.0.255.0/26   | Hosts the Azure Bastion PaaS gateway   |
| snet-management      | 10.0.1.0/24     | Jump-host / management VMs             |
| snet-workload        | 10.0.2.0/24     | Application workloads                  |

All management access to VMs is channelled exclusively through Azure Bastion (HTTPS/443 from the public internet), eliminating direct RDP/SSH exposure. NSGs enforce deny-by-default policies on both subnets.

---

## 3. Assets

| Asset ID | Asset                              | Confidentiality | Integrity | Availability |
|----------|------------------------------------|-----------------|-----------|--------------|
| A-01     | Terraform state file               | High            | Critical  | Medium       |
| A-02     | Azure subscription credentials     | Critical        | Critical  | High         |
| A-03     | Virtual machines in management     | High            | High      | High         |
| A-04     | Workload data / application        | High            | High      | Critical     |
| A-05     | Network Security Group rules       | Medium          | Critical  | High         |
| A-06     | Budget alert email addresses       | Low             | Medium    | Low          |

---

## 4. Threat Analysis (STRIDE)

### 4.1 Spoofing

| ID     | Threat                                              | Target   | Mitigation                                                                 |
|--------|-----------------------------------------------------|----------|----------------------------------------------------------------------------|
| T-S-01 | Attacker impersonates a valid Azure AD identity     | A-02     | Enforce MFA, Conditional Access, and Privileged Identity Management (PIM). |
| T-S-02 | Attacker spoofs source IP to bypass NSG rules       | A-05     | Use service tags (`AzureBastionSubnet` prefix) rather than IP wildcards.   |

### 4.2 Tampering

| ID     | Threat                                              | Target   | Mitigation                                                                 |
|--------|-----------------------------------------------------|----------|----------------------------------------------------------------------------|
| T-T-01 | Unauthorised modification of Terraform state file   | A-01     | Store state in Azure Storage with RBAC + soft-delete + versioning enabled. Use storage account key rotation. |
| T-T-02 | NSG rule manipulation to open inbound paths         | A-05     | Apply Azure Policy to deny NSG rules that allow any-to-any inbound traffic. Enable Azure Defender for Network. |
| T-T-03 | Malicious Terraform module supply-chain attack      | A-01     | Pin provider/module versions. Enable dependency review. Use a private module registry. |

### 4.3 Repudiation

| ID     | Threat                                              | Target   | Mitigation                                                                 |
|--------|-----------------------------------------------------|----------|----------------------------------------------------------------------------|
| T-R-01 | Infrastructure changes made without audit trail     | A-01-05  | Enable Azure Activity Log export to Log Analytics. Enforce resource locks on core resources. |
| T-R-02 | Bastion session not logged                          | A-03     | Enable Bastion session recording (Azure Monitor / Diagnostic Settings).    |

### 4.4 Information Disclosure

| ID     | Threat                                              | Target   | Mitigation                                                                 |
|--------|-----------------------------------------------------|----------|----------------------------------------------------------------------------|
| T-I-01 | Terraform state exposes secrets in plaintext        | A-01     | Never store secrets in Terraform state; use Key Vault references. Restrict storage account access to CI/CD identity only. |
| T-I-02 | VM metadata accessible from workload subnet         | A-03     | Apply `DenyAccess` metadata endpoint policy via Azure Policy; use managed identities with minimal scope. |
| T-I-03 | Bastion session traffic intercepted                 | A-03     | Bastion uses TLS 1.2+ end-to-end; no additional mitigation required for transit. |

### 4.5 Denial of Service

| ID     | Threat                                              | Target   | Mitigation                                                                 |
|--------|-----------------------------------------------------|----------|----------------------------------------------------------------------------|
| T-D-01 | DDoS attack against Bastion Public IP               | A-03,A-04| Enable Azure DDoS Network Protection on the hub VNet.                      |
| T-D-02 | Resource exhaustion through runaway deployments     | A-04     | Budget alerts notify at 80 % and 100 % of monthly spend. Add Azure Policy cost controls. |

### 4.6 Elevation of Privilege

| ID     | Threat                                              | Target   | Mitigation                                                                 |
|--------|-----------------------------------------------------|----------|----------------------------------------------------------------------------|
| T-E-01 | Over-permissive service principal used by CI/CD     | A-02     | Use federated OIDC credentials with a custom role scoped to the target resource group only. |
| T-E-02 | VM compromised and used to pivot to management plane| A-03     | Enforce Azure AD Join + Defender for Servers on all VMs. Apply JIT VM Access. |
| T-E-03 | Lateral movement from workload to management subnet | A-04     | NSG on management subnet denies inbound from workload prefix; workload-to-management traffic is blocked by default. |

---

## 5. Risk Register

| ID     | Likelihood | Impact | Risk Level | Status      |
|--------|-----------|--------|------------|-------------|
| T-S-01 | Medium    | High   | High       | Mitigated   |
| T-T-01 | Low       | High   | Medium     | Mitigated   |
| T-T-02 | Low       | High   | Medium     | Mitigated   |
| T-T-03 | Low       | High   | Medium     | Open – pin versions |
| T-I-01 | Medium    | High   | High       | Mitigated   |
| T-D-01 | Low       | High   | Medium     | Open – enable DDoS Protection |
| T-E-01 | Medium    | High   | High       | Mitigated   |
| T-E-02 | Low       | High   | Medium     | Open – requires VM deployment |
| T-E-03 | Low       | High   | Medium     | Mitigated   |

---

## 6. Security Controls Summary

| Control                              | Service / Feature                                 | Status    |
|--------------------------------------|---------------------------------------------------|-----------|
| No direct RDP/SSH from internet      | Azure Bastion (HTTPS only)                        | ✅ Done    |
| Deny-by-default network policy       | NSG rules (priority 4096 deny-all inbound)        | ✅ Done    |
| Immutable Terraform state            | Azure Storage + RBAC + soft delete                | ✅ Done    |
| Cost governance                      | Azure Consumption Budget (80 % / 100 % alerts)    | ✅ Done    |
| DDoS Protection                      | Azure DDoS Network Protection                     | ⚠️ Manual |
| Audit logging                        | Azure Activity Log → Log Analytics                | ⚠️ Manual |
| Privileged Access Management         | PIM + Conditional Access + MFA                    | ⚠️ Manual |
| VM Just-in-Time Access               | Microsoft Defender for Cloud – JIT                | ⚠️ Manual |

---

## 7. Assumptions & Out-of-Scope

- Spoke VNet peering is out of scope for this version of the landing zone.
- Identity governance (Entra ID Governance) is managed outside this Terraform root module.
- DNS private zones and Private Endpoints are planned for a future iteration.

---

## 8. References

- [Microsoft Azure Well-Architected Framework – Security](https://learn.microsoft.com/en-us/azure/well-architected/security/)
- [Azure Landing Zone – Conceptual Architecture](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Bastion Security Baseline](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/bastion-security-baseline)
- [STRIDE Threat Modeling](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
