# Current State Assessment

**NorthBridge Financial Group — Identity & Access Management Program**  
**Document:** CSA-001 | **Classification:** Internal | **Version:** 1.0  
**Owner:** IAM Architecture Team | **Assessment Period:** October–November 2024  

---

## Executive Summary

This document captures the baseline state of workforce authentication at NorthBridge Financial Group prior to the Passwordless Authentication Modernization program. It establishes the measurement baseline against which program success will be evaluated and identifies the specific gaps, risks, and populations that the modernization program must address.

Assessment conducted October–November 2024 using Microsoft Entra ID sign-in logs, Authentication Methods Activity reports, and Conditional Access policy analysis.

---

## 1. Identity Infrastructure Overview

| Component | Current State |
|---|---|
| **Directory** | Active Directory (on-premises) — 6 domain controllers across 3 sites |
| **Cloud identity** | Microsoft Entra ID — hybrid joined via Entra Connect sync |
| **Sync tool** | Microsoft Entra Connect v2.x — password hash sync enabled |
| **Device management** | Microsoft Intune — 68% of corporate devices enrolled |
| **Total user accounts** | 42,340 (40,000 workforce + 2,340 service/shared accounts) |
| **Licensed users (Entra ID P2)** | 40,000 workforce accounts |
| **Guest accounts** | 847 external collaborator accounts (out of scope) |
| **Hybrid joined devices** | 28,400 Windows devices |
| **Entra registered (personal)** | 4,200 iOS/Android devices |

---

## 2. Authentication Method Baseline

### 2.1 Registration Coverage

Assessment of all 40,000 workforce accounts against Microsoft Entra ID Authentication Methods Activity report:

| Authentication Method | Registered Users | Percentage | Risk Level |
|---|---|---|---|
| Password only — no MFA | 8,800 | 22% | Critical |
| Password + SMS OTP | 6,400 | 16% | High |
| Password + push MFA (Authenticator) | 23,200 | 58% | Medium |
| Password + TOTP (third-party app) | 980 | 2.5% | Medium |
| Windows Hello for Business | 940 | 2.4% | Low |
| FIDO2 security key | 180 | 0.5% | Low |
| Microsoft Authenticator passwordless | 480 | 1.2% | Low |
| **Any phishing-resistant method** | **1,600** | **4%** | — |

**Key finding:** 96% of workforce accounts have no phishing-resistant authentication method registered. The organization's effective phishing-resistant coverage is critically below acceptable threshold.

### 2.2 MFA Registration by Department

| Department | Total Users | MFA Registered | MFA % | Passwordless % |
|---|---|---|---|---|
| Information Technology | 420 | 418 | 99.5% | 28% |
| Corporate — Head Office | 3,200 | 3,088 | 96.5% | 6% |
| Finance & Treasury | 1,800 | 1,764 | 98% | 4% |
| Risk & Compliance | 640 | 634 | 99% | 5% |
| Branch Operations | 28,000 | 21,280 | 76% | 0.8% |
| Contact Centre | 4,200 | 3,654 | 87% | 0.5% |
| Executive & Senior Leadership | 180 | 180 | 100% | 12% |
| Contractors & Vendors | 1,560 | 982 | 63% | 0% |

**Key finding:** Branch Operations — the largest population at 28,000 users — has the lowest MFA coverage at 76% and near-zero passwordless adoption. This population also operates shared workstations, making standard passwordless methods non-viable without a dedicated shared device strategy.

---

## 3. Conditional Access Policy Analysis

### 3.1 Policy Inventory

At assessment baseline, NorthBridge had 23 active Conditional Access policies. Review findings:

| Policy Category | Count | Gap Identified |
|---|---|---|
| Require MFA — all users | 1 | Excludes legacy auth protocols — ineffective |
| Require MFA — privileged roles | 1 | Enforced but uses push MFA, not phishing-resistant |
| Block legacy authentication | 0 | **Critical gap — no legacy auth block in place** |
| Require compliant device | 2 | Scoped to 3 applications only |
| Authentication strength policies | 0 | **Critical gap — no phishing-resistant strength enforced** |
| Named location — trusted networks | 1 | Defined but used as MFA bypass — security risk |
| Sign-in risk policies | 2 | Enabled but alert-only, not blocking |
| User risk policies | 1 | Enabled but alert-only, not blocking |

**Critical finding:** NorthBridge had zero Conditional Access policies enforcing Authentication Strength. Push-based MFA was accepted as sufficient for all applications including high-risk financial systems. No policy blocked legacy authentication protocols.

### 3.2 Legacy Authentication Exposure

Analysis of Entra ID sign-in logs (30-day period, October 2024):

| Protocol | Daily Auth Volume | Applications Affected | MFA Enforced? |
|---|---|---|---|
| Basic Authentication (Exchange) | 1,840 | Exchange Online (legacy clients) | No |
| SMTP AUTH | 620 | Internal relay, legacy mail clients | No |
| IMAP | 280 | Legacy email clients | No |
| POP3 | 140 | Legacy email clients | No |
| NTLM (on-prem apps) | 320 | 6 internal web applications | No |
| **Total legacy auth volume** | **3,200/day** | **47 applications** | **None** |

**Key finding:** 3,200 successful legacy authentication events per day — all invisible to MFA enforcement. An attacker with a valid password credential can authenticate via legacy protocols regardless of MFA policy configuration.

