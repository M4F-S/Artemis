# P14 — Active Defense Agent (tiered, legally gated)

**Owner-added pillar.** Designed and architected; capabilities A–E ship in code, locked off, until per-jurisdiction legal clearance ([ADR-0009](../09-adr/0009-active-defense-policy.md)) is granted by the customer. Capability G (NAC) and the full tier ladder are added per [ADR-0013](../09-adr/0013-active-defense-tiers.md).

## Why this exists, and what it is NOT

Real "hack-back" — accessing attacker systems to retrieve / disrupt — is illegal under the US CFAA, UK CMA, EU NIS2 Art. 6, and equivalents in AU/CA/JP. P14 is a **lawful Active Defense Agent**, scoped to actions inside the defender's perimeter or via legitimate third-party channels.

P14 does **not**:
- Scan, probe, or send traffic to attacker-controlled hosts.
- Exploit attacker infrastructure, credentials, or accounts.
- Wipe / modify any system the customer doesn't own.
- Operate without explicit customer admin authorisation.

P14 design includes a hard-coded **outbound-action allowlist** enforced in code, not just in policy. Anything outside the allowlist is unimplementable, not just disabled.

## Severity ladder (Tier 0–5)

P14 actions compose into a six-tier ladder. A tenant configures which tiers are enabled per scope (per device group, per network, per time-of-day).

| Tier | Name | Default trigger | Action | Reversible? |
|---|---|---|---|---|
| **0** | Observe | any alert | log only | n/a |
| **1** | Warn | severity ≥ MEDIUM | notify operator + (optionally) end user | n/a |
| **2** | Soft contain | severity ≥ HIGH or honeytoken trip | kill process; revoke session; force MFA | yes |
| **3** | Hard contain | severity ≥ CRITICAL with multi-signal | isolate host (WFP / nftables / NetExt); freeze account | yes |
| **4** | Network neutralisation | confirmed-malicious + tenant-policy=allowed | NAC: revoke 802.1X cert, deny MAC at switch/AP, deny in firewall ACL | yes |
| **5** | Escalate to authority | confirmed-malicious + scope-policy=allowed | structured incident report to named admin / authority chain | n/a |

Higher tiers compose lower-tier actions: Tier 4 implies Tier 3, which implies Tier 2, etc.

Tier-progression rules:
- **Tier 0–1 always available.**
- **Tier 2** — per-tenant opt-in, default ON.
- **Tier 3** — per-tenant opt-in, default ON for HIGH+.
- **Tier 4** — per-tenant opt-in PER SCOPE + multi-signal gate ([ADR-0011](../09-adr/0011-self-healing-rollback.md)).
- **Tier 5** — per-tenant opt-in + named authority chain + multi-signal gate.

Tiers 4 and 5 **require** a 60-second cancel window and a CRITICAL audit event (per [ADR-0013](../09-adr/0013-active-defense-tiers.md)).

## Capabilities (mapped onto the ladder)

### A. Adaptive deception escalation (extends P3) — Tier 0–2

When an attacker trips a low-tier canary, *more* canaries are placed in the path of their next likely move. Decoy identities are spun up dynamically with realistic activity to hold the attacker's attention while containment runs.

### B. Attacker fingerprinting — Tier 0

