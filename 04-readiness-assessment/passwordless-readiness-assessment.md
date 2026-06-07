# Passwordless Readiness Assessment

**NorthBridge Financial Group - Identity & Access Management Program**  
**Document:** PRA-001 | **Classification:** Internal | **Version:** 1.0  
**Owner:** IAM Architecture Team | **Status:** Target-state planning and assessment artifact

---

## Executive Summary

This readiness assessment evaluates NorthBridge Financial Group's preparedness for a Microsoft Entra ID passwordless authentication rollout. It is written for executive leadership, security teams, identity administrators, endpoint teams, and support leaders who need to understand whether the organization is ready to move from password-heavy authentication toward phishing-resistant and passwordless sign-in.

The assessment shows that NorthBridge has a strong business case and a clear target architecture, but it is not ready for immediate enterprise-wide enforcement. The organization should begin with remediation and pilot preparation because current gaps remain in MFA coverage, phishing-resistant method registration, legacy authentication retirement, shared workstation strategy, help desk readiness, and Conditional Access Authentication Strength design.

This document is a planning artifact for a fictional enterprise modernization case study. It does not claim that deployment is complete, pilot results exist, or screenshots have been collected.

---

## Assessment Objectives

| Objective | Assessment Focus |
|---|---|
| Security improvement | Reduce password-only access and weak MFA exposure |
| Phishing resistance | Increase adoption of WHfB, FIDO2, and certificate-based authentication where appropriate |
| User experience improvement | Reduce password resets, lockouts, and repeated authentication friction |
| Operational readiness | Confirm support, recovery, TAP, device, and rollout processes are prepared |
| Zero Trust alignment | Align access decisions to user risk, device trust, authentication strength, and application sensitivity |

---

## Current State Assessment

### User Population

NorthBridge models a large hybrid enterprise with approximately 40,000 workforce users, 1,100+ branch locations, shared branch workstations, corporate Windows devices, mobile workers, privileged administrators, and service/shared accounts that require separate exception handling.

| Population | Readiness Observation |
|---|---|
| Corporate knowledge workers | Good candidate for WHfB and Authenticator passwordless rollout after device validation |
| Branch operations | Highest complexity due to shared workstations and lower MFA coverage |
| IT administrators | Strong candidate for early FIDO2 and phishing-resistant pilot |
| Executives | Require higher-assurance methods and carefully tested recovery paths |
| Contractors and vendors | Require separate scoping and risk-based inclusion plan |
| Service/shared accounts | Must not be treated as normal workforce passwordless users |

### Device Management Maturity

Device readiness is partially mature but not sufficient for broad WHfB enforcement. The current-state assessment records Intune enrollment for a majority of corporate devices, but shared branch workstations and legacy teller terminals require a FIDO2 strategy rather than WHfB.

| Device Area | Current Readiness |
|---|---|
| Corporate laptops | Good WHfB candidate where hybrid join, compliance, and TPM requirements are met |
| Corporate desktops | Viable for WHfB after Intune and policy validation |
| Shared branch workstations | Not a WHfB fit; FIDO2 security keys required |
| Legacy teller terminals | Require remediation or exception plan before enforcement |
| Mobile devices | Authenticator passwordless may support mobile workers, but BYOD policy boundaries must be clear |

### MFA Adoption

Baseline MFA adoption is incomplete. The scenario baseline shows 78% MFA registration across workforce users, leaving a material population without MFA. Passwordless coverage is much lower, with only a small percentage of users having phishing-resistant methods registered.

| Area | Current State |
|---|---|
| Any MFA registration | 78% baseline |
| Password-only accounts | 8,800 workforce users |
| Any phishing-resistant method | 4% baseline |
| Branch MFA coverage | Lower than corporate and IT populations |
| Executive MFA coverage | Complete MFA, but not fully phishing-resistant |

### Authentication Methods

NorthBridge currently relies heavily on passwords, push MFA, SMS, and legacy sign-in patterns. These methods do not satisfy the intended target state for high-risk applications or privileged administration.

| Method | Current Concern |
|---|---|
| Password-only | Not acceptable for target-state workforce access |
| SMS OTP | Weak method; should be removed from target Authentication Strength policies |
| Push MFA | Better than password-only, but not phishing-resistant by itself |
| WHfB | Low adoption; requires device and policy readiness |
| FIDO2 | Low adoption; essential for shared devices and privileged users |
| TAP | Must be configured as onboarding/recovery only |

### Conditional Access Maturity

Conditional Access maturity is not sufficient for immediate enforcement. The scenario baseline includes no Authentication Strength policies and no fully implemented legacy authentication block.

