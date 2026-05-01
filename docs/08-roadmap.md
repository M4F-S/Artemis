# 08 — Roadmap

The roadmap is **phased** — value delivered each phase, no huge bangs. P14 (Active Defense) is built throughout but locked off until Phase 5+ when legal clearance is secured.

## Phase 0 — Spec lock (this round)

- All `docs/` complete and reviewed.
- Two design partners (SMBs, ideally one with EU presence) signed.
- An external security advisor reviews the threat model.
- Hiring plan locked: founding security engineer (Rust + eBPF), founding ML engineer, founding full-stack, security advisor.

Exit criterion: every pillar has measurable success criteria and at least one design-partner use case.

## Phase 1 — Linux MVP (≈ 10 weeks)

- Linux sensor with eBPF substrate (P2).
- Userland daemon (Rust core, Wasm rule engine).
- LLM-fed-malware heuristic (P1.1 only, no browser yet).
- Endpoint deception (P3) on Linux.
- Intent sessions (P4) — CLI + minimal UI.
- Control plane minimum: ingest, detection engine, console v0, alerts.
- Reporting (P13): live dashboard only, no PDFs yet.
- Data: events + alerts pipeline; provenance graph behind a feature flag.

Exit criterion: design partner runs Artemis on a 50-host Linux fleet for 2 weeks; we hit the alert + MTTR targets and < 2% CPU.

## Phase 2 — Windows + LLM copilot (≈ 8 weeks)

- Windows sensor: ETW + minifilter + AMSI + WFP.
- LLM SOC-copilot (P5) — alert narratives + Q&A.
- Reporting (P13): weekly executive PDF.
- Hardware-rooted attestation (P9) Phase 1 — TPM enrolment + Secure Boot status.
- Identity fusion (P10) Phase 1 — Entra connector.

## Phase 3 — macOS + browser + privacy (≈ 8 weeks)

- macOS sensor: Endpoint Security + Network Extension.
- Browser extension (P1.2) — DOM injection + agent tool-call audit.
- Differential privacy (P6.1) on egress.
- Provenance graph (P7) general availability.

## Phase 4 — Hardening & robust ML (≈ 8 weeks)

- Certified-robust ML (P8) — DRSM-style for static + smoothed dynamic.
- Federated IoC (P6.2) — CKKS aggregation MVP.
- Hardware attestation (P9) Phase 2 — CFI policy enforcement.
- Identity fusion (P10) Phase 2 — Okta + Google + ITDR fusion rules.
- Supply-chain runtime guard (P11) — npm/pypi/cargo install hooks.
- Compliance bundles (P13) — SOC 2 + ISO 27001 evidence export.

## Phase 5 — Active Defense unlock (≈ 6 weeks)

- P14 capabilities A–E built (already specified, build now), shipped **off**.
- Legal review per US/EU/UK/CA/AU jurisdictions.
- Selective unlock with customer dual-control.
- P12 PQ signing fully in code-update pipeline.

## Stretch (post-Phase 5)

- Confidential-VM workloads (P9 Phase 3) for server tenants.
- Identity-fusion deeper UEBA (T5 insider).
- Mobile sensors (Android first; iOS strictly through MDM-managed posture).
- IoT / OT signal collection via passive network sensor.
- Marketplace for third-party rules / playbooks / decoys.

## Risks tracked through the roadmap

| Risk | Mitigation |
|---|---|
| eBPF kernel ABI churn | Use `aya` + CO-RE; CI matrix across LTS kernels |
| Apple Endpoint Security entitlement denial | Apply early; have non-ES fallback (sysdiagnose) |
| Defender coexistence issues on Win | Conform to MSFT 3rd-party AV requirements; ship coexistence test suite |
| LLM provider price/availability | Multi-provider abstraction; local Llama fallback |
| Adversary adapts to certified-robust models | Continuous red-team; defence-in-depth via P3 + P4 |
| Legal exposure from P14 | Default-off; per-jurisdiction policy; dual-control |
| Customer privacy concerns | DP + BYOK + pseudonymisation hardwired |
