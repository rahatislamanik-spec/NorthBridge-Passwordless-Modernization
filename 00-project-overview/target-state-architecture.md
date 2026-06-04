# Target State Architecture

**NorthBridge Financial Group — Identity & Access Management Program**
**Document:** TSA-001 | **Classification:** Internal | **Version:** 1.0
**Owner:** IAM Architecture Team | **Approved by:** CISO Office

---

## Executive Summary

This document defines the target authentication architecture for NorthBridge Financial Group following completion of the Passwordless Authentication Modernization program. It describes the intended end state for all authentication methods, Conditional Access policies, device trust, and identity governance controls that together eliminate password dependency across the 40,000-user workforce.

---

## 1. Target State Principles

| Principle | Definition |
|---|---|
| **Phishing-resistant by default** | No authentication flow relies on a credential that can be captured and replayed |
| **Device-bound credentials** | Primary authentication is tied to a specific trusted device — not a portable secret |
| **Zero standing password access** | Passwords are disabled as a usable credential for all in-scope workforce accounts |
| **Operationally supportable** | Every method has a documented recovery path that help desk can execute without exceptions |

---

## 2. Target Authentication Architecture

### 2.1 Method Assignment by User Population

| Population | Primary Method | Secondary / Recovery | Shared Device |
|---|---|---|---|
| Corporate knowledge workers | Windows Hello for Business | Authenticator passwordless | No |
| Remote / mobile workers | Authenticator passwordless | FIDO2 security key | No |
| Branch tellers — assigned device | Windows Hello for Business | FIDO2 security key | No |
| Branch tellers — shared workstation | FIDO2 security key (YubiKey 5 NFC) | TAP (recovery only) | Yes |
| IT administrators | FIDO2 security key | WHfB (secondary) | No |
| Privileged / break-glass accounts | FIDO2 security key (dedicated) | Hardware TOTP (offline) | No |
| Executives | WHfB + FIDO2 key (dual registered) | TAP (recovery only) | No |
| Contractors (managed device) | Authenticator passwordless | TAP (onboarding only) | No |

### 2.2 Authentication Flow — Corporate Knowledge Worker

    User approaches Windows 11 laptop
             |
             v
    Windows Hello for Business (PIN or biometric)
             |
             v
    Entra ID validates device-bound credential
             |
             v
    Conditional Access evaluates:
      - Device compliance (Intune)
      - Authentication strength (phishing-resistant)
      - Sign-in risk (Identity Protection)
             |
             v
    Access granted — no password transmitted

### 2.3 Authentication Flow — Branch Shared Workstation

    Employee inserts YubiKey 5 NFC into shared terminal
             |
             v
    Windows prompts for FIDO2 PIN
             |
             v
    Employee enters PIN — private key never leaves hardware token
             |
             v
    Entra ID validates FIDO2 assertion
             |
             v
    Conditional Access evaluates:
      - Authentication strength (FIDO2 = phishing-resistant)
      - Named location (branch network)
      - Device state (compliant shared device)
             |
             v
    Access granted to branch applications
    Employee removes YubiKey — session ends

---

## 3. Conditional Access Target State

### 3.1 Authentication Strength Policies

| Policy Name | Methods Allowed | Applied To |
|---|---|---|
| **NB-Strength-PhishingResistant** | WHfB, FIDO2, CBA | High-risk applications, admin portals |
| **NB-Strength-Passwordless** | WHfB, FIDO2, CBA, Authenticator passwordless | Standard workforce applications |
| **NB-Strength-MFA-Minimum** | All MFA methods | Low-risk internal applications (transitional) |

### 3.2 Conditional Access Policy Target State

| Policy | Users | Condition | Control |
|---|---|---|---|
| CA-001: Require phishing-resistant — admin roles | All privileged roles | Any access | NB-Strength-PhishingResistant |
| CA-002: Require phishing-resistant — high-risk apps | All users | Core banking, treasury, Azure portal | NB-Strength-PhishingResistant |
| CA-003: Require passwordless — all workforce | All users | All cloud apps | NB-Strength-Passwordless |
| CA-004: Block legacy authentication | All users | All apps | Block |
| CA-005: Require compliant device — corporate apps | All users | M365 apps | Compliant or hybrid joined device |
| CA-006: TAP — restrict high-risk app access | TAP users | High-risk apps | Block |
| CA-007: Sign-in risk — block high risk | All users | Any | Block if sign-in risk = High |
| CA-008: User risk — require password change | All users | Any | Require secure password change if user risk = High |

---

## 4. Device Trust Target State

