# Break-Glass and Exception Management Model

**NorthBridge Financial Group - Identity & Access Management Program**  
**Document:** GOV-001 | **Classification:** Internal | **Version:** 1.0  
**Owner:** Identity Governance Lead | **Status:** Target-state governance and operational planning artifact

---

## Executive Summary

Passwordless modernization improves security by reducing password dependency, but an enterprise still needs controlled emergency access, exception handling, and governance for systems that cannot immediately support modern authentication. Without a formal exception model, Conditional Access exclusions, legacy applications, emergency access accounts, and service accounts can become unmanaged bypass paths.

This document defines how NorthBridge Financial Group should govern break-glass accounts, service accounts, legacy application exceptions, Conditional Access exclusions, and quarterly reviews during and after a passwordless modernization program.

This is a target-state governance artifact for a fictional enterprise case study. It does not claim that deployment is complete, screenshots exist, or pilot results have been collected.

---

## Governance Objectives

| Objective | Governance Outcome |
|---|---|
| Business continuity | Ensure critical operations can continue during authentication outages or rollout issues |
| Emergency recovery | Preserve secure administrative recovery paths during tenant lockout or CA misconfiguration |
| Security resilience | Prevent exclusions and legacy dependencies from becoming permanent unmanaged risk |
| Operational stability | Give identity, security, operations, and business teams a clear approval and review process |
| Zero Trust alignment | Keep exceptions explicit, time-limited, monitored, and risk-reviewed |

---

## Emergency Access (Break-Glass) Accounts

Emergency access accounts exist to prevent complete administrative lockout during Conditional Access misconfiguration, identity provider outage, MFA outage, or tenant recovery scenarios.

### Purpose

Break-glass accounts are not daily administrative accounts. They are reserved for emergency tenant recovery when normal privileged access methods are unavailable.

### Recommended Account Model

| Control Area | Recommendation |
|---|---|
| Number of accounts | Maintain two separate cloud-only emergency access accounts |
| Account type | Cloud-only Entra ID accounts, not synchronized from on-premises AD |
| Role assignment | Global Administrator or minimum emergency roles required by recovery design |
| Daily use | Prohibited except during approved emergency testing or recovery |
| Naming | Use a non-obvious naming standard documented in the emergency access procedure |
| Ownership | Joint ownership by IAM leadership and Security Operations |

### Credential Requirements

| Requirement | Target Standard |
|---|---|
| Password strength | Long, unique, randomly generated credentials |
| Password storage | Stored in approved enterprise password vault or physical sealed process |
| MFA design | Protected through a separate emergency access method that does not depend on the same CA path being recovered |
| Rotation | Rotate after every use, after staff change, and during scheduled review |
| Access disclosure | Limited to named emergency access custodians |

### Storage Requirements

Break-glass credentials should be stored in a way that remains available during identity outage scenarios. NorthBridge should avoid storing the only copy in a system that depends on the same tenant access path being recovered.

Recommended storage controls:

- Two-person access process for credential retrieval
- Sealed physical backup or approved offline vault process
- Access log for every retrieval
- Post-use credential rotation
- Security Operations notification on every access

### Monitoring Requirements

| Monitoring Item | Requirement |
|---|---|
| Sign-in alerting | Immediate alert for any successful or failed break-glass sign-in |
| Location review | Alert on unexpected source country, device, or IP pattern |
| Role activity | Review all directory and CA changes made during session |
| Session review | Require post-use incident or change record |
| Credential retrieval | Log who accessed the credential and why |

### Exclusion Requirements

Break-glass accounts should be excluded from standard Conditional Access policies that could cause tenant lockout. They should not be excluded from monitoring, alerting, review, or emergency access governance.

| Policy Area | Treatment |
|---|---|
| Standard workforce CA policies | Excluded |
| Passwordless enforcement policies | Excluded |
| Device compliance requirements | Excluded where required for emergency access |
| Monitoring and alerting | Included |
| Access reviews | Included |
| Emergency access test process | Included |

### Testing Requirements

| Test | Frequency | Owner |
|---|---|---|
| Credential retrieval test | Quarterly | IAM + Security Operations |
| Sign-in validation | Quarterly | IAM |
| Alert validation | Quarterly | Security Operations |
| Role validation | Quarterly | IAM Governance |
| Post-test credential rotation | After each test | IAM |
| Documentation review | Quarterly | Exception Review Board |

Testing should be scheduled, documented, and performed without changing production policy unless a recovery exercise requires it.

---

## Service Account Governance

Service accounts and application identities must be governed separately from workforce passwordless authentication. They should not be placed into broad user exclusions without ownership, risk review, and a retirement path.

