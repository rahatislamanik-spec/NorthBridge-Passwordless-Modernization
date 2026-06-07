# Passwordless Support Workflow

**NorthBridge Financial Group - Identity & Access Management Program**  
**Document:** SD-002 | **Classification:** Internal | **Version:** 1.0  
**Owner:** Service Desk Lead | **Status:** Target-state operational support model

---

## Executive Summary

This document defines the target-state support and recovery workflow for NorthBridge Financial Group's passwordless authentication modernization program. It explains how the help desk, IAM team, endpoint team, and security operations team should respond to common passwordless support scenarios such as lost devices, failed Windows Hello for Business registration, FIDO2 security key replacement, Temporary Access Pass issuance, and account recovery.

This is a planning artifact for a fictional enterprise rollout. It does not claim that these workflows have been used in production or validated against live support tickets.

---

## Purpose

The purpose of this workflow is to keep passwordless authentication secure and supportable during pilot and rollout phases. Passwordless rollout can fail operationally if recovery paths are unclear, so this document defines repeatable steps for restoring user access without weakening identity controls.

| Goal | Support Outcome |
|---|---|
| Restore access safely | Recover users through verified, logged workflows |
| Protect against social engineering | Require identity verification before TAP issuance or method reset |
| Preserve auditability | Tie recovery actions to tickets, logs, and operator identity |
| Reduce downtime | Give help desk clear decision paths and escalation triggers |
| Support phased rollout | Keep pilot and department waves from overwhelming support teams |

---

## Help Desk Responsibilities

| Team | Responsibility |
|---|---|
| Tier 1 Help Desk | Triage, user guidance, knowledge base routing, ticket creation |
| Tier 2 Help Desk | Identity verification, TAP issuance, FIDO2 disablement, guided re-registration |
| IAM Team | Authentication method reset, Conditional Access exceptions, suspicious recovery review |
| Endpoint Team | WHfB device policy, Intune compliance, device enrollment, hardware issues |
| Security Operations | Suspicious sign-in investigation, repeated recovery requests, potential account compromise |
| Service Desk Lead | Support readiness, reporting, escalation review, communication coordination |

Tier 1 should not issue TAP, reset authentication methods, or disable FIDO2 keys. Those actions require Tier 2 or IAM ownership.

---

## Lost Device Workflow

Use this workflow when a user loses a corporate laptop, mobile device, or device used for passwordless authentication.

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Create support ticket and mark category as Identity & Access - Lost Device |
| 2 | Tier 1 | Verify whether the device is corporate-managed or personal |
| 3 | Tier 2 | Perform identity verification before discussing recovery options |
| 4 | Endpoint Team | Locate device record in Intune and initiate wipe, retire, or lock action where appropriate |
| 5 | IAM Team | Review user's registered authentication methods in Entra ID |
| 6 | Tier 2 | Disable affected device-bound methods where loss creates access risk |
| 7 | Tier 2 | Issue TAP only after verification and only if the user needs recovery access |
| 8 | User + Tier 2 | Register replacement method through `aka.ms/mysecurityinfo` |
| 9 | Tier 2 | Confirm successful sign-in and close ticket with recovery notes |

Escalate to Security Operations if the device may contain sensitive data, if sign-in activity appears after reported loss, or if the user cannot verify identity.

---

## Failed Windows Hello for Business Registration Workflow

Use this workflow when a user cannot complete WHfB registration or cannot use WHfB after enrollment.

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Confirm user is on a supported Windows device and assigned to the correct rollout group |
| 2 | Tier 1 | Confirm the user has network access and can reach Microsoft sign-in services |
| 3 | Tier 2 | Check whether the device appears in Entra ID and Intune |
| 4 | Endpoint Team | Confirm Intune compliance state, WHfB policy assignment, and device join state |
| 5 | IAM Team | Review sign-in logs for CA failures, authentication method errors, or risk blocks |
| 6 | Tier 2 | Issue TAP if the user needs to re-register methods |
| 7 | User + Tier 2 | Retry WHfB provisioning after device and policy checks are complete |
| 8 | Tier 2 | Document root cause and whether user was restored through TAP, FIDO2, or Authenticator passwordless |

Common causes include missing Intune policy assignment, non-compliant device state, hybrid join issue, TPM problem, user not included in rollout group, or Conditional Access report-only failure that needs IAM review.

---

## FIDO2 Security Key Replacement Workflow

Use this workflow for lost, damaged, expired, or replaced FIDO2 security keys.

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Create ticket and capture reason: lost, damaged, replacement, or suspected theft |
| 2 | Tier 2 | Verify user identity using approved verification steps |
| 3 | Tier 2 | Check user's authentication methods in Entra ID |
| 4 | Tier 2 | Disable or delete the affected FIDO2 key from the user's authentication methods |
| 5 | Security Operations | Review sign-in logs if key theft or compromise is suspected |
| 6 | Tier 2 | Issue TAP only if needed for re-registration |
| 7 | IT Asset / Endpoint Team | Assign replacement key and update inventory record |
| 8 | User + Tier 2 | Register replacement FIDO2 key |
| 9 | Tier 2 | Confirm the user can sign in and close ticket with key replacement notes |

If the lost key belongs to an administrator, privileged role holder, executive, or branch shared-device user, escalate to IAM before closing the ticket.

---

## Temporary Access Pass Issuance Workflow

