# Passwordless Support and Recovery Workflow

**NorthBridge Financial Group - Identity & Access Management Program**  
**Document:** SD-002 | **Classification:** Internal | **Version:** 1.1  
**Owner:** Service Desk Lead | **Status:** Target-state operational readiness artifact

---

## Executive Summary

This document defines the target-state operational support model for NorthBridge Financial Group's passwordless authentication modernization initiative. It describes how the help desk, IAM team, endpoint team, and security operations team should support common recovery scenarios during a phased passwordless rollout.

The model covers Temporary Access Pass issuance, Windows Hello for Business registration failures, FIDO2 security key replacement, lost device recovery, account recovery, new device enrollment, escalation, monitoring, audit logging, and user communications.

This is a planning and operational readiness artifact for a fictional enterprise case study. It does not claim that the workflow has been used in production, that pilot results exist, or that screenshots have been collected.

---

## Purpose

Passwordless authentication reduces credential theft risk, but it also changes how users recover access. The purpose of this workflow is to make recovery secure, repeatable, auditable, and supportable before broad Conditional Access enforcement.

| Goal | Operational Outcome |
|---|---|
| Restore user access safely | Recover users through verified, ticket-backed workflows |
| Prevent social engineering | Require identity verification before TAP issuance or method reset |
| Support staged rollout | Give support teams clear steps before pilot and department waves |
| Protect privileged access | Escalate high-risk and administrator recovery requests |
| Maintain auditability | Tie every recovery action to a ticket, operator, log entry, and outcome |

---

## Scope

This support model applies to the target-state NorthBridge passwordless modernization program.

| In Scope | Out of Scope |
|---|---|
| Workforce passwordless recovery workflows | Completed production deployment evidence |
| Help desk and IAM operating model | Real tenant screenshots or pilot metrics |
| Temporary Access Pass recovery process | Physical device procurement proof |
| WHfB, FIDO2, and new device support | Claims that CA policies are enforced in production |
| Sign-in monitoring and escalation paths | Replacement for formal incident response policy |

---

## Support Team Responsibilities

| Team | Primary Responsibilities |
|---|---|
| Tier 1 Help Desk | Intake, triage, ticket creation, user guidance, knowledge base routing |
| Tier 2 Help Desk | Identity verification, TAP issuance, guided registration, FIDO2 disablement, recovery documentation |
| Tier 3 / IAM Team | Authentication method reset, Conditional Access review, exception approval, suspicious recovery investigation |
| Endpoint Team | Intune device state, WHfB policy assignment, compliance troubleshooting, device replacement support |
| Security Operations | Risky sign-in review, suspected compromise investigation, repeated recovery pattern review |
| Service Desk Lead | Staffing, reporting, escalation review, communications, support readiness tracking |

Tier 1 should not issue TAP, reset authentication methods, or remove FIDO2 keys. Those actions require Tier 2 or IAM ownership.

---

## Identity Verification Requirements

Before issuing a TAP, resetting authentication methods, replacing a FIDO2 key, or approving account recovery, the support operator must verify the user's identity.

| Verification Method | Appropriate Use |
|---|---|
| Live video call with employee badge | Remote workforce and business users |
| Callback to phone number already on record | Standard help desk recovery |
| Manager confirmation through a known internal channel | High-risk or unusual request |
| Employee ID plus manager name | Initial triage only; not sufficient alone for high-risk recovery |
| In-person branch or office verification | Branch staff and shared-device users |

Do not approve recovery based only on inbound email, Teams chat, SMS, caller-provided phone number, or pressure from an unverified requester.

---

## Temporary Access Pass Issuance Workflow

Temporary Access Pass is a short-lived bridge credential for onboarding, device replacement, and recovery. It is not a standing authentication method and should not satisfy high-risk application access.