| CA Area | Assessment |
|---|---|
| Require MFA policies | Present but too broad and not phishing-resistant |
| Authentication Strength | Must be designed and validated before enforcement |
| Legacy authentication block | Required before broad passwordless confidence |
| Report-only validation | Required for every rollout phase |
| Break-glass exclusions | Must be validated before any enforcement |
| Sign-in risk policies | Should be integrated into rollout monitoring |

### Legacy Authentication Dependencies

Legacy authentication remains a high-risk blocker. The current-state scenario includes POP, IMAP, SMTP AUTH, legacy Exchange/basic authentication patterns, and unsupported applications that can bypass modern MFA.

### Administrative Account Protections

Administrative accounts should be moved first to phishing-resistant methods, but not through abrupt enforcement. Privileged access should be piloted with FIDO2, WHfB where appropriate, sign-in log review, break-glass validation, and explicit CA exclusions for emergency access accounts.

---

## Target State Assessment

| Target Capability | Target Design |
|---|---|
| Windows Hello for Business | Primary sign-in for assigned corporate Windows devices using cloud Kerberos trust |
| FIDO2 Security Keys | Primary method for shared workstations, privileged users, branch users, and high-assurance scenarios |
| Temporary Access Pass | Short-lived onboarding and recovery method only, tied to support ticket and monitoring |
| Authentication Strength Policies | Named policies for phishing-resistant and passwordless access instead of generic MFA |
| Passwordless-first sign-in experience | Users sign in with device-bound or hardware-bound methods, with passwords removed from normal access paths |

The target state should be enforced only after report-only validation, pilot readiness, support readiness, and exception handling are complete.

---

## Readiness Categories

| Category | Score | Comments |
|---|---:|---|
| Identity Readiness | 3/5 | Hybrid identity foundation exists, but sync errors, service/shared account handling, and privileged method coverage need remediation. |
| Device Readiness | 3/5 | Corporate Windows devices can support WHfB, but shared branch workstations and legacy devices require FIDO2 and exception planning. |
| MFA Readiness | 3/5 | MFA baseline exists for most users, but password-only users and weak MFA methods remain. |
| Conditional Access Readiness | 2/5 | CA exists, but Authentication Strength and legacy auth controls are not ready for broad enforcement. |
| User Readiness | 2/5 | Corporate groups are likely easier to prepare; branch users, contractors, and shared-device users need targeted communications and support. |
| Help Desk Readiness | 3/5 | Support workflows are documented as target-state artifacts, but pilot validation and ticket evidence are still pending. |
| Security Operations Readiness | 3/5 | Sign-in log and risky sign-in review requirements are defined, but operational validation is still needed. |

### Readiness Interpretation

NorthBridge is ready for Phase 0 remediation and Phase 1 pilot preparation. It is not ready for enterprise-wide enforcement. The most important blockers are legacy authentication, low phishing-resistant registration, shared-device complexity, and incomplete operational validation.

---

## Legacy Authentication Analysis

| Legacy Dependency | Risk | Mitigation |
|---|---|---|
| POP | Bypasses modern authentication and MFA controls | Identify users/apps, migrate to modern Outlook or approved mail access, then block |
| IMAP | Allows password-based access from legacy clients | Disable per mailbox or tenant after dependency review |
| SMTP AUTH | Commonly used by older applications and scanners | Replace with Graph API, authenticated relay design, or scoped exceptions |
| Legacy Office clients | May fail modern auth or CA controls | Upgrade Office clients and remove unsupported versions from production use |
| Unsupported applications | May rely on basic auth, NTLM, or password-only flows | Assign application owner, document remediation path, and time-limit exceptions |

Legacy authentication is a high-priority risk because it can allow password-based access even when modern MFA policies appear strong. NorthBridge should not claim passwordless readiness until legacy auth volume is understood, reduced, and blocked where safe.

---

## Risk Assessment

| Risk Area | Risk Level | Explanation | Mitigation |
|---|---|---|---|
| User adoption | Medium | Users may resist new sign-in methods or delay registration | Pilot champions, communications, training, and registration reminders |
| Device replacement | Medium | Users may lose access when receiving new devices or replacing phones | New device enrollment workflow, TAP recovery, and help desk readiness |
| Lost credentials / lost keys | Medium | FIDO2 key loss or phone replacement can create lockout risk | FIDO2 replacement workflow, backup methods, TAP controls |
| Application compatibility | High | Legacy apps and protocols may fail under passwordless/CA enforcement | Report-only validation, app owner sign-off, exception register |
| Support desk workload | High | Rollout waves can increase TAP, WHfB, FIDO2, and lockout tickets | Wave scheduling, Tier 2 staffing, knowledge base, daily ticket review |

---

## Readiness Gaps