Temporary Access Pass is a short-lived recovery and onboarding credential. It is not a normal sign-in method and should not be used to bypass high-risk access controls.

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Create or validate existing ServiceNow ticket |
| 2 | Tier 2 | Verify user identity using approved verification steps |
| 3 | Tier 2 | Confirm why TAP is required and whether another registered method is available |
| 4 | Tier 2 | Check for existing active TAP and repeated recovery requests |
| 5 | Tier 2 | Issue single-use TAP with short lifetime, normally 4 hours or less |
| 6 | Tier 2 | Deliver TAP verbally or through approved secure support channel |
| 7 | User + Tier 2 | User registers permanent passwordless method |
| 8 | Tier 2 | Confirm method registration and successful sign-in |
| 9 | Tier 2 | Record TAP details in ticket without writing the passcode itself |

Escalate to IAM if the user has more than three TAP requests in seven days, cannot verify identity, is a privileged user, or shows risky sign-in activity.

---

## Account Recovery Workflow

Use this workflow when a user cannot access any registered passwordless method and standard self-service recovery fails.

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Open recovery ticket and collect impact statement |
| 2 | Tier 2 | Verify identity using two approved factors |
| 3 | Tier 2 | Review available authentication methods in Entra ID |
| 4 | IAM Team | Review sign-in logs, risky user status, and Conditional Access result |
| 5 | IAM Team | Reset authentication methods only if recovery is approved |
| 6 | Tier 2 | Issue TAP if authorized by IAM recovery decision |
| 7 | User + Tier 2 | Register new permanent method immediately |
| 8 | IAM Team | Confirm risky user state is clear or documented |
| 9 | Tier 2 | Close ticket with recovery path, method registered, and escalation notes |

Do not reset authentication methods if compromise is suspected until Security Operations completes the initial review.

---

## Escalation Matrix

| Scenario | Escalate To | Response Target |
|---|---|---|
| User cannot verify identity | IAM Team + Service Desk Lead | Immediate |
| Privileged user requests TAP or method reset | IAM Team | Same business hour |
| Lost FIDO2 key for admin or executive | IAM Team + Security Operations | Same business hour |
| Risky sign-in detected during recovery | Security Operations | Immediate |
| More than three TAP requests in seven days | IAM Team | Same business day |
| WHfB issue affects multiple users | Endpoint Team + IAM Team | Same business day |
| Conditional Access blocks valid pilot users | IAM Team | Same business hour during pilot |
| Suspected social engineering | Security Operations | Immediate |

---

## Security Verification Steps

Before TAP issuance, FIDO2 replacement, method reset, or account recovery, the support operator must verify the user's identity.

Approved verification options:

| Verification Method | Use Case |
|---|---|
| Live video call with employee badge | Remote workforce recovery |
| Manager confirmation through known internal channel | High-risk or unusual request |
| Employee ID plus manager name | Standard help desk triage |
| Callback to phone number already on record | Phone-based support |
| In-person branch or office verification | Branch and shared-device users |

Do not approve recovery based only on an inbound email, Teams chat, SMS message, or caller-provided phone number.

---

## Risk Controls

| Risk | Control |
|---|---|
| Social engineering during recovery | Identity verification, Tier 2 ownership, and escalation triggers |
| TAP misuse | Short lifetime, single-use preference, ticket requirement, and log review |
| Lost FIDO2 key used after report | Immediate key disablement in Entra ID |
| Device loss exposes access | Intune lock, wipe, retire, and sign-in log review |
| Repeated recovery requests | IAM review after repeated TAP or method reset activity |
| Privileged account compromise | IAM and Security Operations review before recovery |
| Help desk overreach | Clear separation between Tier 1, Tier 2, IAM, Endpoint, and Security Operations |

---

## Audit Logging Requirements

Every passwordless recovery event should be traceable from user report to final restoration.

| Log Item | Required Detail |
|---|---|
| Ticket number | ServiceNow incident or request ID |
| Request type | Lost device, WHfB failure, FIDO2 replacement, TAP, account recovery |
| User identity verification | Verification method used, not sensitive proof values |
| Operator identity | Help desk or IAM operator who performed the action |
| Authentication method changed | FIDO2 disabled, TAP issued, WHfB reset, Authenticator registered |
| TAP metadata | Issuer, target user, lifetime, single-use setting, ticket link |
| Sign-in log review | Whether risky sign-ins or CA failures were checked |
| Final outcome | Restored, escalated, denied, or pending |

Never store the actual TAP value, FIDO2 PIN, password, or recovery secret in the ticket.

---

## Communication Template for Affected User

Subject: Passwordless sign-in recovery request

Hello [User Name],

We received your passwordless sign-in support request under ticket [Ticket Number].

For your security, our support team must verify your identity before changing authentication methods or issuing a Temporary Access Pass. Please do not share passwords, PINs, security key PINs, or one-time passcodes in email or chat.

Your assigned support contact will guide you through the recovery steps and confirm when your new sign-in method is working.

If you did not request passwordless sign-in support, contact the Service Desk immediately and do not approve any sign-in prompts.

Thank you,  
NorthBridge Service Desk

---

## Final Operational Outcome

The intended operating model is a support process where passwordless recovery is fast, verifiable, auditable, and resistant to social engineering. Help desk staff can restore access without weakening Conditional Access policy intent, IAM retains control over high-risk recovery decisions, and Security Operations has clear escalation points for suspicious activity.

At maturity, NorthBridge should have:

- Documented recovery workflows for lost devices, WHfB failures, FIDO2 key replacement, TAP issuance, and account recovery
- Clear ownership between Tier 1, Tier 2, IAM, Endpoint, and Security Operations
- Ticket-backed audit logs for every recovery event
- User communications that reduce confusion during rollout waves
- Escalation triggers for privileged users, repeated recovery requests, risky sign-ins, and suspected social engineering

This support model describes the target-state operating approach and should be validated through future pilot execution, support tickets, and sanitized evidence artifacts.

---

*NorthBridge Financial Group is a fictional organization created for portfolio demonstration purposes. This document is intended for operational planning and hiring-manager review, not as evidence of a completed production support process.*