```text
User cannot access registered method
↓
Create or validate support ticket
↓
Verify user identity
↓
Check existing methods and risky sign-in status
↓
Issue short-lived TAP if approved
↓
User registers permanent passwordless method
↓
Confirm successful sign-in
↓
Record recovery outcome and close ticket
```

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Create or validate ServiceNow ticket |
| 2 | Tier 2 | Verify user identity using approved verification methods |
| 3 | Tier 2 | Confirm why TAP is required and whether another method is available |
| 4 | Tier 2 | Check for existing active TAP, repeat requests, and risky sign-ins |
| 5 | Tier 2 | Issue single-use TAP with short lifetime, normally 4 hours or less |
| 6 | Tier 2 | Deliver TAP verbally or through approved secure support channel |
| 7 | User + Tier 2 | Register permanent passwordless method immediately |
| 8 | Tier 2 | Confirm successful sign-in and document outcome |

Escalate to IAM if the requester is privileged, cannot verify identity, has repeated TAP requests, or appears in risky sign-in logs.

---

## Windows Hello for Business Registration Failure Workflow

Use this workflow when a user cannot complete WHfB registration or WHfB does not work after enrollment.

```text
WHfB registration fails
↓
Confirm user and device are in rollout scope
↓
Check Entra ID and Intune device state
↓
Review WHfB policy assignment and compliance
↓
Review sign-in logs and CA result
↓
Issue TAP only if re-registration is required
↓
Retry WHfB provisioning
↓
Document root cause and close ticket
```

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Confirm user is on a supported Windows device and assigned to the rollout group |
| 2 | Tier 1 | Confirm network access and basic sign-in service reachability |
| 3 | Tier 2 | Check whether the device appears in Entra ID and Intune |
| 4 | Endpoint Team | Confirm compliance state, join state, TPM health, and WHfB policy assignment |
| 5 | IAM Team | Review sign-in logs, Conditional Access results, and user risk |
| 6 | Tier 2 | Issue TAP only if the user must re-register methods |
| 7 | User + Tier 2 | Retry WHfB provisioning after policy checks are complete |
| 8 | Tier 2 | Record root cause, remediation path, and final sign-in status |

Common causes include missing Intune policy assignment, device non-compliance, hybrid join issue, TPM issue, incorrect rollout group membership, or Conditional Access condition mismatch.

---

## FIDO2 Security Key Replacement Workflow

Use this workflow for lost, damaged, stolen, expired, or replaced FIDO2 security keys.

```text
User reports FIDO2 issue
↓
Create ticket and verify identity
↓
Check authentication methods in Entra ID
↓
Disable affected FIDO2 key
↓
Issue TAP only if needed
↓
Assign replacement key
↓
Register replacement key
↓
Confirm sign-in and update inventory
```

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Create ticket and capture reason: lost, damaged, stolen, expired, or replacement |
| 2 | Tier 2 | Verify user identity |
| 3 | Tier 2 | Review user's authentication methods in Entra ID |
| 4 | Tier 2 | Disable or delete affected FIDO2 key |
| 5 | Security Operations | Review sign-in logs if theft or compromise is suspected |
| 6 | Tier 2 | Issue TAP only if needed for re-registration |
| 7 | IT Asset / Endpoint Team | Assign replacement key and update inventory |
| 8 | User + Tier 2 | Register replacement FIDO2 key |
| 9 | Tier 2 | Confirm successful sign-in and close ticket |

Privileged users, executives, administrators, and shared-device users require IAM review before ticket closure.

---

## Lost Device Recovery Workflow

Use this workflow when a user loses a corporate laptop, mobile device, or device used for passwordless authentication.