| Device Type | Join Type | Compliance Policy | WHfB Enabled | FIDO2 Enabled |
|---|---|---|---|---|
| Corporate laptops | Hybrid Entra joined | Yes — Intune | Yes | Yes |
| Corporate desktops | Hybrid Entra joined | Yes — Intune | Yes | Yes |
| Shared branch workstations | Hybrid Entra joined | Yes — Intune (shared) | No | Yes |
| iOS corporate | Entra registered | Yes — Intune MAM | N/A | N/A |
| Android corporate | Entra registered | Yes — Intune MAM | N/A | N/A |
| BYOD (any) | Entra registered | App protection only | No | No |

---

## 5. Windows Hello for Business — Deployment Model

**Selected model: Cloud Kerberos Trust**

| Decision | Rationale |
|---|---|
| Cloud Kerberos trust over hybrid key trust | Eliminates PKI dependency — no certificate infrastructure required |
| Cloud Kerberos trust over cloud-only trust | NorthBridge has on-premises AD — cloud Kerberos trust bridges the hybrid environment |
| Azure AD Kerberos deployed to all 3 AD sites | Hard prerequisite — deployed in Phase 0 |
| PIN complexity: 8 character minimum | Aligns to OSFI B-13 authentication control requirements |
| Biometric unlock enabled | Face and fingerprint permitted on supported hardware |
| WHfB provisioning via Intune policy | Automated provisioning during device enrollment — no manual steps |

---

## 6. FIDO2 Security Key — Deployment Model

**Selected hardware: YubiKey 5 NFC**

| Decision | Rationale |
|---|---|
| YubiKey 5 NFC selected | Supports USB-A, USB-C, and NFC — compatible with all NorthBridge workstation types |
| Two keys issued per shared workstation user | Primary worn on lanyard, backup stored in branch safe |
| One key issued per privileged / admin user | IT admin, executive, break-glass accounts |
| FIDO2 PIN complexity enforced via Entra ID | 8 character minimum |
| Key registration performed by IT at onboarding | Self-service not permitted for branch staff |
| Lost key procedure | Report to help desk — disabled in Entra ID within 1 hour, TAP issued for recovery |

---

## 7. Temporary Access Pass — Policy Design

TAP is a time-limited passcode used exclusively as a bridge credential for onboarding and recovery.

| Parameter | Value | Rationale |
|---|---|---|
| TAP lifetime | 4 hours maximum | Minimizes exposure window |
| TAP usage | Single-use only | Prevents reuse after initial registration |
| TAP scope | Cannot access high-risk applications | CA-006 blocks TAP from core banking, treasury, admin portals |
| TAP issuance authority | Help desk Tier 2 and above | Prevents social engineering at Tier 1 |
| TAP issuance requirement | Valid ServiceNow ticket number required | Audit trail for every TAP issued |
| TAP logging | All issuance events logged to SIEM | Anomaly detection on TAP volume spikes |

---

## 8. Identity Protection Integration

| Control | Configuration | Action |
|---|---|---|
| Sign-in risk policy | High risk detected | Block sign-in — require help desk contact |
| User risk policy | High risk detected | Disable account — require IAM team review |
| MFA registration policy | Users without MFA | Prompt for registration at next sign-in |
| Risky sign-in alerts | Real-time | Alert SOC — investigate within 1 hour |

---

## 9. Current State vs Target State

| Dimension | Current State | Target State |
|---|---|---|
| Primary credential | Password | Device-bound phishing-resistant method |
| Phishing-resistant coverage | 4% | 95%+ |
| Legacy authentication | 3,200 events/day | 0 — fully blocked |
| CA policies enforcing auth strength | 0 | 8 active policies |
| Shared workstation auth | Password only | FIDO2 hardware key |
| TAP policy | Not configured | Single-use, 4-hour, ticket-gated |
| Password-only accounts | 8,800 | 0 |
| Help desk password tickets | 2,200/quarter | under 440/quarter |
| OSFI AAL compliance | AAL1 majority | AAL2 minimum, AAL3 for privileged |

---

## 10. Phase 0 Prerequisites

The following must be completed before any user enrollment begins:

| Prerequisite | Owner | Required For |
|---|---|---|
| Deploy Azure AD Kerberos to all 3 AD sites | IAM Engineering | WHfB cloud Kerberos trust |
| Remediate 143 Entra Connect sync errors | IAM Engineering | Clean enrollment baseline |
| Configure TAP policy in Entra ID | IAM Engineering | Onboarding and recovery |
| Enable FIDO2 and WHfB in Authentication Methods policy | IAM Engineering | Method availability |
| Deploy CA-004 in report-only mode | IAM Engineering | Legacy auth baseline |
| Procure YubiKey 5 NFC inventory (7,000 units) | Procurement | Branch and shared device rollout |
| Build help desk TAP issuance procedure | Service Desk Lead | Support readiness |
| Configure Intune WHfB enrollment policy | Endpoint Team | Automated WHfB provisioning |

---

*Document owner: IAM Architecture Team — NorthBridge Financial Group*
*Next review: Following Phase 1 completion*
*Related documents: business-problem.md | current-state-assessment.md*