---

## 4. Device State Assessment

### 4.1 Windows Device Inventory

| Device Category | Count | Join Type | WHfB Eligible | WHfB Enrolled |
|---|---|---|---|---|
| Corporate laptops | 18,200 | Hybrid Entra joined | Yes | 820 (4.5%) |
| Corporate desktops — assigned | 6,400 | Hybrid Entra joined | Yes | 120 (1.9%) |
| Branch shared workstations | 4,800 | Hybrid Entra joined | No — shared | 0 |
| Branch teller terminals | 2,200 | Domain joined only | No — legacy | 0 |
| Contact centre workstations | 1,600 | Hybrid Entra joined | Yes | 0 |
| **Total Windows devices** | **33,200** | — | **26,200 eligible** | **940 (2.8%)** |

**Key finding:** 4,800 shared workstations and 2,200 legacy teller terminals cannot use Windows Hello for Business. These 7,000 devices require an alternative phishing-resistant method — FIDO2 hardware keys are the designated solution.

### 4.2 Mobile Device Inventory

| Platform | Enrolled in Intune | Authenticator Installed | Passwordless Phone Sign-in Enabled |
|---|---|---|---|
| iOS (corporate) | 3,400 | 3,264 (96%) | 312 (9.2%) |
| Android (corporate) | 800 | 752 (94%) | 168 (21%) |
| iOS (personal — BYOD) | 2,800 | 1,960 (70%) | 84 (3%) |
| Android (personal — BYOD) | 1,200 | 720 (60%) | 24 (2%) |

---

## 5. Application Authentication Inventory

### 5.1 High-Risk Applications (Priority for Phishing-Resistant Enforcement)

| Application | Users | Current Auth Requirement | Legacy Auth? | Priority |
|---|---|---|---|---|
| Core Banking System | 22,000 | Password + push MFA | No | P1 |
| Treasury Management Platform | 340 | Password + push MFA | No | P1 |
| Entra ID Admin Portal | 48 | Password + push MFA | No | P1 |
| Azure Portal | 62 | Password + push MFA | No | P1 |
| Exchange Online (admin) | 24 | Password + push MFA | No | P1 |
| SharePoint — HR & Finance | 4,200 | MFA required | No | P2 |
| Microsoft 365 (general) | 38,000 | MFA required | Yes — partial | P2 |
| Branch Teller Application | 18,000 | Password only | Yes | P1 |
| VPN (remote access) | 6,400 | Password + push MFA | No | P1 |
| ServiceNow (ITSM) | 1,200 | Password + push MFA | No | P2 |

**Key finding:** The Branch Teller Application — used by 18,000 staff — accepts password-only authentication and supports legacy auth protocols. This is the highest-risk application in the estate and a primary target for the modernization program.

---

## 6. Identity Sync Health

Entra Connect sync health assessment (November 2024):

| Check | Status | Detail |
|---|---|---|
| Sync cycle | Healthy | Syncing every 30 minutes |
| Password hash sync | Enabled | All accounts syncing |
| Entra Connect version | Current | v2.x — supported |
| Sync errors | 143 accounts | Attribute conflicts — remediation required before rollout |
| Seamless SSO | Enabled | Configured for all domain-joined devices |
| Azure AD Kerberos | Not deployed | Required for WHfB cloud Kerberos trust — must deploy pre-rollout |

**Key finding:** Azure AD Kerberos has not been deployed to any AD site. This is a hard prerequisite for Windows Hello for Business cloud Kerberos trust deployment. Must be completed in Phase 0 before any WHfB rollout begins.

---

## 7. Gap Summary

| Gap | Severity | Affected Population | Resolution |
|---|---|---|---|
| 22% of users have no MFA | Critical | 8,800 users | Phase 1–2 enrollment drive |
| Zero phishing-resistant CA policies | Critical | All 40,000 users | Phase 1 CA deployment |
| No legacy auth block | Critical | 47 applications | Phase 1 — block legacy auth |
| WHfB not deployed at scale | High | 26,200 eligible devices | Phase 1–2 WHfB rollout |
| Shared workstations have no passwordless path | High | 18,000 branch staff | Phase 3 FIDO2 deployment |
| Azure AD Kerberos not deployed | High | All WHfB candidates | Phase 0 prerequisite |
| 143 sync errors in Entra Connect | Medium | 143 accounts | Phase 0 remediation |
| TAP policy not configured | Medium | All users | Phase 0 configuration |
| Authentication Strength policies absent | Critical | All applications | Phase 1 CA redesign |

---

## 8. Baseline Metrics for Program Measurement

The following metrics are recorded at baseline and will be tracked throughout the program:

| Metric | Baseline Value | Target |
|---|---|---|
| Phishing-resistant method coverage | 4% | 95%+ |
| MFA coverage (any method) | 78% | 100% |
| Legacy auth sign-in volume | 3,200/day | 0 |
| Password-only accounts | 8,800 | 0 |
| WHfB enrollment | 940 devices | 26,200 devices |
| FIDO2 key deployment | 180 users | 7,000 shared workstation users |
| Password-related help desk tickets | 2,200/quarter | <440/quarter |
| CA policies enforcing auth strength | 0 | 6+ |

---

*Document owner: IAM Architecture Team — NorthBridge Financial Group*  
*Next review: Following Phase 1 completion*  
*Related documents: business-problem.md | target-state-architecture.md*