```text
Lost Device
↓
Identity Verification
↓
Open incident or service request
↓
Lock, wipe, or retire device if managed
↓
Review registered authentication methods
↓
Issue Temporary Access Pass if approved
↓
Register new device or method
↓
Revoke old authentication method
↓
Close ticket with audit notes
```

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Create ticket and mark category as Identity & Access - Lost Device |
| 2 | Tier 1 | Confirm whether the device is corporate-managed or personal |
| 3 | Tier 2 | Complete identity verification |
| 4 | Endpoint Team | Locate device in Intune and initiate lock, wipe, retire, or lost-mode action where appropriate |
| 5 | IAM Team | Review registered authentication methods and sign-in logs |
| 6 | Tier 2 | Disable affected device-bound methods if loss creates access risk |
| 7 | Tier 2 | Issue TAP only if needed for recovery |
| 8 | User + Tier 2 | Register replacement method or new device |
| 9 | Tier 2 | Confirm sign-in, document recovery path, and close ticket |

Escalate to Security Operations if sensitive data exposure, post-loss sign-in activity, or suspected theft is identified.

---

## Account Recovery Workflow

Use this workflow when a user cannot access any registered passwordless method and standard self-service recovery fails.

```text
User locked out of all methods
↓
Open recovery ticket
↓
Verify identity using two approved methods
↓
Review sign-in logs, user risk, and registered methods
↓
IAM approves or denies recovery
↓
Reset methods only if approved
↓
Issue TAP if required
↓
Register permanent method
↓
Confirm access and close ticket
```

| Step | Owner | Action |
|---|---|---|
| 1 | Tier 1 | Open recovery ticket and capture business impact |
| 2 | Tier 2 | Verify identity using two approved methods |
| 3 | Tier 2 | Review registered authentication methods |
| 4 | IAM Team | Review sign-in logs, risky user status, and Conditional Access results |
| 5 | IAM Team | Approve or deny authentication method reset |
| 6 | Tier 2 | Issue TAP only after IAM approval |
| 7 | User + Tier 2 | Register permanent passwordless method immediately |
| 8 | IAM Team | Confirm risk state is cleared or documented |
| 9 | Tier 2 | Close ticket with recovery outcome and escalation notes |

Do not reset methods if compromise is suspected until Security Operations completes initial review.

---

## New Device Enrollment Workflow

Use this workflow when a user receives a replacement laptop, moves to a new managed device, or needs passwordless registration on a newly enrolled endpoint.

```text
New device assigned
↓
Confirm device ownership and Intune enrollment
↓
Confirm user is in passwordless rollout group
↓
Issue TAP if first sign-in or recovery is required
↓
Complete WHfB provisioning
↓
Register FIDO2 or Authenticator backup method
↓
Validate sign-in to Microsoft 365
↓
Close enrollment ticket
```

| Step | Owner | Action |
|---|---|---|
| 1 | Endpoint Team | Confirm device is enrolled in Intune and assigned to the user |
| 2 | Tier 1 | Confirm user is in the appropriate rollout group |
| 3 | Tier 2 | Verify identity before issuing any recovery credential |
| 4 | Tier 2 | Issue TAP only if needed for first sign-in or method registration |
| 5 | User + Tier 2 | Complete WHfB provisioning |
| 6 | User + Tier 2 | Register backup method such as FIDO2 or Authenticator passwordless |
| 7 | IAM Team | Review sign-in logs if registration or Conditional Access errors occur |
| 8 | Tier 2 | Confirm Microsoft 365 sign-in and close ticket |

---

## Help Desk Escalation Matrix

| Scenario | Escalate To | Response Target |
|---|---|---|
| User cannot verify identity | IAM Team + Service Desk Lead | Immediate |
| Privileged user requests TAP or method reset | IAM Team | Same business hour |
| Lost FIDO2 key for admin or executive | IAM Team + Security Operations | Same business hour |
| Risky sign-in detected during recovery | Security Operations | Immediate |
| More than three TAP requests in seven days | IAM Team | Same business day |
| WHfB failure affects multiple users | Endpoint Team + IAM Team | Same business day |
| Conditional Access blocks valid pilot users | IAM Team | Same business hour during pilot |
| Suspected social engineering | Security Operations | Immediate |
| New device cannot enroll in Intune | Endpoint Team | Same business day |

---

## Tier 1 / Tier 2 / Tier 3 Responsibilities