Source IP, ASN, TLS fingerprint (JA4), HTTP fingerprint (HASH), tooling tells (Cobalt Strike beacons, Sliver, Mythic). Aggregated (DP'd) and contributed to the federated IoC exchange (P6) — opt-in.

### C. Tarpitting — Tier 1–3

Inside the customer's perimeter only — slow / null-route attacker connections to keep them engaged while we contain. Implemented via WFP / nftables rules on Artemis-managed endpoints.

### D. Containment playbooks — Tier 2–3

Process kill, host isolation (network quarantine), driver unload, eBPF detach, browser tab close. Each playbook is a signed YAML artefact, version-controlled, and runs through a deterministic engine — never produced by the LLM.

### E. Coordinated revocation & rotation — Tier 2–3

Mass-revoke OAuth grants matching a compromise pattern. Identity actions via P10 connectors: revoke session, force MFA, disable account. Rotate impacted secrets via integrations with HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault.

### F. Legitimate-channel takedowns (outbound, opt-in, gated) — Tier 5

Programmatic abuse reports to:
- Cloud providers (AWS abuse, GCP abuse, Azure abuse).
- CDNs (Cloudflare, Fastly, Akamai).
- Registrars (via TLD-specific abuse APIs).
- GitHub, GitLab (for malicious repos).
- LLM API providers (for keys observed in vibeware) — Anthropic / OpenAI / etc. abuse channels.
- Optional integration with takedown vendors (Netcraft, etc.).

Each report includes evidence packaged from telemetry (P13 evidence bundles).

### G. NAC integration (NEW) — Tier 4

Network Access Control connector framework: control the customer's own network gear to deny access to a confirmed-malicious device. Reference connectors (Phase 5–7):

- `artemis-nac-freeradius` (v0) — FreeRADIUS REST + cert-revoke.
- `artemis-nac-pfsense` — pfSense REST API.
- `artemis-nac-unifi` — UniFi Controller API + wireless deauth.
- `artemis-nac-cisco-ise` — Cisco ISE REST + CoA (RFC 5176).
- `artemis-nac-aruba-clearpass` — Aruba ClearPass REST.
- `artemis-nac-meraki` — Meraki Dashboard API.

Each connector implements the `NacConnector` trait ([ADR-0013](../09-adr/0013-active-defense-tiers.md)) and returns a reversible `DenyToken`.

### H. Honeytoken-driven attribution (extends P3) — Tier 0–4

When a decoy AWS key is used, the resulting CloudTrail event is captured, attributed, and added to the incident timeline. May trigger Tier 4 if the originating device is on a managed network.

## Legal-clearance gating

P14 ships **off** by default. Enabling requires:

1. Tenant admin opts in per capability and per tier.
2. Per-jurisdiction policy file (US/EU/UK/CA/AU/JP/...) loaded; jurisdictions where the action is unlawful get hard-disabled.
3. Customer uploads a signed legal acknowledgement (Artemis-supplied template + their counsel's review).
4. Dual-control: a second admin must approve any third-party-touching action (Tier 5 capability F).

The control plane refuses to dispatch P14 actions that don't satisfy all four conditions.

## Audit & reversibility

- Every P14 action produces a tamper-evident audit record (signed, hash-chained).
- Reversible actions (process kill, network isolate, NAC deny) are tracked with explicit "rollback" plays.
- Irreversible actions (key rotation, account disable, Tier 5 reports) require human approval and produce a customer-facing change record.
- Tier-4 NAC denies retain a 30-day tombstone enabling partial undo if triggered in error.

## Adversarial misuse considerations

- **Triggering Artemis as a weapon against innocent third parties:** Tier 4 actions are perimeter-internal (the customer's own NAC gear); Tier 5 outbound takedown reports are evidence-bundled and human-approved.
- **Hijacking a tenant to attack another:** strict tenant isolation; cross-tenant action is unimplementable.
- **Insider abuse:** RBAC + dual-control on Tier 4–5; audit log immutable; alerts on anomalous Active-Defense usage.
- **Tier-4 abuse as DoS:** rate-limited per tenant; multi-signal gate; 60-second cancel; admin notification.
- **Tier-5 abuse as harassment:** authority chain explicit per scope; structured templates; redaction by default.

## Coverage

- Reduces MTTR materially when customer chooses to enable.
- Captures attribution data that hardens the rest of the platform.
- Tier 4–5 specifically address scenarios like 42 Berlin: a confirmed-malicious endpoint is removed from the school network and reported to administration in a single audited action.

## Roadmap

- **Phase 5**: Tier 0–3 + capabilities A–E built and shippable, all locked off; Tier 4 NAC connector framework + FreeRADIUS reference; Tier 5 report-generation pipeline.
- **Phase 6**: Selective unlocking per jurisdiction (post-legal-review); UniFi + pfSense connectors; first 42-Berlin Tier-4 dry-run.
- **Phase 7**: Cisco ISE + Aruba ClearPass + Meraki connectors; capability F (third-party takedowns) post-legal-review.
