# Passwordless Pilot Rollout Plan

**NorthBridge Financial Group - Identity & Access Management Program**  
**Document:** ROL-001 | **Classification:** Internal | **Version:** 1.0  
**Owner:** IAM Architecture Team | **Status:** Target-state planning artifact

---

## Executive Summary

This document defines the proposed pilot and phased rollout plan for NorthBridge Financial Group's passwordless authentication modernization program. It translates the target-state architecture into an operational deployment sequence covering IT pilot users, business power users, department rollout, enterprise deployment, support readiness, risk controls, and monitoring.

This is a planning artifact for a fictional enterprise modernization project. It does not claim that the pilot has been completed, that users have been enrolled, or that production results are available.

---

## Rollout Objectives

| Objective | Target Outcome |
|---|---|
| Reduce password dependency | Move in-scope workforce users toward phishing-resistant and passwordless authentication methods |
| Validate user readiness | Confirm enrollment, sign-in, and recovery workflows before broad enforcement |
| Protect high-risk access | Require phishing-resistant authentication for privileged roles and sensitive applications |
| Preserve business continuity | Use staged deployment, report-only Conditional Access, and recovery paths before enforcement |
| Prepare support teams | Equip help desk and IAM operators with documented procedures for TAP, WHfB, and FIDO2 scenarios |
| Build auditability | Review sign-in logs, authentication method registration, TAP issuance, and exception activity during each phase |

---

## Success Metrics

| Metric | Target Before Enforcement |
|---|---|
| IT pilot passwordless registration | 95% or higher |
| Business power user registration | 90% or higher |
| Department rollout registration | 85% or higher before expanding to enterprise deployment |
| Help desk escalation rate | Less than 2% of enrolled users per rollout wave |
| Critical authentication incidents | 0 unresolved Severity 1 incidents before phase gate approval |
| Legacy authentication | No validated business dependency before blocking |
| TAP usage | Tracked to ticket number, reviewed daily during pilot |
| Sign-in risk events | Reviewed daily during report-only validation |

These metrics are proposed rollout gates. They are not presented as completed pilot results.

---

## Phase 1 - IT Pilot Group

| Area | Plan |
|---|---|
| Cohort | IAM team, endpoint team, help desk Tier 2, security operations, and selected IT administrators |
| Approximate size | 100-150 users |
| Timeline | Weeks 1-4 |
| Primary methods | Windows Hello for Business and FIDO2 security keys |
| Recovery method | Temporary Access Pass issued by Tier 2 or IAM operators |
| Conditional Access posture | Report-only for authentication strength and legacy authentication policies |
| Exit criteria | Registration target met, no critical incidents open, support procedures validated |

**Purpose:** Validate technical prerequisites, support procedures, authentication method registration, sign-in log monitoring, and rollback workflows with users who can provide high-quality operational feedback.

---

## Phase 2 - Business Power Users

| Area | Plan |
|---|---|
| Cohort | Finance, operations, compliance, branch support leads, and executive assistants |
| Approximate size | 500-1,000 users |
| Timeline | Weeks 5-8 |
| Primary methods | Windows Hello for Business, Microsoft Authenticator passwordless, and FIDO2 for shared-device users |
| Recovery method | Temporary Access Pass with ticket validation |
| Conditional Access posture | Continue report-only validation for broad workforce policies |
| Exit criteria | Registration target met, high-risk application access validated, help desk volume within threshold |

**Purpose:** Validate user experience and support model with business-critical users before department-scale rollout.

---

## Phase 3 - Department Rollout

| Area | Plan |
|---|---|
| Cohort | Corporate departments, branch regions, and operations teams in scheduled waves |
| Approximate size | 5,000-10,000 users per wave |
| Timeline | Weeks 9-20 |
| Primary methods | Windows Hello for Business for managed Windows devices, FIDO2 for shared branch devices, Authenticator passwordless for mobile users |
| Recovery method | Temporary Access Pass through approved support process |
| Conditional Access posture | Begin targeted enforcement for validated groups; keep enterprise-wide policies in report-only until wave readiness is confirmed |
| Exit criteria | Department readiness confirmed, exception register reviewed, no unresolved business blockers |

