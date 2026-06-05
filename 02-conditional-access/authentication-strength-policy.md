# Authentication Strength Policy Design

**NorthBridge Financial Group — Identity & Access Management Program**
**Document:** CA-001 | **Classification:** Internal | **Version:** 1.0
**Owner:** IAM Architecture Team | **Review Cycle:** Quarterly

---

## Executive Summary

This document defines the Authentication Strength policy architecture deployed in Microsoft Entra ID as part of the NorthBridge Passwordless Authentication Modernization program. Authentication Strength policies replace generic MFA requirements in Conditional Access by explicitly naming which authentication methods are acceptable for a given access scenario.

This approach ensures that phishing-resistant methods are enforced by policy — not assumed by MFA claim — and provides a durable, auditable control that satisfies OSFI B-13 and PCI-DSS v4.0 requirements for high-assurance authentication.

---

## 1. Why Authentication Strength Over MFA Claims

Prior to this program, NorthBridge Conditional Access policies used the control "Require multi-factor authentication." This control accepts any registered MFA method — including SMS OTP, push notifications, and software TOTP — none of which are phishing-resistant.

The problem: a policy that says "require MFA" and a policy that says "require phishing-resistant MFA" look identical in the portal if you do not inspect the grant controls carefully. The former is exploitable. The latter is not.

Authentication Strength policies solve this by:

| Problem | Solution |
|---|---|
| Push MFA accepted where phishing-resistant required | Named strength policy explicitly excludes push MFA |
| SMS OTP accepted as MFA in high-risk app policies | Named strength policy explicitly excludes SMS |
| No audit trail of which methods were acceptable at time of access | Strength policy name is logged in every sign-in event |
| CA policy intent unclear from grant control alone | Strength policy name communicates intent — NB-Strength-PhishingResistant is self-documenting |

---

## 2. NorthBridge Authentication Strength Policies

Three custom Authentication Strength policies are defined for NorthBridge. All three are created in Entra ID under Protection > Authentication Methods > Authentication Strengths.

---

### 2.1 NB-Strength-PhishingResistant

**Purpose:** Highest assurance level. Required for all privileged access and high-risk financial applications.
**NIST AAL equivalent:** AAL3
**OSFI B-13 alignment:** Satisfies phishing-resistant MFA requirement for high-risk access

**Allowed combinations:**

| Method | Allowed | Notes |
|---|---|---|
| Windows Hello for Business | Yes | Device-bound, PIN or biometric |
| FIDO2 security key | Yes | Hardware-bound, PIN required |
| Certificate-based authentication (MFA) | Yes | Smart card or software certificate with MFA claim |
| Microsoft Authenticator (push) | No | Not phishing-resistant |
| SMS OTP | No | Not phishing-resistant |
| Software TOTP | No | Not phishing-resistant |
| Temporary Access Pass | No | Bridge credential only — excluded from high-risk apps |

**Applied to via Conditional Access:**
- CA-001: All Entra ID privileged roles (Global Admin, Privileged Role Admin, Security Admin, etc.)
- CA-002: Core Banking System, Treasury Management Platform, Azure Portal, Entra Admin Portal

**Configuration in Entra ID:**
- Name: NB-Strength-PhishingResistant
- Allowed method combinations: WindowsHelloForBusiness, Fido2SecurityKey, x509CertificateMultiFactor
- Custom policy: Yes
- Built-in equivalent: Phishing-resistant MFA (Microsoft built-in — used as reference)

---

### 2.2 NB-Strength-Passwordless

**Purpose:** Standard assurance level for workforce application access. Requires passwordless method but permits Authenticator passwordless phone sign-in in addition to hardware-bound methods.
**NIST AAL equivalent:** AAL2+
**OSFI B-13 alignment:** Satisfies MFA requirement for standard workforce access

**Allowed combinations:**

| Method | Allowed | Notes |
|---|---|---|
| Windows Hello for Business | Yes | Device-bound, PIN or biometric |
| FIDO2 security key | Yes | Hardware-bound, PIN required |
| Certificate-based authentication (MFA) | Yes | Smart card or software certificate with MFA claim |
| Microsoft Authenticator passwordless | Yes | Device-bound, number matching required |
| Microsoft Authenticator (push) | No | Push MFA alone not accepted |
| SMS OTP | No | Not accepted |
| Software TOTP | No | Not accepted |
| Temporary Access Pass | No | Excluded from standard workforce apps during enforcement |

**Applied to via Conditional Access:**
- CA-003: All users, all Microsoft 365 and Entra ID-integrated applications

**Configuration in Entra ID:**
- Name: NB-Strength-Passwordless
- Allowed method combinations: WindowsHelloForBusiness, Fido2SecurityKey, x509CertificateMultiFactor, MicrosoftAuthenticatorPasswordless
- Custom policy: Yes

---

### 2.3 NB-Strength-MFA-Minimum

**Purpose:** Transitional assurance level for low-risk internal applications during phased rollout. Accepts any MFA method. Will be retired at end of Phase 4 when full passwordless coverage is achieved.
**NIST AAL equivalent:** AAL2
**OSFI B-13 alignment:** Satisfies baseline MFA requirement — not sufficient for high-risk access

**Allowed combinations:**

| Method | Allowed | Notes |
|---|---|---|
| Windows Hello for Business | Yes | |
| FIDO2 security key | Yes | |
| Microsoft Authenticator passwordless | Yes | |
| Microsoft Authenticator (push) | Yes | Accepted during transition period |
| Software TOTP | Yes | Accepted during transition period |
| SMS OTP | No | Excluded even at minimum level — below NorthBridge baseline |
| Password only | No | Never accepted |

