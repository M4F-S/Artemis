# P14 — Active Defense Agent (legally gated)

**User-added pillar.** Designed and architected, but **disabled at runtime** until per-jurisdiction legal clearance is granted by the customer.

## Why this exists, and what it is NOT

The user requested an "attack-back" capability. Real attack-back — accessing attacker systems to retrieve / disrupt — is illegal under the US CFAA, UK CMA, EU NIS2 Art. 6, and equivalents in AU/CA/JP. The proposed US "Active Cyber Defense Certainty Act" has been re-introduced multiple times but has never passed; the EU NIS2 directive permits some active measures but only **inside the defender's own perimeter or with the host's authorisation**. P14 is therefore a **lawful Active Defense Agent**, scoped to actions inside the defender's perimeter or via legitimate third-party channels.

P14 does **not**:
- Scan, probe, or send traffic to attacker-controlled hosts.
- Exploit attacker infrastructure, credentials, or accounts.
- Wipe / modify any system the customer doesn't own.
- Operate without explicit customer admin authorisation.

P14 design includes a hard-coded **outbound-action allowlist** enforced in code, not just in policy. Anything outside the allowlist is unimplementable, not just disabled.

## Capabilities (all inside-perimeter or legitimate-channel)

### A. Adaptive deception escalation (extends P3)
- When an attacker trips a low-tier canary, *more* canaries are placed in the path of their next likely move.
- Decoy identities are spun up dynamically with realistic activity to hold the attacker's attention while containment runs.

### B. Attacker fingerprinting
- Source IP, ASN, TLS fingerprint (JA4), HTTP fingerprint (HASH), tooling tells (Cobalt Strike beacons, Sliver, Mythic).
- Aggregated (DP'd) and contributed to the federated IoC exchange (P6) — opt-in.

### C. Tarpitting
- Inside the customer's perimeter only — slow / null-route attacker connections to keep them engaged while we contain.
- Implemented via WFP / nftables rules on Artemis-managed endpoints.

### D. Containment playbooks
- Process kill, host isolation (network quarantine), driver unload, eBPF detach, browser tab close.
- Identity actions via P10 connectors: revoke session, force MFA, disable account, rotate service-account keys.
- Each playbook is a signed YAML artefact, version-controlled, and runs through a deterministic engine — never produced by the LLM.

### E. Coordinated revocation & rotation
- Mass-revoke OAuth grants matching a compromise pattern.
- Rotate impacted secrets via integrations with HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault.

### F. Legitimate-channel takedowns (outbound, opt-in, gated)
- Programmatic abuse reports to:
  - Cloud providers (AWS abuse, GCP abuse, Azure abuse).
  - CDNs (Cloudflare, Fastly, Akamai).
  - Registrars (via TLD-specific abuse APIs).
  - GitHub, GitLab (for malicious repos).
  - LLM API providers (for keys observed in vibeware) — Anthropic / OpenAI / etc. abuse channels.
- Each report includes evidence packaged from telemetry (P13 evidence bundles).
- Optional integration with takedown vendors (Netcraft, etc.).

### G. Honeytoken-driven attribution (extends P3)
- When a decoy AWS key is used, the resulting CloudTrail event is captured, attributed, and added to the incident timeline.

## Legal-clearance gating

P14 ships **off** by default. Enabling requires:

1. Tenant admin opts in per capability.
2. Per-jurisdiction policy file (US/EU/UK/CA/AU/JP/...) loaded; jurisdictions where the action is unlawful get hard-disabled.
3. A signed "legal acknowledgement" PDF returned by the customer (uploaded to console).
4. A second admin approval for any action category that touches third parties (F).

The control plane refuses to dispatch P14 actions that don't satisfy all four conditions.

## Audit & reversibility

- Every P14 action produces a tamper-evident audit record (signed, hash-chained).
- Reversible actions (process kill, network isolate) are tracked with explicit "rollback" plays.
- Irreversible actions (key rotation, account disable) require human approval and produce a customer-facing change record.

## Adversarial misuse considerations

- **Triggering Artemis as a weapon against innocent third parties:** containment actions are perimeter-internal; outbound takedown reports are evidence-bundled and human-approved.
- **Hijacking a tenant to attack another:** strict tenant isolation; cross-tenant action is unimplementable.
- **Insider abuse:** RBAC + dual-control on P14 actions; audit log immutable; alerts on anomalous Active-Defense usage.

## Coverage

- Reduces MTTR materially when customer chooses to enable.
- Captures attribution data that hardens the rest of the platform.

## Roadmap

- Phase A (concurrent with MVP): playbook engine + capabilities A–E built and shippable, **all locked off**.
- Phase B (post-legal review): selective unlocking per jurisdiction.
- Phase C (long-term): research into deeper deception (active impersonation, decoy networks).
