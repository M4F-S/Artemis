# P10 — Identity Fusion (ITDR)

**Gap closed:** Tier 3 #11. 79% of 2024 detections were malware-free; 65% of initial access was identity-driven. Mainstream EDR is endpoint-centric and ITDR is identity-centric — the two are usually siloed. Artemis fuses them.

## Identity sources

- Microsoft Entra ID (Azure AD) — sign-in logs, conditional access decisions, OAuth grants.
- Okta — system log, threat insights, factor enrolments.
- Google Workspace — login challenges, OAuth tokens, Drive sharing events.
- On-prem AD — Domain Controller events via LDAP/SAMR plus a lightweight collector.
- Local OS identity — Linux PAM, Windows Security Channel, macOS opendirectoryd.

All ingested via P10's connector layer; pseudonymised at rest (P6).

## Fused signals

| Signal | Combines | Detection example |
|---|---|---|
| Token replay | endpoint (cookie source) + identity (token use) | Same refresh token used from two ASN-disjoint hosts within 5m → CRITICAL |
| OAuth grant abuse | identity (new grant) + endpoint (which process triggered it) | Newly-installed extension granted "send mail as you" → HIGH, surface to user |
| Impossible travel + unfamiliar device | identity (geo, fingerprint) + endpoint (first-seen heartbeat) | Login from Lagos 5m after laptop heartbeat from Berlin → CRITICAL |
| Adversary-in-the-middle phish | identity (MFA prompt) + endpoint (browser navigation chain) | MFA approve from a low-rep host while browser shows phishing toolkit URL → CRITICAL |
| Service-account drift | identity (new IP/UA for SA) + endpoint (which process holds key) | Backup SA suddenly used from a developer laptop → HIGH |
| Privileged-action without elevation | identity (admin role assumed) + endpoint (no JIT request) | Admin role used without expected JIT flow → HIGH |

## Containment hooks

- Revoke session — Entra `revokeSignInSessions`, Okta clear sessions, Google session revoke.
- Force MFA re-enrolment.
- Disable account.
- Rotate keys for service accounts.

All pass through the Active-Defense playbook framework (P14), so they're auditable, reversible, and gated.

## Privacy

- We never collect content of MFA prompts, passwords, or vault contents.
- Per-tenant isolation enforced; no cross-tenant identity leakage even in federated IoC.

## Coverage

- ATT&CK: T1078 (Valid Accounts), T1098 (Account Manipulation), T1539 (Steal Web Session Cookie), T1556 (Modify Authentication Process), T1606 (Forge Web Credentials).
