# 07 — Deployment & Ops

## Agent distribution

| OS | Artefact | Signing |
|---|---|---|
| Windows | `.msi` (per-arch x64, arm64) | Authenticode (EV cert) + Artemis ML-DSA |
| macOS | notarised `.pkg` + `.app` | Apple Developer ID + notarisation + Artemis ML-DSA |
| Linux | `.deb`, `.rpm`, static `.tar.gz`, OCI image | repo signing keys (GPG) + Artemis ML-DSA |
| Browser | Chrome Web Store + Edge Add-ons + Firefox AMO | platform signatures |

All artefacts double-signed (P12). Updates downloaded over TLS, integrity-checked against the prior-signed manifest, applied atomically (A/B partition on Linux/Win; macOS replace-after-quit).

## Enrolment flow

1. Admin creates a tenant in the console, downloads a signed enrolment bundle (`tenant-id`, `enrolment-token`, `ca-pin`).
2. Installer runs on endpoint, generates a key pair locally, requests a device cert from control plane, presents the enrolment token + TPM quote (P9).
3. Control plane verifies token + TPM quote against tenant gold measurement (or "first-seen" if a baseline isn't pinned).
4. Cert issued; agent starts service; TUS-style resumable upload of initial inventory.

## Update channels

- `stable` — fortnightly.
- `beta` — weekly (~5–10% of fleet, customer-opt-in).
- `dev` — internal only.

Rollback: every release has a guaranteed-safe rollback. Failed-update telemetry from > N% of fleet within an hour automatically pauses the rollout and notifies the on-call.

## Telemetry budget (per endpoint, idle)

- CPU: < 2% average, < 5% p99.
- RAM: < 150 MB (sensor + daemon + browser ext combined).
- Disk: < 200 MB on-disk spool cap (encrypted).
- Net: < 50 MB/day baseline; bursts during incidents capped + notified.

CI runs `stress-ng`, kernel build, video render, and a 1k-process exec workload as performance regressions; merges blocked on regression > 10%.

## SLAs

| Metric | Target | Measured |
|---|---|---|
| Console availability | 99.9% | per-tenant |
| Ingest availability | 99.95% | per-region |
| Alert end-to-end p99 | < 60 s | per-tenant |
| Containment p99 (operator-initiated) | < 5 s for kill, < 30 s for isolate | per-tenant |

## On-call

- 24/7 on-call rotation across two regions.
- Tier-1 SaaS issues: Artemis on-call.
- Tier-1 customer security incidents: customer's IT lead is primary; Artemis MDR add-on offers Artemis on-call as primary.

## Compliance / certifications roadmap

- Year 1: SOC 2 Type II.
- Year 1.5: ISO 27001.
- Year 2: HIPAA BAA pre-template, FedRAMP Moderate (only if a federal customer pulls).
- Year 2: NIS2 / DORA mappings.

## Cost model (rough, per endpoint per month)

| Component | $/endpoint/mo |
|---|---|
| Compute (control plane shared) | ~0.20 |
| Storage (ClickHouse + Memgraph) | ~0.30 |
| LLM copilot (Anthropic, cached) | ~0.40 |
| Data egress | ~0.05 |
| **Cloud cost** | **~0.95** |

Pricing target: $5–8/endpoint/month for Standard, $10–15 for Plus (P9 + P14), $20+ for MDR add-on.

## Security operations for Artemis itself

- All Artemis production access via PAM with hardware keys.
- All container images SLSA L3 built, with provenance attestations.
- Secrets in cloud KMS, never in env vars at rest.
- Quarterly internal red-team exercises against the production control plane.
- Bug bounty (HackerOne) within 6 months of GA.
