# Artemis

> **Status: Paused (May 2026).** This project is on hold pending capital and a senior co-founder. The full architectural specification is preserved as a complete reference (97 docs across 22 capability pillars, 18 ADRs, samples, session prompts, senior audit). See [`docs/14-session-handoff.md`](docs/14-session-handoff.md) for the full closure context, and [`docs/29-senior-audit.md`](docs/29-senior-audit.md) for the honest market positioning. Resumption is realistic when (a) a senior co-founder is recruited, (b) EXIST / seed funding is secured, and (c) the scope is narrowed to a single wedge (the strategic review recommends privacy-first Linux EDR for EU developers and small institutions). The spec is a founder portfolio asset; preserve it.

Next-generation, cross-platform endpoint protection for the SMB / mid-market.

Artemis is **architecture-spec stage** — no production code yet. This repo currently contains only design documents. The intent is to lock the design before any line of code is written, so the engineering team (or a future automation) can implement directly from the spec.

## Why Artemis

Mainstream NGAV/EDR/XDR vendors (Defender, CrowdStrike, SentinelOne, Sophos, Palo Alto Cortex) already cover signatures, behavioural ML, and EDR telemetry well. Artemis targets the gaps they leave open:

- AI-native attacks: LLM-fed runtime malware, browser-agent prompt injection, "vibeware".
- Kernel blind spots: in-kernel eBPF abuse, kernel-mode rootkits.
- Identity-driven intrusions (79% of 2024 detections were malware-free).
- Supply-chain runtime risk (npm/pypi typosquatting +104% YoY).
- SMBs that need plain-English explanations, not enterprise dashboards.

## Marquee

Artemis is **the AI-native, autonomic security platform**. Both halves matter equally: AI-native (built for LLM-era attacks and defences) and autonomic (self-evolving + self-healing under an explicit safety contract — see [ADR-0010](docs/09-adr/0010-autonomic-safety.md) and [ADR-0011](docs/09-adr/0011-self-healing-rollback.md)).

## Pillars

The product is organised around 22 capability pillars (full detail in [`docs/04-detection-pillars/`](docs/04-detection-pillars/)):

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
| **P15** | **Self-Healing** *(marquee)* | Spec |
| **P16** | **Self-Evolving (continual ML + auto-rules)** *(marquee)* | Spec |
| P17 | Built-in BAS / self-red-team | Spec |
| P18 | Email & phishing protection | Spec |
| P19 | Network detection (NDR) | Spec |
| P20 | Cloud workload protection (CWPP) | Spec |
| P21 | LLM / AI-app firewall | Spec |
| P22 | Threat hunting + DFIR + backup integration | Spec |

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

## Picking up the work

- New here? Read [Onboarding](docs/11-onboarding.md) (60-minute path).
- Want to contribute? Read [`CONTRIBUTING.md`](CONTRIBUTING.md).
- Picking up an existing thread? Read [Session handoff](docs/14-session-handoff.md) — most recent entry first.
- Need a ticket? Open the [Task backlog](docs/12-task-backlog.md).
- Looking for design partners? See the [Design-partner program](docs/13-design-partner-program.md).
- Targeting 42 Berlin specifically? Read [42 Berlin adaptation](docs/15-42-berlin-adaptation.md) and [42 Berlin outreach](docs/16-42-berlin-outreach.md).
- Continuing as Claude Code? Read [`CLAUDE.md`](CLAUDE.md) before doing anything.

## Implementation-readiness pack

- [Engineering bootstrap](docs/17-engineering-bootstrap.md) — workspace layout, dev env, CI, code style.
- [Team & headcount](docs/18-team-and-headcount.md) — role profiles, hiring sequence, how many people per phase.
- [Cost model](docs/19-cost-model.md) — Phase 1–4 burn rate.
- [Definition of Done](docs/20-definition-of-done.md) — observable exit criteria per phase.
- [Kickoff checklist](docs/21-kickoff-checklist.md) — single-page gate before first commit.
- [Apollo (offensive testing companion)](docs/22-apollo-offensive-companion.md) — sister project; lab-only (per [ADR-0012](docs/09-adr/0012-apollo-scope.md)).
- [Parallel implementation sessions](docs/23-parallel-sessions.md) — workstreams WS-A–H, branch protocol, file ownership.
- [The first PR](docs/24-first-pr.md) — concrete bootstrap PR scope.
- [Local dev runbook](docs/25-dev-runbook.md) — clone → running agent.
- [Customer lifecycle](docs/26-customer-lifecycle.md) — discovery → onboarding → steady-state → offboarding.
- [Internal incident response](docs/27-internal-incident-response.md) — what we do when Artemis itself is the target.
- [Versioning & compatibility](docs/28-versioning-and-compatibility.md) — semver, schema evolution, deprecation.
- [**LAUNCH**](docs/31-launch.md) — single-page kickoff playbook. Open this when you're ready to start Phase 1.
- [Senior audit](docs/29-senior-audit.md) — independent architecture review with critical issues + remediations.
- [Research backlog](docs/30-research-backlog.md) — improvement items tracked from the audit and the latest research.
- [Session prompts](docs/session-prompts/) — paste-ready prompts for parallel Claude Code sessions.
- [Sample artefacts](samples/) — `event.proto`, `control_plane.proto`, `console-api.openapi.yaml`, `cli-commands.md`, `rule.example.yaml`, `agent.toml.example`, `migrations/*.sql`.

## License

Undecided. See [ADR-0008](docs/09-adr/0008-licensing.md). Default-closed until set.
