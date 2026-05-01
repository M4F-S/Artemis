# ADR-0013 — Active Defense severity tiers + NAC connector contract

## Status
Accepted (Phase 0).

## Context

P14 originally listed Active Defense capabilities A–F flat. The owner has asked for **explicit severity tiers** (so an operator and a tenant policy can choose how aggressively Artemis responds) plus a 42-Berlin-specific capability: when a malicious endpoint is confirmed on the school network, neutralise it by blocking the device's network access and report to school administration.

This requires:
1. A formal tier ladder that composes existing capabilities into operational levels.
2. A new capability G: Network Access Control (NAC) connector — controlling the customer's own network gear to deny access to a confirmed-malicious device.
3. A formal "report to authority" capability already implicit in P14 capability F, now elevated to its own tier (Tier 5).

NAC is a destructive-but-reversible primitive (MAC deny / cert revoke / port shutdown all reversible). It must respect the same multi-signal gating as auto-rollback (ADR-0011), with its own rate limits and audit trail.

## Decision

P14 is reorganised around **6 severity tiers**:

| Tier | Name | Default trigger | Action set | Composes |
|---|---|---|---|---|
| 0 | Observe | any alert | log only | — |
| 1 | Warn | severity ≥ MEDIUM | notify operator + (optionally) end user | — |
| 2 | Soft contain | severity ≥ HIGH or honeytoken trip | kill process; revoke session; force MFA | P14 D, partial E |
| 3 | Hard contain | severity ≥ CRITICAL with multi-signal | isolate host (WFP / nftables / NetExt); freeze account | P14 D extended |
| 4 | Network neutralisation | confirmed-malicious + tenant-policy=allowed | NAC: revoke 802.1X cert, deny MAC at switch/AP, deny in firewall ACL | **NEW capability G** |
| 5 | Escalate to authority | confirmed-malicious + scope-policy=allowed | structured incident report to named admin / authority chain | P14 F, redirected internal |

### Tier-progression rules

- Tier 0–1 are always available.
- Tier 2 requires per-tenant opt-in (default ON).
- Tier 3 requires per-tenant opt-in (default ON for HIGH+ severity scenarios).
- Tier 4 requires per-tenant opt-in PER SCOPE (e.g., school WiFi = yes; corporate VPN = yes; guest network = no), AND multi-signal confirmation per ADR-0011.
- Tier 5 requires per-tenant opt-in AND a named authority chain (per-scope), AND multi-signal confirmation.
- Tier 4 and 5 actions emit CRITICAL audit events regardless of outcome.

### NAC connector contract (capability G)

A pluggable connector interface so customers can use their actual network infrastructure:

```rust
#[async_trait]
pub trait NacConnector {
    /// Deny a device from the network. Returns a token that can later
    /// be used to reverse the action.
    async fn deny(&self, device: DeviceIdentity, scope: Scope, reason: DenyReason) 
        -> Result<DenyToken>;

    /// Reverse a previous deny.
    async fn allow(&self, token: DenyToken) -> Result<()>;

    /// Health check: can we reach the NAC backend?
    async fn health(&self) -> Result<NacHealth>;

    /// Connector capabilities (what kinds of denial we can apply).
    fn capabilities(&self) -> NacCapabilities;
}
```

Reference connectors (Phase 5–7):
- `artemis-nac-freeradius` — v0; FreeRADIUS REST module + cert-revoke flow.
- `artemis-nac-pfsense` — pfSense REST API for firewall / DHCP deny.
- `artemis-nac-unifi` — UniFi Controller API for AP MAC deny + wireless deauth.
- `artemis-nac-cisco-ise` — Cisco ISE REST + CoA (RFC 5176) for auth re-evaluation.
- `artemis-nac-aruba-clearpass` — Aruba ClearPass REST.
- `artemis-nac-meraki` — Cisco Meraki Dashboard API.

Customers without a supported vendor can write their own connector against the trait.

### Tier-4 safety contract

Tier 4 actions must:
- Pass the multi-signal gate from ADR-0011.
- Be reversible (the connector returns a `DenyToken` that allows undoing the action).
- Be rate-limited per tenant (default: ≤ 3 devices per 5 minutes; ≤ 10 per hour).
- Notify all tenant admins via at least one channel before taking effect.
- Be cancellable via a 60-second window unless tenant policy = `tier4-no-delay`.
- Be logged with full evidence in the audit chain.

### Tier-5 safety contract

Tier 5 reports must:
- Pseudonymise PII by default; admin chooses re-identification per case.
- Include a structured evidence bundle (provenance subgraph, alert chain, LLM narrative with citations).
- Route to a named authority per tenant scope (e.g., for 42 Berlin: scope `campus-network` → IT admin; scope `student-byod` → IT lead + dean of students).
- Be deliverable via the customer's chosen channel (email DL, ticketing webhook, secure chat).
- Include action history (what tiers fired before reaching tier 5).

## 42 Berlin-specific application

The default 42 configuration:
- Tier 1–3 ON, default thresholds.
- Tier 4 ON for scope `42-network`. NAC connector: FreeRADIUS (assumed; confirmed during onboarding).
- Tier 5 ON for scope `42-network`. Authority: 42 IT lead + (for severe student-BYOD cases) dean of students. Channel: email + 42's chosen ticketing system.
- Pre-authorisation: signed by 42 admin during onboarding; covered in DPIA.

## Adversarial threats addressed

| Threat | Defence |
|---|---|
| Attacker triggers mass Tier-4 NAC denials as DoS | Multi-signal gate + per-tenant rate limit + 60s cancel + admin notification |
| Compromised NAC connector deauths arbitrary devices | Connector instance scoped per tenant; audit log per call; rotation of connector creds |
| False-positive auto-network-block | All Tier 4 actions reversible via stored DenyToken; tombstone retained 30 days |
| Tier-5 report leaks PII inadvertently | Default-pseudonymous; explicit re-identification action audited |
| Tier-5 report sent to wrong chain due to misconfig | Authority chain reviewed during onboarding; sample report sent during dry-run |

## Consequences

- P14 doc is rewritten around tiers (capabilities A–F preserved, mapped to tiers, capability G added).
- Engineering builds a connector framework before any specific vendor integration; reference FreeRADIUS implementation lands in Phase 5.
- Customers must declare their authority chain at onboarding for Tier 5 to be available.
- Marketing must describe the tier ladder accurately and never claim "automatic everything"; tiers 4 and 5 always require per-tenant opt-in plus multi-signal gating.