| Activity | Tier 1 | Tier 2 | Tier 3 / IAM |
|---|---|---|---|
| Create ticket and classify request | Yes | Yes | Yes |
| Provide setup guidance | Yes | Yes | Yes |
| Verify identity for recovery | No | Yes | Yes |
| Issue TAP | No | Yes | Yes |
| Disable FIDO2 key | No | Yes | Yes |
| Reset authentication methods | No | No | Yes |
| Approve Conditional Access exception | No | No | Yes |
| Review risky sign-in context | No | Escalate | Yes |
| Investigate suspected compromise | No | Escalate | IAM + Security Operations |

---

## Security Controls

| Control | Requirement |
|---|---|
| Identity verification | Required before TAP, method reset, or key replacement |
| TAP lifetime | Short-lived, normally 4 hours or less |
| TAP usage | Single-use preferred |
| TAP delivery | Verbal or approved secure support channel only |
| Privileged recovery | IAM approval required |
| Lost device | Managed device lock, wipe, or retire considered |
| FIDO2 loss | Key disabled in Entra ID before replacement closes |
| Break-glass accounts | Excluded from standard workflows and handled by emergency access procedure |
| Documentation | Every recovery action tied to a ticket |

---

## Audit Logging Requirements

Every passwordless recovery event should be traceable from initial report to final restoration.

| Log Item | Required Detail |
|---|---|
| Ticket number | ServiceNow incident or request ID |
| Request type | TAP, WHfB failure, FIDO2 replacement, lost device, account recovery, new device enrollment |
| User verification | Verification method used, not sensitive proof values |
| Operator identity | Support or IAM operator who performed the action |
| Method changed | TAP issued, FIDO2 disabled, WHfB reprovisioned, method reset, new method registered |
| TAP metadata | Issuer, target user, lifetime, single-use setting, ticket link |
| Device action | Lock, wipe, retire, replacement, or no action required |
| Sign-in review | Whether risky sign-ins or CA failures were checked |
| Final outcome | Restored, escalated, denied, pending, or transferred |

Never store actual TAP values, FIDO2 PINs, WHfB PINs, passwords, or recovery secrets in support tickets.

---

## Sign-In Monitoring Requirements

| Signal | Review Purpose |
|---|---|
| Entra ID sign-in logs | Confirm authentication method used and identify failed sign-ins |
| Conditional Access results | Determine whether report-only or enforced policy affected the user |
| Authentication Methods activity | Confirm method registration, removal, and changes |
| Risky sign-ins | Identify suspicious access during recovery |
| Risky users | Confirm whether recovery should pause for security review |
| TAP activity | Detect repeated TAP issuance, unusual issuer activity, or excessive recovery volume |
| Help desk tickets | Track recurring failure patterns and support load |

During pilot and rollout waves, support leadership should review recovery volume, repeated TAP requests, and CA-related tickets daily.

---

## Incident Response Considerations

Escalate recovery activity into incident response when:

- A user reports a lost device and sign-ins continue after the report.
- A user denies requesting recovery or TAP issuance.
- Multiple recovery requests originate from the same department, branch, or location.
- A privileged account requires method reset.
- A user appears in risky sign-in or risky user reports.
- Support staff suspect social engineering or caller impersonation.

Security Operations should determine whether to disable the account, revoke sessions, force password reset where still applicable, or open a security incident.

---

## User Communication Process

| Communication | Timing | Owner |
|---|---|---|
| Recovery acknowledgement | After ticket creation | Tier 1 |
| Verification instructions | Before recovery action | Tier 2 |
| TAP handling instructions | When TAP is issued | Tier 2 |
| Replacement method instructions | During guided registration | Tier 2 |
| Closure confirmation | After successful sign-in | Tier 2 |
| Security warning | If request appears suspicious | Security Operations |

### User Message Template

Subject: Passwordless sign-in recovery request

Hello [User Name],

We received your passwordless sign-in support request under ticket [Ticket Number].

