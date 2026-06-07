# Passwordless Authentication Strength Policy

**NorthBridge Financial Group - Identity & Access Management Program**  
**Document:** CA-002 | **Classification:** Internal | **Version:** 1.0  
**Owner:** IAM Architecture Team | **Status:** Target-state planning artifact

---

## Executive Summary

This document defines the target-state Conditional Access and Authentication Strength design for NorthBridge Financial Group's passwordless modernization program. It explains how Microsoft Entra ID Conditional Access should be used to move workforce users from password-based access toward phishing-resistant and passwordless authentication methods.

This is a planning artifact for a fictional enterprise modernization case study. It does not claim that the policy has been deployed, that screenshots exist, or that production enforcement results are available.

---

## Policy Objective

The objective is to require stronger authentication methods for workforce and high-risk access while preserving operational continuity through staged rollout, report-only validation, help desk recovery workflows, and documented exceptions.

| Objective | Target Design |
|---|---|
| Reduce password dependency | Require passwordless or phishing-resistant methods for in-scope users |
| Protect privileged access | Require phishing-resistant Authentication Strength for administrative roles |
| Protect sensitive applications | Apply stronger authentication to financial, cloud, and administrative workloads |
| Avoid rollout disruption | Use report-only mode, pilot groups, and staged enforcement before broad enablement |
| Preserve recovery paths | Use Temporary Access Pass for onboarding and recovery only |
| Support auditability | Monitor sign-in logs, method registration, risky sign-ins, and help desk escalations |

---

## Business Problem

NorthBridge's current-state scenario includes password-spray exposure, high password reset ticket volume, mixed MFA coverage, and inconsistent authentication strength across applications. Generic MFA requirements may still allow weaker methods such as SMS, voice calls, or push approval that do not meet phishing-resistant expectations for high-risk access.

Authentication Strength policies solve this by explicitly defining which authentication methods satisfy access requirements. This makes Conditional Access decisions more precise, easier to audit, and better aligned to Zero Trust and financial-sector risk expectations.

---

## Target Users and Groups

| Population | Policy Treatment |
|---|---|
| IT administrators | Require phishing-resistant Authentication Strength |
| Privileged role holders | Require phishing-resistant Authentication Strength for all cloud apps |
| Corporate knowledge workers | Require passwordless Authentication Strength after rollout gate approval |
| Branch users with assigned devices | Prefer Windows Hello for Business with FIDO2 fallback |
| Shared branch workstation users | Require FIDO2 security keys where WHfB is not appropriate |
| Remote and mobile workers | Allow passwordless Authenticator where risk and device posture permit |
| Executives and sensitive roles | Require phishing-resistant method, with FIDO2 or certificate-based authentication where appropriate |
| Break-glass accounts | Excluded from standard CA policies and protected by separate emergency access controls |

---

## Included Cloud Apps

| App Scope | Planned Treatment |
|---|---|
| Microsoft 365 apps | Passwordless requirement for workforce users after staged rollout |
| Microsoft Entra admin center | Phishing-resistant requirement for privileged users |
| Azure portal | Phishing-resistant requirement for administrators and cloud operators |
| Exchange admin center | Phishing-resistant requirement for Exchange administrators |
| Intune admin center | Phishing-resistant requirement for endpoint administrators |
| Core banking and treasury applications | Phishing-resistant requirement for all users with access |
| Enterprise SSO applications | Passwordless or phishing-resistant requirement based on application risk |

Application targeting should be validated in report-only mode before enforcement.

---

## Exclusions

Exclusions must be narrow, documented, and reviewed. They are not a way to bypass security requirements permanently.

| Exclusion | Reason | Control |
|---|---|---|
| Break-glass accounts | Prevent total tenant lockout during emergency access scenarios | Separate monitoring, strong offline credential handling, and periodic access review |
| Emergency access accounts | Preserve administrative recovery path | Excluded from standard CA policies but monitored through alerting |
| Service accounts | Non-interactive or application-bound authentication | Migrate to managed identities or workload identities where possible |
| Legacy exception group | Temporary business continuity for users or apps not ready for enforcement | Time-limited, owner-approved, reviewed at least every 30-90 days |

