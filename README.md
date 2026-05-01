# Artemis

Next-generation, cross-platform endpoint protection for the SMB / mid-market.

Artemis is **architecture-spec stage** — no production code yet. This repo currently contains only design documents. The intent is to lock the design before any line of code is written, so the engineering team (or a future automation) can implement directly from the spec.

## Why Artemis

Mainstream NGAV/EDR/XDR vendors (Defender, CrowdStrike, SentinelOne, Sophos, Palo Alto Cortex) already cover signatures, behavioural ML, and EDR telemetry well. Artemis targets the gaps they leave open:

- AI-native attacks: LLM-fed runtime malware, browser-agent prompt injection, "vibeware".
- Kernel blind spots: in-kernel eBPF abuse, kernel-mode rootkits.
- Identity-driven intrusions (79% of 2024 detections were malware-free).
- Supply-chain runtime risk (npm/pypi typosquatting +104% YoY).
- SMBs that need plain-English explanations, not enterprise dashboards.

## Pillars

The product is organised around 14 capability pillars (full detail in [`docs/04-detection-pillars/`](docs/04-detection-pillars/)):

| # | Pillar | Status |
|---|---|---|
| P1 | AI-aware defence | Spec |
| P2 | Unified kernel visibility | Spec |
| P3 | Endpoint deception | Spec |
| P4 | Intent sessions | Spec |
| P5 | LLM SOC-copilot | Spec |
| P6 | Privacy-respecting telemetry | Spec |
| P7 | Causal provenance graphs | Spec |
| P8 | Certified-robust ML | Spec |
| P9 | Hardware-rooted attestation | Spec |
| P10 | Identity fusion (ITDR) | Spec |
| P11 | Supply-chain runtime guard | Spec |
| P12 | Post-quantum code signing | Spec |
| P13 | Reporting & dashboards | Spec |
| P14 | Active Defense Agent (legally gated) | Spec |

## Read order

1. [Vision](docs/00-vision.md) — problem, customer, competitive positioning.
2. [Threat model](docs/01-threat-model.md) — adversary tiers, assets, trust boundaries.
3. [System architecture](docs/02-system-architecture.md) — components and data flow.
4. [Sensor design](docs/03-sensor-design.md) — per-OS sensors.
5. [Detection pillars](docs/04-detection-pillars/) — one file per pillar.
6. [Data model](docs/05-data-model.md) — events, alerts, provenance graph.
7. [Control plane](docs/06-control-plane.md) — multi-tenant SaaS.
8. [Deployment & ops](docs/07-deployment-and-ops.md) — installer, telemetry budget, SLAs.
9. [Roadmap](docs/08-roadmap.md) — phasing.
10. [ADRs](docs/09-adr/) — locked architectural decisions.
11. [Glossary](docs/10-glossary.md).

## License

Undecided. See [ADR-0008](docs/09-adr/0008-licensing.md). Default-closed until set.
