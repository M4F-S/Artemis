# P15 — Self-Healing

**Marquee pillar (joint with P16).** Artemis recovers from compromise, tampering, and degradation **without human intervention** in the common case, while remaining safe under adversarial attempts to *trigger* self-healing as a destructive primitive.

## Goals

1. Restore Artemis itself if disabled, killed, or downgraded.
2. Restore the protected endpoint to a known-good state when compromise is confirmed (and only when confirmed).
3. Rotate compromised credentials, sessions, and tokens automatically.
4. Reconcile drift from gold attestation baselines.
5. Maintain protection during cloud / network outages.

## Capabilities

### S1 Agent self-protection + auto-recovery

- Kernel-mode self-protection (PPL on Win, locked-down service on Linux/macOS).
- Cloud watchdog: missing-heartbeat → re-deploy via the OS management channel (Intune / JAMF / Ansible / a sidecar bootstrap).
- Tamper alerts (signed, hash-chained) sent out-of-band before disablement completes — even if the agent is being killed, the last gasp gets out.
- Bootstrap shim is the **only** component that can re-inject the agent; it is single-purpose, signed (P12), and read-only.

### S2 Endpoint snapshot + rollback

- Integrate with the OS-native snapshot mechanism: Btrfs / ZFS on Linux, APFS snapshots on macOS, VSS on Windows.
- Take a point-in-time snapshot at low-risk moments (idle, post-update).
- On confirmed compromise: roll back **after** human confirmation by default; auto-rollback only when (a) ransomware-encryption pattern confirmed *and* (b) tenant policy = `auto-rollback-ransomware`.
- Restore from immutable backup (P22 integration: Veeam / Rubrik / AWS Backup / restic) for off-host recovery.

### S3 Credential & session healing

- On `IDENTITY_COMPROMISE` alerts (P10), automatically:
  - Revoke current sessions.
  - Force MFA re-enrolment.
  - Rotate the user's secrets via Vault / AWS SM / GCP SM / Azure KV integrations.
- Service-account rotation: detect compromise → rotate → push new key via secret-manager → notify owner. Reversible if false-positive.

### S4 Continuous attestation reconciliation

- Periodic TPM re-quote (P9) compared against the gold PCR set.
- On drift: classify (benign update? attacker?). Drive remediation:
  - Benign update → re-baseline gold with admin sign-off.
  - Suspected tampering → freeze host, alert, queue rollback.

### S5 Graceful cloud-outage degradation

> **Scope downgraded from the original "decentralised mesh fallback" per the senior audit (`docs/29-senior-audit.md`, issue C6).** Distributed-coordinator election is genuinely Raft / Paxos territory and is deferred to a post-Phase-7 stretch goal. The Phase-1–6 deliverable is the simpler version below.

- During cloud outages, agents continue applying the locally-cached rule pack and the local detection engine.
- Events queue to the local encrypted spool (per `docs/05-data-model.md` wire-level reliability section); spool size capped per agent config.
- Inside-perimeter P14 actions whose playbooks are locally cached (e.g. `kill process`, `isolate host`) remain available; cloud-only actions (Tier 4 NAC, Tier 5 escalate-to-authority) are unavailable until cloud connectivity returns.
- No agent-to-agent coordination is performed in this scope. Each agent operates independently against its local cache.
- On reconnect, agents drain the spool to ingest in event-id order; the control plane reconciles and emits any deferred alerts.

The decentralised mesh + read-only coordinator election from the original spec is re-classified as a long-term R&D project.

### S6 Damage assessment + restore

- When a compromise is contained, the provenance graph (P7) drives a damage report: which files written, which secrets touched, which identities used, which lateral hops attempted.
- For each damaged asset, a restore plan is proposed — file rollback, secret rotation, identity revocation, network cleanup.
- Operator approves the plan; orchestrator executes via P14.

## Adversarial considerations

Self-healing is a **double-edged primitive**. An attacker who can trigger it falsely gains a destructive capability. Mitigations:

- Auto-rollback gated on multi-signal confirmation (ransomware-encryption rate, mass file rewrite, alert severity ≥ CRITICAL, *and* tenant flag).
- Self-rotation triggers logged + alerted to a second admin channel.
- Mesh-elected local coordinator is **read-only** with respect to destructive actions.
- All self-healing actions reversible where possible; irreversible ones require pre-issued tenant authorisation.

## Coverage

- Reduces MTTR from incident-detect to fleet-clean dramatically.
- Ransomware-recovery path is the headline: file changes → rollback → service restored, not "pay or restore from backup three days later".

See [ADR-0011](../09-adr/0011-self-healing-rollback.md) for the safety contract.
