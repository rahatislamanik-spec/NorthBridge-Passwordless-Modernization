# Business Problem Statement

**NorthBridge Financial Group — Identity & Access Management Program**  
**Document:** BP-001 | **Classification:** Internal | **Version:** 1.0  
**Owner:** IAM Architecture Team | **Approved by:** CISO Office  

---

## Executive Summary

NorthBridge Financial Group's workforce authentication model is built on a foundation that was designed for a different threat era. Passwords — even when combined with push-based MFA — are no longer sufficient to protect a regulated financial institution operating in a modern threat landscape.

This document defines the business problem that initiated the Passwordless Authentication Modernization program, establishes the regulatory and operational context, and justifies the decision to pursue phishing-resistant authentication across all 40,000 workforce identities.

---

## 1. The Triggering Incident

**Date:** September 2024  
**Classification:** P1 Security Incident — Credential Compromise  

In September 2024, NorthBridge's Security Operations Centre detected anomalous sign-in activity originating from 14 branch employee accounts across three Ontario locations. Investigation confirmed a coordinated password-spray attack targeting accounts with weak or reused passwords.

**Impact:**
- 14 accounts compromised across Hamilton, Mississauga, and Brampton branches
- Attackers accessed customer transaction records and internal SharePoint files
- 6-hour containment window required full branch IT lockdown during business hours
- Estimated total incident cost: $340,000 (containment, forensics, regulatory notification, reputational risk)
- OSFI incident notification filed within 72 hours per B-13 requirements

**Root cause:** All 14 compromised accounts used password-only authentication. MFA was enrolled but configured as optional. Attackers bypassed MFA by exploiting legacy authentication protocols that MFA policies did not cover.

**Conclusion:** The incident exposed two systemic failures — optional MFA enrollment and unblocked legacy authentication. Tightening password policy alone would not have prevented this attack. The IAM team recommended a phased transition to phishing-resistant, passwordless authentication.

---

## 2. The Threat Landscape

Passwords are the primary attack vector in financial services credential compromise. The attack patterns targeting NorthBridge are consistent with industry-wide trends:

| Attack Type | Description | Password Dependency |
|---|---|---|
| **Password spray** | Low-volume attempts across many accounts to avoid lockout | Directly exploits weak passwords |
| **Phishing** | Credential harvesting via fake login pages | Captures password + OTP in real time |
| **MFA fatigue** | Repeated push notifications to exhaust users into approving | Bypasses push-based MFA |
| **Legacy auth exploitation** | Targets protocols that bypass modern CA policies (SMTP, IMAP, POP3) | Passwords remain the only control |
| **Adversary-in-the-middle (AiTM)** | Reverse proxy intercepts session tokens after successful MFA | Defeats non-phishing-resistant MFA |

Push-based MFA — NorthBridge's current standard — does not protect against phishing, AiTM attacks, or MFA fatigue. Only phishing-resistant authentication methods provide protection against this full threat profile.

---

## 3. Regulatory Context

NorthBridge operates under federal financial services regulation. The following frameworks directly drive the requirement for phishing-resistant authentication:

### OSFI B-13 — Technology and Cyber Risk Guideline
The Office of the Superintendent of Financial Institutions (OSFI) B-13 guideline, effective January 2024, requires federally regulated financial institutions to implement strong authentication controls for all systems processing sensitive data.

Key requirements applicable to this program:
- Multi-factor authentication for all remote access and privileged operations
- Phishing-resistant authentication for high-risk access scenarios
- Annual review and attestation of authentication control effectiveness
- Documented exception process for accounts unable to meet standard controls

### PCI-DSS v4.0
NorthBridge processes cardholder data across branch point-of-sale systems and internal finance platforms. PCI-DSS v4.0 Requirement 8 mandates MFA for all access into the cardholder data environment (CDE) and requires phishing-resistant MFA for remote administrative access.

### NIST SP 800-63B
NorthBridge's internal security standards reference NIST SP 800-63B Authentication Assurance Levels. The target state for workforce authentication is **AAL2 minimum**, with **AAL3 required** for privileged and administrative accounts. AAL3 requires hardware-based phishing-resistant authenticators — met by FIDO2 security keys and Windows Hello for Business.

---

## 4. Current State Problems

### 4.1 Authentication Method Inventory (Baseline — October 2024)