**Purpose:** Scale enrollment while controlling risk through department-by-department gates, communications, and support coverage.

---

## Phase 4 - Enterprise Deployment

| Area | Plan |
|---|---|
| Cohort | Remaining workforce users, approved exceptions, and late adopters |
| Approximate size | Remaining in-scope users after department rollout |
| Timeline | Weeks 21-32 |
| Primary methods | Population-specific passwordless method based on device and role |
| Recovery method | Temporary Access Pass and documented exception workflow |
| Conditional Access posture | Move validated policies from report-only to enforcement in controlled waves |
| Exit criteria | Passwordless coverage target met, exception register approved, legacy authentication blocked where safe |

**Purpose:** Complete the planned enterprise rollout while maintaining clear exception handling and monitoring.

---

## Temporary Access Pass Strategy

Temporary Access Pass is used as a bridge credential for onboarding, device replacement, and recovery. It is not a standing access method and should not satisfy high-risk application access.

| Control | Planned Standard |
|---|---|
| Issuance authority | Tier 2 help desk and IAM operators only |
| Ticket requirement | ServiceNow ticket number required for every TAP |
| Lifetime | 4 hours maximum |
| Use count | Single-use preferred for onboarding and recovery |
| Delivery | Verbal delivery over verified call or approved support channel |
| Monitoring | Daily review of TAP issuance volume and repeat requests |
| High-risk access | Excluded through phishing-resistant Authentication Strength requirements |

---

## FIDO2 Security Key Strategy

FIDO2 security keys are the primary method for shared workstations, branch users without assigned devices, privileged users, and users requiring phishing-resistant access independent of a single Windows profile.

| Area | Planned Approach |
|---|---|
| Hardware standard | YubiKey 5 NFC or equivalent enterprise-approved key |
| Branch users | Primary key issued to user; backup process defined by branch operations |
| Privileged users | Dedicated FIDO2 key required for administrative access |
| Registration | Guided registration for pilot and branch users; self-service where appropriate for corporate users |
| Lost key process | Disable key in Entra ID, open ticket, issue TAP only after identity verification |
| Inventory | Track assignment, replacement, and deactivation through IT asset process |

---

## Windows Hello for Business Strategy

Windows Hello for Business is the primary passwordless method for assigned corporate Windows devices.

| Area | Planned Approach |
|---|---|
| Deployment model | Cloud Kerberos trust for hybrid AD and Entra ID environments |
| Device scope | Managed Windows 10/11 devices with Intune compliance |
| Enrollment | Intune policy-driven provisioning during sign-in or device setup |
| PIN policy | Enterprise PIN requirements aligned to internal security policy |
| Biometrics | Permitted on supported hardware where policy allows |
| Support path | WHfB reset and reprovisioning through help desk documented procedure |

---

## Conditional Access Report-Only Validation

All new Conditional Access policies that affect sign-in behavior should run in report-only mode before enforcement.

| Validation Area | Review Activity |
|---|---|
| Authentication Strength | Identify users who would fail passwordless or phishing-resistant requirements |
| Legacy authentication | Confirm no valid business dependency remains before blocking |
| High-risk applications | Validate privileged and financial application access paths |
| Exclusions | Confirm break-glass, service accounts, and emergency access accounts are handled separately |
| Sign-in risk | Review Identity Protection risk results and false positives |
| Device compliance | Confirm Intune compliance state does not block valid users unexpectedly |

Report-only findings should be reviewed daily during pilot phases and summarized at each phase gate.

---

## Help Desk Readiness

| Readiness Area | Required Before Phase 1 |
|---|---|
| TAP issuance procedure | Documented and tested by Tier 2 |
| WHfB support procedure | Documented for setup, reset, and device replacement |
| FIDO2 lost key procedure | Documented with disablement and replacement steps |
| Escalation path | IAM and Security Operations escalation criteria defined |
| Knowledge base | End-user setup article and support scripts available |
| Staffing | Additional coverage scheduled for rollout wave launch days |
| Ticket categories | Passwordless onboarding, TAP recovery, WHfB reset, FIDO2 replacement |

