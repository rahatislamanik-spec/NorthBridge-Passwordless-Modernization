# Help Desk Procedures — Passwordless Authentication Support

**NorthBridge Financial Group — Identity & Access Management Program**
**Document:** SD-001 | **Classification:** Internal | **Version:** 1.0
**Owner:** Service Desk Lead | **IAM Review:** Quarterly

---

## Overview

This document is the operational reference for NorthBridge help desk staff supporting the Passwordless Authentication Modernization program. It covers the four most common support scenarios: TAP issuance, WHfB reset, FIDO2 key replacement, and Authenticator re-registration.

**Tier 1** handles initial triage and user guidance only.
**Tier 2** handles TAP issuance, key disablement, and escalations.
**IAM Team** handles policy exceptions, account-level issues, and anything not covered here.

---

## 1. Authorization Matrix

| Action | Tier 1 | Tier 2 | IAM Team |
|---|---|---|---|
| Guide user through WHfB setup | Yes | Yes | Yes |
| Guide user through Authenticator registration | Yes | Yes | Yes |
| Issue Temporary Access Pass | No | Yes | Yes |
| Disable lost FIDO2 key in Entra ID | No | Yes | Yes |
| Reset user authentication methods | No | No | Yes |
| Approve policy exceptions | No | No | Yes |
| Disable user account | No | No | Yes |

---

## 2. TAP Issuance Procedure

Use when a user cannot sign in and has no registered passwordless method available.

**Step 1 — Verify identity**
- Confirm user identity using two factors: employee ID + manager name, or video call with badge visible
- Do NOT issue TAP based on email request alone
- Do NOT issue TAP to someone who cannot verify their identity

**Step 2 — Open ServiceNow ticket**
- Category: Identity & Access — Passwordless Support
- Note the ticket number — format must be INC followed by 7 digits (example: INC0042891)
- TAP cannot be issued without a valid ticket number

**Step 3 — Run issuance script**
- Open PowerShell as Tier 2 operator
- Run: `.\New-TAPForUser.ps1 -UserPrincipalName "upn@northbridge.ca" -TicketNumber "INC0042891"`
- Script will block issuance if user already has an active TAP

**Step 4 — Deliver TAP securely**
- Read TAP verbally over phone or Teams call only
- Never send TAP via email, SMS, or Teams chat in plaintext
- Inform user the TAP is single-use and expires in 4 hours

**Step 5 — Guide user through registration**
- Direct user to: `aka.ms/mysecurityinfo`
- User signs in with their UPN and the TAP
- User registers their permanent passwordless method during this session
- Confirm registration is complete before ending the call

**Step 6 — Close ticket**
- Confirm method registered successfully
- Note which method was registered in the ticket
- Close ticket with resolution: TAP issued, passwordless method registered

---

## 3. Windows Hello for Business — Common Issues

| Symptom | Likely Cause | Resolution |
|---|---|---|
| WHfB PIN prompt not appearing | Device not hybrid joined or WHfB policy not applied | Verify device in Intune — check WHfB enrollment policy |
| "This option is not available" at sign-in | WHfB not provisioned on this device | User must complete WHfB setup — issue TAP if needed |
| PIN forgotten | User locked out of WHfB | Issue TAP — user re-provisions WHfB at mysecurityinfo |
| Biometric not working | Hardware or driver issue | User can switch to PIN — escalate hardware issue separately |
| WHfB works locally but fails cloud apps | Azure AD Kerberos issue | Escalate to IAM team — do not attempt to resolve at Tier 2 |

---

## 4. FIDO2 Security Key — Lost or Damaged Key

**Lost key procedure:**

| Step | Action | Time Target |
|---|---|---|
| 1 | User reports lost key to help desk | Immediate |
| 2 | Tier 2 disables key in Entra ID — Protection > Authentication Methods | Within 1 hour |
| 3 | Open ServiceNow ticket — note key serial if known | Immediate |
| 4 | Issue TAP for temporary access | Same call |
| 5 | Procurement requests replacement YubiKey | Within 24 hours |
| 6 | IT registers new key for user at next available session | Within 48 hours |

**Disabling a FIDO2 key in Entra ID:**
1. Sign in to Entra ID portal
2. Navigate to Users > select user > Authentication Methods
3. Locate the FIDO2 Security Key entry
4. Click the three dots > Delete
5. Confirm deletion — key is immediately invalidated

**Branch staff — backup key:**
All branch staff have a backup key stored in the branch safe. Before issuing a TAP, check whether the user can retrieve their backup key first.

---

## 5. Microsoft Authenticator Passwordless — Re-registration

Use when a user has a new phone or has deleted the Authenticator app.

| Step | Action |
|---|---|
| 1 | Verify user identity — same process as TAP issuance |
| 2 | Issue TAP via New-TAPForUser.ps1 |
| 3 | User installs Microsoft Authenticator on new device |
| 4 | User signs in at aka.ms/mysecurityinfo using TAP |
| 5 | User adds Authenticator — select "Add sign-in method > Authenticator app" |
| 6 | User enables passwordless phone sign-in within the app |
| 7 | Confirm registration visible in mysecurityinfo before ending call |

**Important:** The old Authenticator registration is NOT automatically removed when a user gets a new phone. Tier 2 must remove the old registration from Entra ID Authentication Methods after the new device is registered.

---

## 6. Escalation to IAM Team

Escalate immediately if any of the following occur:

| Scenario | Escalation Path |
|---|---|
| User claims they never registered any method but sign-in logs show activity | IAM team — possible account compromise |
| TAP issuance script fails with permission error | IAM team — operator permission issue |
| User locked out of all methods including TAP | IAM team — account-level recovery |
| Suspicious TAP request — caller cannot verify identity | IAM team + Security Operations — do not issue TAP |
| User reports their FIDO2 key is missing but someone else may have it | IAM team + Security Operations — disable immediately |
| More than 3 TAP requests for the same user in 7 days | IAM team — flag for review |

---

## 7. Quick Reference Card

Print and post at help desk workstations.

| Scenario | Tool | Who |
|---|---|---|
| User needs TAP | New-TAPForUser.ps1 | Tier 2 |
| Check user auth methods | Entra ID > Users > Auth Methods | Tier 2 |
| Disable lost FIDO2 key | Entra ID > Users > Auth Methods > Delete | Tier 2 |
| User registration page | aka.ms/mysecurityinfo | Share with user |
| Check sign-in logs | Entra ID > Sign-in logs | Tier 2 |
| Audit TAP issuance log | TAP_AuditLog_[date].csv on shared drive | Tier 2 |
| Escalate to IAM | iam-team@northbridge.ca / Teams: IAM Operations | Tier 2 |

---

*Document owner: Service Desk Lead — NorthBridge Financial Group*
*IAM review contact: iam-team@northbridge.ca*
*Related documents: tap-issuance-workflow.md | recovery-scenarios.md | exception-policy.md*