Every exclusion should have an owner, expiry date, business justification, and remediation plan.

---

## Authentication Strength Design

### Phishing-Resistant Methods

The highest-risk access paths should require methods that resist credential replay and common phishing attacks.

| Method | Use Case | Notes |
|---|---|---|
| Windows Hello for Business | Managed Windows devices assigned to one user | Device-bound credential using PIN or biometric unlock |
| FIDO2 security keys | Privileged users, shared workstations, branch users, and recovery-resistant access | Hardware-bound credential with PIN or biometric verification |
| Certificate-based authentication | Executive, high-privilege, or smart-card-compatible scenarios | Appropriate where certificate lifecycle and device controls are mature |

### Passwordless Workforce Methods

| Method | Use Case | Notes |
|---|---|---|
| Windows Hello for Business | Primary method for corporate Windows users | Preferred for assigned Intune-managed devices |
| FIDO2 security keys | Shared devices and phishing-resistant access | Preferred where WHfB is not operationally suitable |
| Microsoft Authenticator passwordless | Mobile and remote worker scenarios | Acceptable for standard workforce apps where policy allows |

### Temporary Access Pass

Temporary Access Pass is used only as a bridge credential for onboarding, device replacement, and account recovery. It should not be treated as a standing authentication method and should not satisfy high-risk application access.

| TAP Control | Planned Requirement |
|---|---|
| Issuance authority | Tier 2 help desk or IAM operators only |
| Lifetime | Short-lived, normally 4 hours or less |
| Use count | Single-use preferred |
| Ticketing | Service desk ticket required for every issuance |
| Monitoring | TAP issuance reviewed during pilot and rollout waves |
| High-risk apps | Excluded by requiring phishing-resistant Authentication Strength |

---

## Blocked or Discouraged Methods

| Method | Treatment | Rationale |
|---|---|---|
| SMS OTP | Block or exclude from Authentication Strength policies | Susceptible to SIM swap and interception |
| Voice call MFA | Block or exclude | Weak user verification and social engineering risk |
| Password-only sign-in | Not accepted for in-scope cloud access | Does not satisfy MFA or Zero Trust expectations |
| Legacy authentication | Block after report-only validation | Bypasses modern MFA and Conditional Access controls |
| Push MFA alone | Discouraged for high-risk access | Not phishing-resistant unless replaced by passwordless or stronger methods |

---

## Conditional Access Rollout Mode

Conditional Access enforcement should move through controlled gates instead of immediate tenant-wide blocking.

| Stage | Mode | Purpose |
|---|---|---|
| Design validation | Disabled or scoped testing | Confirm policy logic, exclusions, and target groups |
| Report-only first | Report-only | Identify users, devices, and apps that would fail enforcement |
| Pilot group | Report-only then enforced for IT pilot | Validate method registration and support workflows |
| Business pilot | Staged enforcement | Confirm user experience and application compatibility |
| Department rollout | Wave-based enforcement | Expand by department or branch group |
| Enterprise rollout | Broad enforcement | Apply once readiness, exceptions, and monitoring gates are met |

### Rollback Plan

| Scenario | Rollback Action |
|---|---|
| Valid users unexpectedly blocked | Return affected policy to report-only or temporarily exclude pilot group |
| Application incompatibility found | Exclude app from enforcement while owner remediates dependency |
| Help desk overload | Pause next rollout wave and extend report-only period |
| FIDO2 or WHfB registration issue | Pause enforcement for affected cohort until registration path is corrected |
| Emergency access concern | Validate break-glass accounts and stop policy expansion until recovery path is confirmed |

Rollback actions should be documented through change records and reviewed before rollout resumes.