---

## User Communications

| Communication | Audience | Timing |
|---|---|---|
| Executive announcement | All users | 2-3 weeks before first business wave |
| Pilot invitation | IT pilot users and power users | 1 week before enrollment |
| Setup instructions | Each rollout cohort | 3-5 business days before enrollment |
| Reminder notice | Users not registered | 48 hours before phase gate |
| Support instructions | All enrolled users | Day of enrollment |
| Exception process | Managers and support teams | Before enforcement |

Communication should focus on what users need to do, why the change matters, and where to get help.

---

## Risk Management

| Risk | Mitigation |
|---|---|
| Users blocked before enrollment | Report-only CA validation, registration tracking, and staged enforcement |
| Lost or damaged FIDO2 keys | Documented disablement, replacement, and TAP recovery process |
| Help desk overload | Wave scheduling, pilot feedback, knowledge base, and temporary staffing coverage |
| Legacy application dependency | Legacy auth report-only review and application owner sign-off before blocking |
| Shared workstation complexity | FIDO2-focused branch workflow and local support readiness |
| Social engineering during TAP requests | Identity verification, Tier 2 issuance only, ticket requirement, and TAP log review |
| Break-glass account lockout | Exclude emergency accounts from standard CA policies and protect with separate controls |

---

## Rollback Strategy

Rollback does not mean disabling passwordless methods. It means temporarily reducing enforcement pressure while preserving registered methods and audit data.

| Scenario | Rollback Action |
|---|---|
| CA policy blocks valid users | Return affected policy to report-only or exclude affected pilot group temporarily |
| WHfB provisioning issue | Pause Intune WHfB policy assignment for affected device group |
| FIDO2 registration issue | Pause rollout wave and continue with existing MFA until registration issue is resolved |
| TAP support issue | Restrict issuance to IAM operators until help desk process is corrected |
| High-risk application access issue | Keep phishing-resistant requirement in report-only while app owner validates access path |

Rollback actions require IAM owner approval, change record notes, and post-incident review before resuming rollout.

---

## Monitoring and Sign-In Log Review

| Log Source | Review Focus |
|---|---|
| Entra ID sign-in logs | Failed sign-ins, report-only CA results, authentication method used |
| Authentication Methods activity | New registrations, method changes, FIDO2 key registration events |
| Identity Protection | Risky users and risky sign-ins during rollout |
| Conditional Access insights | Users who would be blocked by planned enforcement |
| TAP issuance records | Issuer, target user, ticket number, lifetime, and repeat usage |
| Help desk tickets | Volume, category, escalation rate, and repeated user issues |

During Phase 1 and Phase 2, monitoring should be reviewed daily. During department and enterprise waves, monitoring should be reviewed daily for the first week of each wave and then at agreed rollout checkpoints.

---

## Final Target-State Outcome

The planned target state is a workforce authentication model where passwords are no longer the default access path for in-scope users. Corporate Windows users sign in with Windows Hello for Business, shared-device and privileged users use FIDO2 security keys, mobile users use passwordless methods where appropriate, and high-risk applications require phishing-resistant Authentication Strength through Conditional Access.

At completion, NorthBridge should have:

- Documented passwordless method coverage by user population
- Validated Conditional Access enforcement gates
- Reduced password reset and account lockout dependency
- A monitored TAP recovery process
- A reviewed exception register
- Help desk procedures for common recovery scenarios
- Sign-in log evidence supporting safe policy enforcement

These outcomes describe the intended target state and should be validated through future lab or tenant execution evidence.

---

*NorthBridge Financial Group is a fictional organization created for portfolio demonstration purposes. This rollout plan is intended for architectural planning and hiring-manager review, not as evidence of a completed production deployment.*