**Applied to via Conditional Access:**
- Low-risk internal applications only
- Scheduled for retirement: End of Phase 4 (Week 32)

**Configuration in Entra ID:**
- Name: NB-Strength-MFA-Minimum
- Allowed method combinations: All MFA combinations except SMS and voice
- Custom policy: Yes

---

## 3. Conditional Access Policy Configuration

### CA-001: Require Phishing-Resistant — Privileged Roles

| Parameter | Value |
|---|---|
| Policy name | CA-001-NB-PhishingResistant-PrivilegedRoles |
| Users | Directory role members: Global Administrator, Privileged Role Administrator, Security Administrator, Exchange Administrator, SharePoint Administrator, Intune Administrator, Conditional Access Administrator |
| Cloud apps | All cloud apps |
| Conditions | Any platform, any location |
| Grant control | Require authentication strength: NB-Strength-PhishingResistant |
| Session controls | Sign-in frequency: 8 hours |
| State | Report-only (Weeks 1-2) then Enabled |

---

### CA-002: Require Phishing-Resistant — High-Risk Applications

| Parameter | Value |
|---|---|
| Policy name | CA-002-NB-PhishingResistant-HighRiskApps |
| Users | All users |
| Cloud apps | Core Banking System, Treasury Management Platform, Azure Portal, Microsoft Entra Admin Center, Exchange Admin Center |
| Conditions | Any platform, any location |
| Grant control | Require authentication strength: NB-Strength-PhishingResistant |
| Session controls | Sign-in frequency: 4 hours, persistent browser session: No |
| State | Report-only (Weeks 1-2) then Enabled |

---

### CA-003: Require Passwordless — All Workforce

| Parameter | Value |
|---|---|
| Policy name | CA-003-NB-Passwordless-AllUsers |
| Users | All users (exclude: break-glass accounts, service accounts group) |
| Cloud apps | All cloud apps |
| Conditions | Any platform, any location |
| Grant control | Require authentication strength: NB-Strength-Passwordless |
| Session controls | Sign-in frequency: 12 hours |
| State | Report-only (Weeks 1-12) then Enabled at Phase 3 |

---

### CA-004: Block Legacy Authentication

| Parameter | Value |
|---|---|
| Policy name | CA-004-NB-Block-LegacyAuthentication |
| Users | All users |
| Cloud apps | All cloud apps |
| Conditions | Client apps: Exchange ActiveSync clients, Other clients |
| Grant control | Block |
| State | Report-only (Weeks 1-2) then Enabled |
| Pre-enablement requirement | Legacy auth sign-in volume must reach zero in report-only logs |

---

### CA-006: Restrict TAP — Block High-Risk Applications

| Parameter | Value |
|---|---|
| Policy name | CA-006-NB-TAP-BlockHighRiskApps |
| Users | All users |
| Cloud apps | Core Banking System, Treasury Management, Azure Portal, Entra Admin Center |
| Conditions | Authentication context: TAP sign-in (enforced via named authentication context) |
| Grant control | Block |
| State | Enabled from Day 1 — no report-only period |

---

## 4. Report-Only Rollout Sequence

Every CA policy runs in report-only mode before enforcement. This is non-negotiable.

| Week | Action |
|---|---|
| Week 1 | Deploy CA-001, CA-002, CA-003, CA-004 in report-only mode |
| Week 1-2 | Review sign-in logs daily — identify users who would be blocked |
| Week 2 | Enable CA-006 (TAP restriction) — enforcement from day one, no report-only |
| Week 3 | Enable CA-004 (block legacy auth) if report-only log shows zero legitimate legacy auth |
| Week 4 | Enable CA-001 (privileged roles) after IT pilot group confirms WHfB registered |
| Week 5 | Enable CA-002 (high-risk apps) after Phase 1 registration confirmed |
| Week 13 | Enable CA-003 (all workforce) at start of Phase 3 after 80%+ passwordless coverage |

---

## 5. Sign-In Log Monitoring

During report-only periods, the IAM team reviews Entra ID sign-in logs daily using the following filters:

| Log Filter | Purpose |
|---|---|
| Conditional Access result = Report-only: Failure | Identifies users who would be blocked on enforcement |
| Authentication method = Password | Identifies users signing in with password only |
| Client app = Other clients OR Exchange ActiveSync | Identifies legacy authentication volume |
| Authentication strength = not satisfied | Identifies gap between registered methods and policy requirement |

**Monitoring tool:** Microsoft Entra ID Sign-in logs + Log Analytics workspace (NorthBridge-SIEM)
**Review cadence:** Daily during report-only, weekly after enforcement
**Escalation threshold:** Greater than 50 report-only failures per day triggers policy review before enforcement

---

## 6. Exception Process

If a user or application cannot satisfy an Authentication Strength policy at enforcement time:

1. Help desk opens exception request in ServiceNow
2. IAM team reviews within 2 business days
3. Approved exceptions are added to a named exclusion group scoped to the specific policy
4. Exception is time-limited — maximum 90 days before mandatory review
5. All exceptions are logged in the NorthBridge Exception Register (see exception-policy.md)
6. Exceptions exceeding 90 days require CISO sign-off

---

*Document owner: IAM Architecture Team — NorthBridge Financial Group*
*Next review: Quarterly or following any policy enforcement incident*
*Related documents: ca-policy-matrix.md | named-locations-trusted-networks.md | exception-policy.md*
