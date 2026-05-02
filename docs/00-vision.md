# 00 — Vision

## Problem

The 10–500-seat SMB / mid-market sits in a security capability gap:

- Too small for a real SOC; can't hire round-the-clock analysts.
- Too valuable to be ignored by attackers — ransomware groups now industrially target this segment.
- Existing tools split into two unsatisfying buckets:
  - **Consumer AV** (Defender, Norton, Bitdefender consumer). Cheap, low-friction, but signature-heavy and weak on identity, supply-chain, and AI-era threats.
  - **Enterprise EDR/XDR** (CrowdStrike Falcon, SentinelOne Singularity, Palo Alto Cortex). Powerful but priced and tuned for enterprise SOCs; alert volume drowns SMBs and the UX assumes a tier-1 analyst on staff.

Meanwhile, the threat landscape moved:

- **79% of 2024 detections were malware-free** — identity-, OAuth-, and session-based.
- **AI-fed malware** (MalTerminal, vibeware) pulls payloads from LLM APIs at runtime.
- **AI browser agents** (ChatGPT Atlas, Claude for Chrome, Perplexity Comet) introduce indirect prompt injection that OpenAI itself says may never be fully patchable.
- **eBPF abuse** has a verified visibility gap on Linux.
- **Supply-chain typosquatting** on npm/pypi is up 104% YoY.

## Target customer

- 10–500 employees.
- Mixed fleet: Windows + macOS laptops, Linux servers, browser-heavy SaaS workloads.
- One IT lead or an MSP, no dedicated SOC analyst.
- Compliance pressure: SOC 2, HIPAA, PCI-DSS, increasingly NIS2 / DORA in EU.
- Buying triggers: cyber insurance renewal, customer security questionnaires, a recent breach in their vertical.

## Honest framing

The senior audit (`docs/29-senior-audit.md`) flagged claims that need careful framing in customer-facing material:

- **eBPF-abuse detection is a Linux-only differentiator.** On Windows + macOS, Artemis matches market norms (ETW + Endpoint Security) but does not lead. Marketing must not over-generalise.
- **Certified-robust ML** is bounded by perturbation norm + small radius — not a universal robustness guarantee. UI shows the radius numerically.
- **Self-healing** delivers graceful degradation + secret rotation + snapshot-based rollback. The original "decentralised mesh fallback" is deferred to a post-Phase-7 stretch goal.
- **Active Defense (P14)** ships built but disabled until per-jurisdiction legal review (ADR-0009).
- **Apollo (offensive companion)** is lab-only at first; future commercial SKU is gated per jurisdiction (ADR-0012).
- **Self-evolving** federation is robust within a bounded adversary fraction (ADR-0014); pauses (not "tolerates") under unbounded attacks.

The senior audit is the canonical reference; this section summarises.

## Marquee positioning

Artemis is **the AI-native, autonomic security platform** — both halves matter equally:

- **AI-native** — built for the world where attackers and defenders both use LLMs.
- **Autonomic** — self-evolving (continual learning + auto-rule synthesis) and self-healing (auto-recovery, auto-rollback, auto-rotation), bounded by an explicit safety contract (ADR-0010 / ADR-0011).

## Value props

1. **AI-native by default** — built for the world where attackers and defenders both use LLMs.
2. **Self-evolving** — gets better at its job over time. LLM rule synthesis from incidents; continual ML with poisoning resistance; built-in BAS keeps Artemis honest.
3. **Self-healing** — auto-restarts disabled agents, auto-rolls-back ransomware'd hosts (under safety gates), auto-rotates compromised secrets.
4. **Plain-English explanations** — every alert is human-readable; the SOC-copilot answers "why did Artemis block this?" in one paragraph.
5. **Privacy-respecting** — differential privacy + federated IoC sharing; the customer's raw telemetry never leaves their tenant.
6. **Hard-to-fool** — certified-robust ML, hardware-rooted attestation, and active deception layered together.
7. **One platform, one console** — endpoint + identity + email + network + cloud + AI-app, all OCSF-aligned.

## Competitive matrix

| Capability | Defender for Business | SentinelOne Singularity | Huntress | Crowdstrike Falcon Go | **Artemis** |
|---|---|---|---|---|---|
| Cross-platform agent | ✓ | ✓ | ✓ (limited macOS) | ✓ | ✓ |
| Signature + behavioural ML | ✓ | ✓ | ✓ | ✓ | ✓ |
| LLM-fed malware detection | ✗ | partial | ✗ | ✗ | **✓ (P1)** |
| Browser-agent / prompt-injection guard | ✗ | ✗ | ✗ | ✗ | **✓ (P1)** |
| eBPF-abuse detection (Linux) | ✗ | partial | ✗ | partial | **✓ (P2)** |
| Endpoint-level deception (canary files/keys) | ✗ | partial | ✓ (limited) | ✗ | **✓ (P3)** |
| Intent-scoped baselining | ✗ | ✗ | ✗ | ✗ | **✓ (P4)** |
| Plain-English LLM copilot for SMB | ✗ | enterprise tier | partial | ✗ | **✓ (P5)** |
| Differential-privacy telemetry | ✗ | ✗ | ✗ | ✗ | **✓ (P6)** |
| Causal provenance + LLM root-cause | partial | partial | ✗ | partial | **✓ (P7)** |
| Certified-robust ML (provable bounds) | ✗ | ✗ | ✗ | ✗ | **✓ (P8)** |
| Hardware-rooted attestation policy | partial (Pluton) | ✗ | ✗ | ✗ | **✓ (P9)** |
| Identity / ITDR fusion | partial (E5) | ✓ | partial | ✓ | **✓ (P10)** |
| Supply-chain runtime guard | ✗ | ✗ | ✗ | ✗ | **✓ (P11)** |
| Post-quantum code-sign verify | ✗ | ✗ | ✗ | ✗ | **✓ (P12)** |
| SMB-priced reporting (exec PDF, ATT&CK) | ✗ | ✗ | partial | ✗ | **✓ (P13)** |
| Active defense (legally gated) | ✗ | ✗ | ✗ | ✗ | **✓ (P14)** |

Differentiation density is highest in P1, P3, P4, P8, P9, P11, P12, P13, P14. These should anchor marketing.

## North-star metric

**Mean time from initial intrusion to full containment** — measured per design-partner tenant. Target: under 15 minutes for the top 10 ATT&CK techniques in the SMB threat profile.