| Account Type | Governance Requirement |
|---|---|
| Legacy service accounts | Identify owner, application, credential storage, sign-in pattern, and retirement path |
| Application identities | Prefer modern application registration, certificate-based auth, or workload identity patterns |
| Managed identities | Preferred for Azure-hosted workloads where supported |
| Shared accounts | Eliminate where possible; otherwise document owner, purpose, and exception expiry |
| Privileged service accounts | Require enhanced monitoring, least privilege, and frequent review |

### Ownership Requirements

Every service account must have:

- Business owner
- Technical owner
- Application or workload mapping
- Environment classification
- Privilege level
- Authentication method
- Review date
- Retirement or modernization plan

### Credential Rotation Requirements

| Credential Type | Rotation Expectation |
|---|---|
| Password-based service accounts | Rotate on defined schedule and after owner/team change |
| Certificate credentials | Track expiry and renew before expiration |
| Client secrets | Replace with certificates or managed identities where possible |
| Managed identities | Review assignments and permissions quarterly |

### Review Process

Service accounts should be reviewed at least quarterly. High-privilege service accounts should be reviewed monthly until modernization is complete.

Review questions:

- Is the account still required?
- Does it have an active owner?
- Does it use modern authentication?
- Can it be replaced by managed identity or workload identity?
- Does it have excessive permissions?
- Is it excluded from Conditional Access, and why?

---

## Legacy Application Exception Management

Some applications may not support passwordless, Authentication Strength, or modern authentication during early rollout. These dependencies must be documented, risk accepted, and retired through a migration plan.

| Legacy Dependency | Risk | Governance Requirement |
|---|---|---|
| POP | Password-based protocol that can bypass modern controls | Disable where possible; approve only with short-term exception |
| IMAP | Legacy mail access that may avoid modern CA expectations | Migrate users to modern clients and remove dependency |
| SMTP AUTH | Often used by devices, scanners, and legacy apps | Scope tightly, replace with Graph/API or relay pattern |
| Legacy Office clients | May not satisfy modern auth or CA controls | Upgrade client version or remove from supported estate |
| Unsupported authentication workflows | May depend on password-only or NTLM-style access | Assign app owner, document risk, plan migration |

### Business Justification

Every legacy exception must include:

- Business process supported
- Application owner
- User or system population affected
- Reason modern authentication is not yet supported
- Risk rating
- Expiration date
- Migration owner
- Target retirement date

### Risk Acceptance Process

High-risk exceptions require Security Architecture and business owner approval. Exceptions that allow legacy authentication, password-only access, or broad CA exclusion should require Exception Review Board approval.

### Retirement Strategy

Legacy exceptions should not be indefinite. NorthBridge should use one of the following paths:

- Upgrade application to modern authentication
- Replace unsupported client
- Move workload to managed identity or application registration
- Retire application
- Isolate access behind compensating controls while migration completes

### Migration Planning

Each exception should have a migration plan with technical owner, business owner, timeline, testing plan, rollback plan, and validation criteria.

---

## Conditional Access Exclusion Model

Conditional Access exclusions are sometimes necessary, but they must be narrow, documented, reviewed, and time-bound.

### Exclusion Types

| Exclusion Type | Example | Governance Treatment |
|---|---|---|
| Approved exclusion | Known application dependency with owner and migration path | Time-limited and reviewed quarterly |
| Temporary exclusion | Pilot user blocked due to policy issue | Short duration, reviewed before renewal |
| Emergency exclusion | CA misconfiguration causing business interruption | Incident-linked and removed after recovery |
| Break-glass exclusion | Emergency access accounts excluded from standard CA | Permanent design exception with continuous monitoring |
| Service account exclusion | Non-interactive account that cannot satisfy user CA controls | Owner-reviewed and modernized where possible |

### Approval Workflow

```text
Exception Request
↓
Risk Review
↓
Security Approval
↓
Temporary Exclusion
↓
Quarterly Review
↓
Removal or Renewal
```

### Documentation Requirements

Each CA exclusion must document:

- Requester
- Business owner
- Technical owner
- Policy affected
- Users, groups, apps, or accounts excluded
- Risk rating
- Business justification
- Compensating controls
- Expiration date
- Review decision

---

## Exception Review Board

The Exception Review Board governs exceptions that affect passwordless rollout, Conditional Access enforcement, emergency access, service accounts, and legacy authentication dependencies.

| Role | Responsibility |
|---|---|
| Security team | Risk assessment, compensating control review, incident context |
| Identity team | CA design, Entra ID configuration, access review, technical validation |
| Operations team | Business continuity, support impact, rollout scheduling |
| Business stakeholders | Business justification, impact statement, migration commitment |
| Application owners | Legacy dependency remediation and technical migration plan |