| Gap | Impact |
|---|---|
| Low phishing-resistant registration baseline | Prevents immediate Authentication Strength enforcement |
| Password-only users remain | Creates unacceptable risk for target-state access |
| Legacy authentication still active | Can bypass MFA and passwordless controls |
| Shared workstation strategy not validated | Branch rollout depends on FIDO2 availability and support process |
| Azure AD Kerberos prerequisite not completed in scenario baseline | WHfB cloud Kerberos trust depends on this prerequisite |
| Help desk workflow not yet validated with real pilot tickets | Support readiness is designed but not proven |
| No retained pilot screenshots or sign-in log evidence | Repository cannot claim execution proof yet |
| Exception handling model still pending | Break-glass, service account, and legacy app exceptions require governance |

---

## Recommendations

### Short-Term: 0-30 Days

| Recommendation | Outcome |
|---|---|
| Remediate identity sync errors | Clean user/device baseline before enrollment |
| Inventory legacy authentication | Identify POP, IMAP, SMTP AUTH, and unsupported app dependencies |
| Define Authentication Strength policies | Separate phishing-resistant, passwordless, and transitional MFA controls |
| Configure TAP policy design | Prepare secure onboarding and recovery process |
| Validate break-glass accounts | Prevent tenant lockout before report-only testing |
| Select pilot groups | Start with IT, IAM, endpoint, and help desk users |

### Medium-Term: 30-90 Days

| Recommendation | Outcome |
|---|---|
| Run CA policies in report-only mode | Identify users/apps that would fail enforcement |
| Pilot WHfB with IT and corporate users | Validate device-bound sign-in and support path |
| Pilot FIDO2 for administrators and shared-device users | Validate high-assurance and branch-friendly method |
| Train Tier 1 and Tier 2 support teams | Reduce rollout friction and unsafe recovery decisions |
| Build exception register | Track legacy apps, service accounts, and temporary exclusions |
| Review sign-in logs daily during pilot | Detect CA failures, risky sign-ins, and method gaps |

### Long-Term: 90+ Days

| Recommendation | Outcome |
|---|---|
| Expand department rollout waves | Move from pilot to controlled adoption |
| Retire legacy authentication | Remove password-based bypass paths |
| Enforce Authentication Strength | Apply phishing-resistant and passwordless controls after readiness gates |
| Reduce password reset dependency | Lower help desk ticket volume |
| Add sanitized evidence artifacts | Strengthen portfolio proof with reports, screenshots, and sign-in log summaries |
| Review exception register quarterly | Prevent temporary exceptions from becoming permanent risk |

---

## Success Metrics

| Metric | Target |
|---|---|
| Passwordless adoption | 95%+ of in-scope workforce users after rollout |
| MFA registration | 100% of in-scope workforce users |
| Legacy auth retirement | 0 approved recurring legacy authentication events after remediation |
| Help desk ticket reduction | 70-80% reduction in password reset and lockout tickets over time |
| Authentication success rate | 98%+ successful sign-in rate for enrolled users after stabilization |
| Phishing-resistant admin coverage | 100% of privileged users using approved phishing-resistant methods |
| TAP governance | 100% of TAP issuance tied to ticket, operator, lifetime, and outcome |
| Exception review | 100% of exceptions owner-approved and time-limited |

These are target metrics for future validation, not completed pilot or production results.

---

## Executive Recommendation

NorthBridge should proceed with Phase 0 remediation and a controlled Phase 1 IT pilot, but should not proceed with broad enterprise enforcement yet.

The recommended decision is: **Conditionally ready for pilot, not ready for enterprise-wide enforcement.**

Leadership should approve the pilot only after identity sync issues, break-glass validation, TAP policy design, pilot group selection, help desk readiness, and report-only Conditional Access monitoring are in place. Enterprise enforcement should wait until legacy authentication dependencies are remediated, shared workstation FIDO2 workflow is validated, and support teams demonstrate readiness during pilot waves.

---

## Final Outcome

A successful NorthBridge passwordless environment would provide a passwordless-first sign-in experience for workforce users, phishing-resistant access for administrators and high-risk applications, FIDO2 support for shared workstation scenarios, controlled TAP recovery, and Conditional Access policies based on Authentication Strength rather than generic MFA.

At maturity, the organization should have:

- Reduced password-only access paths
- Retired legacy authentication protocols
- Broad WHfB adoption on assigned Windows devices
- FIDO2 coverage for shared-device and privileged scenarios
- Auditable TAP recovery workflows
- Help desk procedures validated through pilot activity
- Sign-in monitoring tied to security operations
- Time-limited exception governance

This final outcome should be proven later through sanitized screenshots, sign-in log summaries, generated readiness outputs, support ticket examples, and pilot validation evidence.

---

*NorthBridge Financial Group is a fictional organization created for portfolio demonstration purposes. This readiness assessment is intended for executive planning, architecture review, and hiring-manager evaluation, not as evidence of a completed production deployment.*