For your security, our support team must verify your identity before changing authentication methods or issuing a Temporary Access Pass. Please do not share passwords, PINs, security key PINs, Temporary Access Pass values, or one-time passcodes in email or chat.

Your assigned support contact will guide you through the recovery steps and confirm when your new sign-in method is working.

If you did not request passwordless sign-in support, contact the Service Desk immediately and do not approve any sign-in prompts.

Thank you,  
NorthBridge Service Desk

---

## Risk Management

| Risk | Mitigation |
|---|---|
| Social engineering during recovery | Identity verification, escalation triggers, and Tier 2 ownership |
| TAP misuse | Short lifetime, single-use preference, ticket requirement, and monitoring |
| Weak recovery path undermines CA | TAP excluded from high-risk app access through Authentication Strength design |
| Lost FIDO2 key remains active | Disable key before ticket closure |
| Lost device remains trusted | Intune lock, wipe, retire, or compliance review |
| Repeated recovery requests | IAM review and Security Operations escalation |
| Help desk overload during rollout | Wave scheduling, knowledge base, staffing plan, and daily ticket review |
| Privileged account recovery risk | IAM approval and security review before method reset |

---

## Business Continuity Considerations

| Area | Continuity Approach |
|---|---|
| Branch operations | Maintain FIDO2 backup process and local escalation path |
| Executives and privileged users | Pre-stage backup method and IAM-reviewed recovery path |
| Help desk surge | Add staffing during pilot launch and department rollout days |
| CA enforcement issue | Return affected policy to report-only or pause next rollout wave |
| Device replacement delay | Use TAP only as temporary bridge to register approved method |
| Emergency access | Maintain break-glass accounts outside standard CA policy scope with separate monitoring |

---

## Recovery Success Criteria

| Criteria | Target |
|---|---|
| Identity verification completed | Required for every recovery action |
| Ticket created | Required before TAP, key replacement, or method reset |
| User restored | User can sign in with permanent passwordless method |
| Weak method avoided | Recovery does not rely on password-only access |
| Logs reviewed | Sign-in and risk context checked where appropriate |
| Sensitive values protected | No TAP value, PIN, or secret stored in ticket |
| Closure notes complete | Final method, action, and outcome documented |

---

## Operational Readiness Checklist

| Readiness Item | Required Before Pilot |
|---|---|
| TAP policy documented | Yes |
| Tier 2 operators trained on TAP issuance | Yes |
| WHfB troubleshooting workflow published | Yes |
| FIDO2 replacement workflow published | Yes |
| Lost device workflow aligned with Intune operations | Yes |
| Account recovery requires IAM approval | Yes |
| Escalation matrix approved | Yes |
| Sign-in log review owner assigned | Yes |
| Help desk ticket categories created | Yes |
| User communication template approved | Yes |
| Daily pilot support review scheduled | Yes |
| Break-glass process documented separately | Yes |

This checklist describes planned readiness gates and is not presented as completed production readiness evidence.

---

## Final Target-State Outcome

The final target-state operating model is a passwordless support process where users can recover access quickly without weakening identity security. Help desk staff have clear workflows, IAM controls high-risk recovery decisions, Endpoint supports device-bound authentication, and Security Operations has defined escalation points for suspicious activity.

At maturity, NorthBridge should have:

- Documented workflows for TAP, WHfB, FIDO2, lost device, account recovery, and new device enrollment
- Clear Tier 1, Tier 2, Tier 3, IAM, Endpoint, and Security Operations ownership
- Ticket-backed audit trails for every recovery action
- Sign-in monitoring tied to support escalation
- User communications that reduce rollout confusion
- Business continuity paths for branch, executive, privileged, and emergency access scenarios

This document describes the intended operating model and should be validated through future pilot execution, support tickets, sign-in log review, and sanitized evidence artifacts.

---

*NorthBridge Financial Group is a fictional organization created for portfolio demonstration purposes. This document is intended for operational planning and hiring-manager review, not as evidence of a completed production support process.*
