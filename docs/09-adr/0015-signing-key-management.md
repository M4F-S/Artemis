# ADR-0015 — Signing-key management

## Status
Accepted (Phase 0).

## Context

The Artemis spec promises "signed everything" — agent updates, knowledge bundles, rules, models, RL policies, BAS techniques, NAC playbooks, audit-log chains. Until now no doc names where the keys live, who can sign, what rotation looks like, or how recovery works. Signing-key compromise is the existential threat for a security vendor (SolarWinds 2020; CCleaner 2017; ASUS Live Update 2019). "Signed" without a key-management story is a marketing claim.

## Decision

### Key roles (one HSM-backed key per role)

| Role | What it signs | HSM | Threshold | Rotation |
|---|---|---|---|---|
| **Root** | Operational keys | offline HSM (cold) | 3-of-5 | once per 5 years (ceremony) |
| **Release** | Agent binaries, control-plane container images | online HSM (warm) | 2-of-3 | annual |
| **Knowledge** | Rule packs, ML models, deception templates, intent templates, RL policies, BAS scenarios | online HSM | 2-of-3 | annual |
| **Playbook** | P14 active-defense playbooks, NAC connector configs | online HSM | 2-of-3 | annual |
| **Agent CA** | Per-device certs (issued to agents at enrolment) | online HSM | 1 (delegated authority) | annual |
| **Audit** | Audit-log signatures (per-tenant) | online HSM | 1 | quarterly |

All operational signing happens via a signing service (`artemis-signer`) that talks to the HSMs over an authenticated channel. Engineers never hold raw keys; they trigger signing operations via signed requests.

### HSM choice

- **Cloud HSM** (AWS CloudHSM / GCP Cloud HSM / Azure Managed HSM) for warm operational signing.
- **Yubico HSM2** or equivalent on-premise device, kept offline in a safe, for the root signing ceremonies.
- FIPS 140-3 Level 3 validated. No exceptions.

### Threshold signing for sensitive roles

- **Release** and **Knowledge** keys use threshold ECDSA / ML-DSA (per cipher's threshold support):
  - 2-of-3 quorum required to sign.
  - The 3 quorum members are: tech lead, release engineer, on-call.
  - Quorum members rotate quarterly.
- A single compromised laptop cannot sign a release. A compromised individual cannot sign alone.

### Sigstore-style transparency log

- Every signature emitted by `artemis-signer` is also published to a public Rekor-style log.
- Customers can verify any artefact signature against the log.
- The log is append-only and tamper-evident (Merkle tree).
- This is the single most important customer-trust signal — it makes "signed" verifiable, not just claimed.

### Rotation cadence

- **Operational keys** (Release, Knowledge, Playbook, Agent CA, Audit): annual rotation. Old keys retire to verify-only mode for 90 days, then are revoked.
- **Root keys**: rotated once per 5 years via offline ceremony with 3-of-5 quorum + counsel observer + recorded video evidence.
- **Round keys** (per ADR-0014): destroyed after each federation round.

### Compromise response

If a release-or-knowledge signing key is suspected compromised:

1. Pause all releases via the kill-switch (signed kill-manifest, root-key authority).
2. Generate a new operational key on the HSM.
3. Cross-sign the new key with the root.
4. Push a transition manifest signed by both old + new keys.
5. Customers verify the transition; agents that don't see the new key within 7 days lock to the last-known-good version + alert.
6. Counsel + customer comms per ADR-0027 (internal IR).

### Bring-online runbook for offline root key

- Quarterly drill: offline ceremony, signed test artefact, verified.
- Annual surprise drill: do we actually still have the safes, the threshold members, the verification process?

### What is NOT done

- We do **not** delegate signing to per-engineer smart cards in the long term. That model fails open under social engineering.
- We do **not** trust a single CI runner with a signing key. CI invokes `artemis-signer` over an authenticated channel; the runner cannot sign without quorum.
- We do **not** keep the root online "for convenience." Root is offline; only the operational keys are online.

## Threat model

Robust against:
- Compromise of one quorum member (need 2-of-3 or 3-of-5).
- Compromise of one CI runner (cannot sign alone).
- Compromise of the signing service binary (HSM still requires authenticated request).
- Replay of past signatures (Rekor log includes time + UUID; agent verifies log inclusion).

Not fully robust against (residual risk):
- Compromise of HSM provider's infrastructure (cloud HSM): documented, accepted; offline root + rotation cadence limits blast radius.
- Compromise of all 3 quorum members simultaneously: would require coordinated attack on 3 distinct individuals; we accept this residual risk for ergonomic reasons.

## Consequences

- Operational cost: HSMs + ceremony tooling + transparency-log hosting (~$5–10k/year initially).
- Process cost: every release requires 2 humans available simultaneously.
- Cultural cost: engineers cannot "just push a fix." Build the muscle.
- Customer-trust dividend: substantial. Customers who require it (regulated industries) have a public log to point auditors at.

## Verification

- Annual external audit of HSM access paths.
- Quarterly drill of root-key bring-online.
- Annual third-party red-team specifically targeting the signing path.
- Continuous: every signature published to the transparency log; deviations alarmed.