---

## Monitoring Requirements

| Monitoring Area | Review Requirement |
|---|---|
| Sign-in logs | Review failed sign-ins, Conditional Access results, and authentication method used |
| Report-only results | Identify users who would be blocked before enforcement |
| Authentication method registration | Track WHfB, FIDO2, Authenticator passwordless, and TAP use |
| Risky sign-ins | Review Identity Protection sign-in risk during rollout |
| Risky users | Escalate high-risk users to IAM and security operations |
| Help desk escalations | Track ticket volume, common failures, TAP requests, and repeated lockouts |
| Legacy authentication | Confirm legitimate dependency reaches zero before blocking |

Monitoring should be daily during pilot and early rollout waves, then weekly after stable enforcement.

---

## Risk Controls

| Risk | Control |
|---|---|
| Tenant-wide lockout | Break-glass exclusions, staged rollout, and report-only validation |
| Weak MFA accepted for sensitive apps | Authentication Strength requiring phishing-resistant methods |
| Social engineering during recovery | Tier 2 TAP issuance, identity verification, and ticket requirement |
| Long-term exception drift | Expiring exception group membership with owner review |
| Shared workstation complexity | FIDO2-first strategy for shared branch scenarios |
| Lost security keys | Disable lost key in Entra ID and issue TAP only after identity verification |
| Poor adoption | User communications, pilot champions, help desk readiness, and registration tracking |
| Legacy protocol bypass | Conditional Access block for legacy authentication after validation |

---

## Success Criteria

| Criteria | Target Before Broad Enforcement |
|---|---|
| IT pilot registration | 95% or higher |
| Business pilot registration | 90% or higher |
| Report-only failure rate | Low enough for IAM owner approval before enforcement |
| Help desk escalation rate | Less than 2% of enrolled users in each wave |
| Legacy authentication dependency | No approved business dependency remaining before block |
| Break-glass validation | Emergency access accounts tested outside standard CA policies |
| Exception register | All exceptions owner-approved, time-limited, and reviewed |
| Sign-in log review | Daily review completed during pilot windows |

These are proposed readiness gates and are not claimed as achieved production results.

---

## Production Readiness Checklist

| Readiness Item | Status Target |
|---|---|
| Authentication Strength policies defined | Required before pilot |
| Conditional Access policies scoped to pilot groups | Required before report-only validation |
| Break-glass accounts excluded and monitored | Required before any enforcement |
| Service accounts reviewed and excluded appropriately | Required before enforcement |
| Legacy exception group created with owner review | Required before pilot |
| TAP policy configured and documented | Required before pilot |
| FIDO2 registration process tested | Required before business rollout |
| WHfB policy validated on managed Windows devices | Required before business rollout |
| Help desk procedures published | Required before pilot |
| User communication templates prepared | Required before each rollout wave |
| Sign-in log review process assigned | Required before report-only mode |
| Rollback procedure approved | Required before enforcement |

---

## Final Target-State Outcome

The intended target state is a Conditional Access model where high-risk and privileged access requires phishing-resistant authentication, standard workforce access uses approved passwordless methods, weak methods are removed from access paths, and recovery is handled through monitored Temporary Access Pass workflows.

At maturity, NorthBridge should have:

- Named Authentication Strength policies for phishing-resistant and passwordless access
- Staged Conditional Access enforcement with validated exclusions
- Reduced reliance on passwords, SMS, voice call, and legacy authentication
- Documented TAP, FIDO2, and WHfB operational support procedures
- Sign-in log and Identity Protection monitoring during rollout
- A time-limited exception process with owner accountability

This outcome describes the target design and should be validated through future tenant execution evidence, screenshots, sign-in log review, and pilot results.

---

*NorthBridge Financial Group is a fictional organization created for portfolio demonstration purposes. This document is intended for architecture planning and hiring-manager review, not as evidence of a completed production deployment.*
