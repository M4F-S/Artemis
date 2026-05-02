# ADR-0016 — Update-channel security

## Status
Accepted (Phase 0).

## Context

Self-update is the most-attacked path for security software (SolarWinds 2020 is the canonical case). The Artemis spec promises double-signed updates (P12) and references signing keys (now ADR-0015), but no single doc treats the update channel as a security surface in its own right. This ADR fills that gap.

The update channel covers:
- Agent binaries (per-OS installer + delta updates).
- Knowledge bundles (rules, models, playbooks, deception/intent templates, BAS scenarios, NAC configs).
- Control-plane service images.

## Decision

### Two-party update consent

- **Control plane** issues an update directive (signed manifest).
- **Agent watchdog** independently verifies the manifest before applying.
- Update applies only when both parties verify.
- The watchdog is a small, separately-signed binary that lives alongside the agent and never updates itself in the same operation as the agent.

### TUF (The Update Framework)

- Update metadata uses TUF: separate roles for `root`, `targets`, `snapshot`, `timestamp`.
- Root role rotated per ADR-0015; threshold-signed.
- Timestamp role short-TTL (24 h); freshness guarantees against rollback to old vulnerable versions.
- Snapshot role binds the consistent set of targets the agent should apply.

### Sigstore-style transparency

- Every update artefact (binary, knowledge bundle) signed via `artemis-signer` (ADR-0015) and recorded in the public Rekor-style transparency log.
- Agent verifies log inclusion before applying.
- Customers can verify the same independently.

### Per-tenant pinning + canary promotion

Phased rollout per release:
1. **Internal canary** — 5% of Artemis-staff endpoints, 24 hours.
2. **Design-partner canary** — opt-in design partners, 48 hours.
3. **Beta channel** — opt-in tenants, 7 days.
4. **Stable** — all tenants on stable channel.

Auto-pause rollout if telemetry shows:
- Agent crash rate > 0.1% above baseline.
- Heartbeat drop > 0.5% above baseline.
- Detection regressions on canary BAS scenarios.

Tenants can pin a version and explicitly opt out of automatic promotion.

### Atomic apply + verified rollback

- A/B partition model on Linux + macOS (atomic switch on next start).
- VSS-snapshot-based rollback on Windows.
- Watchdog verifies the new agent starts and emits a heartbeat within 60 seconds of activation. If not, watchdog rolls back to previous version automatically.
- Rollback is itself a signed action, recorded in the audit log.

### Knowledge-bundle delivery

- Bundles fetched via `KnowledgeService.GetCurrentManifest` + `KnowledgeService.DownloadBundle` (per `samples/control_plane.proto`).
- Bundle content signed (ML-DSA + Ed25519 hybrid per P12).
- Bundle apply is atomic per kind: a partial apply can never leave the agent in an inconsistent state.
- Tenant pin (`knowledge_pins` table) overrides automatic promotion.

### Threat-model coverage

| Threat | Defence |
|---|---|
| Attacker steals signing key | Threshold signing (ADR-0015) + transparency log |
| Attacker compromises CI runner | Runner cannot sign alone (ADR-0015) |
| Attacker compromises control-plane and pushes malicious manifest | Watchdog independent verification + TUF freshness |
| Attacker MITMs the download | mTLS + manifest hash verification + transparency log |
| Attacker rolls a tenant back to a known-vulnerable version | TUF rollback protection (timestamp + snapshot freshness) |
| Update breaks a tenant's fleet | Phased rollout + auto-pause + watchdog rollback |
| Insider pushes unauthorised release | 2-of-3 quorum (ADR-0015) + transparency log |
| Long-tail customer never updates | Stale-version warning at 30 days; nag at 60 days; locked-no-detection at 90 days |

### Air-gap and offline customers

- Knowledge bundles can be exported to a USB-style sneaker-net for fully air-gapped tenants.
- Air-gapped tenants run their own internal Rekor mirror.
- Air-gap deployment is currently informal; formalise in Phase 5+ (item I6 in `docs/30-research-backlog.md`).

## Consequences

- The watchdog is a new component; modest engineering cost.
- TUF + transparency-log hosting adds operational complexity.
- Phased rollouts mean some tenants get fixes 7+ days later than others; security-fix releases compress this timeline (CTO + counsel approval to fast-track).
- Cultural: rollback isn't shameful; rollback that worked is a feature.

## Verification

- Annual external audit of the update path.
- Continuous CI tests: malicious manifest must be rejected; rollback must work; transparency-log inclusion required.
- Quarterly chaos exercise: simulate compromised release; verify watchdog rejects it.
- Public "verify any Artemis update" instructions in customer documentation.