| Authentication Method | Users Enrolled | Percentage |
|---|---|---|
| Password only | 8,800 | 22% |
| Password + SMS OTP | 6,400 | 16% |
| Password + push MFA (Authenticator) | 23,200 | 58% |
| Any passwordless method | 1,600 | 4% |
| Windows Hello for Business | 940 | 2.4% |
| FIDO2 security key | 180 | 0.5% |

**Summary:** 96% of NorthBridge workforce accounts have no phishing-resistant authentication method registered. 22% have no MFA at all.

### 4.2 Help Desk Burden

Password-related tickets represent the single largest category of IT support requests at NorthBridge:

| Ticket Type | Volume per Quarter | Estimated Cost |
|---|---|---|
| Password resets (self-service failed) | 1,100 | $19,800 |
| Account lockouts | 680 | $12,240 |
| MFA registration issues | 290 | $5,220 |
| Forgotten credentials — new device | 130 | $2,340 |
| **Total** | **2,200** | **$39,600** |

Estimated at $18 per ticket average (Tier 1 resolution). Tier 2 escalations average $47 per ticket and account for approximately 15% of volume.

### 4.3 Legacy Authentication Exposure

At baseline, NorthBridge had 47 applications still accepting legacy authentication protocols (Basic Auth, NTLM, form-based auth without MFA enforcement). These protocols bypass Conditional Access policies entirely, meaning an attacker with a valid password can authenticate regardless of MFA configuration.

Legacy auth sign-in volume at baseline: **3,200 successful authentications per day** across the tenant — all invisible to modern CA policy enforcement.

### 4.4 Shared Workstation Gap

NorthBridge operates 1,100+ branch locations. The majority of branch workstations are shared — multiple tellers and advisors sign in on the same physical device throughout the day. Windows Hello for Business, which binds credentials to a single user profile on a managed device, is not viable for these environments without a dedicated shared device authentication strategy.

At baseline, shared workstation users had no viable passwordless path. This gap affects approximately 18,000 branch staff.

---

## 5. The Cost of Inaction

| Risk | Estimated Annual Exposure |
|---|---|
| Credential compromise incident (similar to Q3 2024) | $340,000 per incident |
| OSFI regulatory finding — inadequate MFA controls | Potential audit finding, remediation mandate |
| PCI-DSS non-compliance — CDE access without phishing-resistant MFA | Up to $100,000/month in fines |
| Help desk password support overhead | $158,400/year |
| Productivity loss from lockouts and resets | Estimated 4,800 staff-hours/year |

Maintaining the status quo is not a neutral position. Each quarter without phishing-resistant authentication is a quarter of unacceptable regulatory and operational exposure.

---

## 6. Why Passwordless — Not Just Better MFA

The IAM team evaluated three options before recommending passwordless:

| Option | Description | Verdict |
|---|---|---|
| **Option A:** Enforce MFA for all users | Make push MFA mandatory, block legacy auth | Insufficient — push MFA is vulnerable to phishing and AiTM |
| **Option B:** Deploy phishing-resistant MFA only for privileged users | Scope to admins and high-risk roles | Insufficient — 96% of accounts remain exposed |
| **Option C:** Phased passwordless rollout for all workforce | WHfB + FIDO2 + Authenticator passwordless, eliminate passwords as primary credential | Recommended — addresses full threat profile, meets OSFI AAL requirements |

Option C was approved by the CISO in November 2024 with a 32-week rollout target.

---

## 7. Program Scope

| In Scope | Out of Scope |
|---|---|
| All 40,000 workforce identities in Entra ID | External/guest identities |
| Corporate Windows workstations (hybrid joined) | Consumer-facing customer authentication |
| Branch shared workstations | Service accounts and non-interactive identities |
| iOS and Android managed devices | On-premises application authentication (Phase 2 roadmap) |
| All Entra ID-integrated applications | Third-party federated applications without Entra ID integration |

---

## 8. Success Definition

The Passwordless Authentication Modernization program will be considered successful when:

- 95%+ of workforce accounts have at least one phishing-resistant method registered
- Password as a standalone authentication method is disabled for all in-scope accounts
- Legacy authentication protocols are fully blocked across all applications
- Help desk password-related ticket volume is reduced by 80%+
- Zero P1 credential compromise incidents attributable to password-based attacks in the 12 months following full rollout

---

*Document owner: IAM Architecture Team — NorthBridge Financial Group*  
*Next review: Quarterly or following any P1 identity incident*  
*Related documents: current-state-assessment.md | target-state-architecture.md*