### Board Responsibilities

- Review new exception requests
- Review break-glass account status
- Review legacy authentication dependencies
- Review service account exceptions
- Review expiring exclusions
- Approve renewal, removal, or escalation
- Track exception trends and recurring root causes

---

## Quarterly Validation Process

Quarterly validation prevents exceptions from becoming invisible permanent risk.

| Validation Area | Quarterly Activity |
|---|---|
| Break-glass account testing | Validate credential retrieval, sign-in, alerts, and role assignments |
| Sign-in validation | Confirm emergency accounts and excluded identities show expected monitoring |
| Credential review | Rotate or validate break-glass and high-risk service account credentials |
| Service account review | Confirm owners, privileges, sign-in activity, and modernization plan |
| Exception inventory review | Renew, remove, or escalate all active exceptions |
| Conditional Access review | Validate exclusions, report-only findings, and policy coverage |
| Legacy dependency review | Confirm migration progress and retirement dates |

Every quarterly review should produce a governance summary for IAM leadership and Security Operations.

---

## Audit and Monitoring Requirements

| Monitoring Area | Requirement |
|---|---|
| Sign-in logs | Review break-glass, excluded accounts, service accounts, and legacy protocol activity |
| Alerting | Alert on break-glass sign-ins, unexpected service account sign-ins, and legacy auth spikes |
| Exception tracking | Maintain central exception register with owner, risk, expiry, and review status |
| Governance reporting | Produce quarterly summary of active exceptions, renewals, removals, and overdue items |
| Security review cycles | Review high-risk exceptions monthly and all exceptions quarterly |
| Conditional Access changes | Track policy modifications, exclusions, and emergency changes |
| Service account activity | Monitor unusual sign-in location, interactive sign-in, or privilege changes |

Audit records should not store passwords, TAP values, FIDO2 PINs, or other sensitive secrets.

---

## Risk Assessment

| Risk Area | Risk Level | Explanation | Mitigation |
|---|---|---|---|
| Excessive exclusions | High | Broad or stale exclusions can bypass passwordless and CA controls | Time-limited approvals, quarterly reviews, owner accountability |
| Unmanaged service accounts | High | Unknown owners and static credentials create hidden privilege risk | Inventory, ownership, rotation, managed identity migration |
| Emergency access misuse | Medium | Break-glass accounts are highly privileged and excluded from standard CA | Continuous alerting, sealed access process, quarterly testing |
| Legacy authentication dependencies | High | POP, IMAP, SMTP AUTH, and unsupported clients can bypass modern controls | Inventory, migration plan, retirement dates, exception board approval |

---

## Success Criteria

| Governance Outcome | Success Criteria |
|---|---|
| Break-glass readiness | Two cloud-only emergency accounts validated quarterly with alerting confirmed |
| Exception discipline | 100% of exclusions have owner, justification, expiry, and review status |
| Service account governance | 100% of service accounts have owner, purpose, authentication method, and review date |
| Legacy auth reduction | Legacy auth exceptions decline each quarter until retired or formally risk accepted |
| CA governance | No undocumented Conditional Access exclusions remain active |
| Review cadence | Quarterly Exception Review Board completed and documented |
| Monitoring | Break-glass and high-risk exception sign-ins generate actionable alerts |

These are target governance outcomes and should be validated later through sanitized evidence artifacts.

---

## Final Target-State Outcome

A mature NorthBridge passwordless identity governance model preserves emergency access while preventing exceptions from weakening the modernization program. Break-glass accounts are cloud-only, monitored, tested, and excluded only where required for emergency recovery. Service accounts have owners, rotation schedules, and modernization paths. Legacy applications have documented risk acceptance and retirement plans. Conditional Access exclusions are narrow, time-limited, and reviewed through a formal governance board.

At maturity, NorthBridge should have:

- Tested emergency access accounts with continuous alerting
- Central exception register with ownership and expiry
- Quarterly review board for CA exclusions, service accounts, and legacy dependencies
- Legacy authentication retirement roadmap
- Service account modernization plan
- Security reporting for high-risk exclusions
- Clear separation between emergency access, temporary rollout exceptions, and permanent design exceptions

This final state should be proven later through sanitized access review exports, CA policy screenshots, sign-in alert examples, service account inventory summaries, and quarterly governance review evidence.

---

*NorthBridge Financial Group is a fictional organization created for portfolio demonstration purposes. This document is intended for governance planning and hiring-manager review, not as evidence of a completed production deployment.*
