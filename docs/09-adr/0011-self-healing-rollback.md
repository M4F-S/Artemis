# ADR-0011 — Self-healing rollback safety

## Status
Accepted (Phase 0).

## Context

P15 promises automated rollback of compromised endpoints — an enormously valuable capability for ransomware recovery, and an enormously dangerous primitive if triggered wrongly. This ADR fixes the conditions under which Artemis is allowed to roll back a host without per-incident human approval.

## Decision

**Auto-rollback is OFF by default.** A tenant admin must explicitly enable it per scope (entire tenant, group, or individual host) and select the auto-rollback profile (`ransomware-only`, `confirmed-malicious`, or `disabled`).

When enabled, auto-rollback fires only when **all** of the following are true:

1. **Severity gate**: at least one CRITICAL alert from the incident.
2. **Multi-signal**: at least 2 of:
   - Mass-encryption pattern (file-write rate above threshold with high entropy on written data).
   - Known ransomware family signature hit.
   - Honeytoken file accessed (P3) within the same incident.
   - Provenance graph shows a confirmed exec→encryption chain.
3. **Backup verified**: the snapshot to roll back to was integrity-tested within the last 7 days (P22 H4).
4. **Pre-authorisation**: tenant admin pre-authorisation flag is set for this scope.
5. **Cloud confirmation**: the cloud control plane confirms; mesh-elected fallback coordinators may NOT trigger auto-rollback.
6. **Notification**: a destructive-action notification has been delivered to at least one tenant admin channel; a 60-second cancel window applies unless `auto-rollback-no-delay` is set.

If any condition fails → the action falls back to "propose to operator" mode.

For `confirmed-malicious` profile (broader than ransomware), the multi-signal set is replaced with: signed-malicious verdict from at least two of (rule, ML, federated IoC) AND a damage-assessment delta within bounded scope.

## Reversibility

- Rolled-back hosts retain a "tombstone" of the rolled-back state (encrypted, off-host) for 30 days so an incorrectly-triggered rollback can be partially undone for forensic / data-recovery purposes.
- A rolled-back machine generates a CRITICAL audit event regardless of outcome.

## Why all this caution

A worst case auto-rollback at scale across a fleet during a false-positive event would be catastrophic — it is essentially a self-DoS via legitimate channels. The conditions above are deliberately conservative so the operator is always informed and almost always in control. The price is that the dramatic "ransomware → automatic recovery" demo will sometimes require a single click of confirmation. That is an acceptable trade.

## Consequences

- Engineering must enforce these conditions in the orchestrator; CI tests assert each gate.
- Customer documentation must explain the trade-offs clearly; SMBs must not be sold a "fully autonomous" promise.
- The 60-second cancel window is an actual UI element with a working button, not a notification stub.
