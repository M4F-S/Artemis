# 11 — Onboarding

A 60-minute path from "I just heard about Artemis" to "I can pick up a ticket."

## 0–10 min: orientation

1. Skim [`README.md`](../README.md).
2. Read [`docs/00-vision.md`](00-vision.md) end-to-end.
3. Look at the competitive matrix; note which pillars matter most.

## 10–25 min: threat model & architecture

4. Read [`docs/01-threat-model.md`](01-threat-model.md). Make a mental note of the adversary tiers (T0–T5) — you'll see them again in pillars.
5. Read [`docs/02-system-architecture.md`](02-system-architecture.md). Trace one event from sensor to alert.

## 25–40 min: pick your area

6. Skim [`docs/04-detection-pillars/`](04-detection-pillars/) headers. Pick one pillar that matches your skill.
7. Read that pillar's full doc.

## 40–55 min: pick a task

8. Open [`docs/12-task-backlog.md`](12-task-backlog.md). Find tickets tagged with your pillar.
9. Read the acceptance criteria. Confirm you understand them.
10. Cross-reference any ADR the ticket cites.

## 55–60 min: ready to start

11. Read [`CONTRIBUTING.md`](../CONTRIBUTING.md) — workflow, branch names, PR rules.
12. If you're an AI agent, read [`CLAUDE.md`](../CLAUDE.md).
13. Read the latest [`docs/14-session-handoff.md`](14-session-handoff.md) — what the most recent session did.
14. Branch and start. Update the handoff doc when you finish.

## Roles you can take

| Role | Time / week | Owns |
|---|---|---|
| Sensor engineer (Linux/Win/macOS) | 10–20 h | one OS sensor, eBPF/ETW/ES integration |
| Daemon engineer | 10–20 h | shared core, rule engine, scorers |
| Control-plane engineer | 10–20 h | ingest, detection, storage |
| Console / UI engineer | 10–20 h | Next.js dashboard, alert UX |
| Browser-extension engineer | 5–10 h | MV3 extension across Chrome/Edge/Firefox |
| Detection author | 5–10 h | YAML rules, ATT&CK coverage tracking |
| ML engineer | 10–20 h | smoothed classifiers, ONNX bundles, drift |
| Reverse / red-team | 5–10 h | synthetic-SMB exercise, evasion testing |
| Security reviewer | 5 h | audit unsafe Rust, threat-model deltas |
| Docs / ADR scribe | 2–5 h | keep specs accurate as code lands |

## What you don't need to start

- A finished product. This is Phase 0.
- A specific employer relationship. We'll figure out IP / CLAs in Phase 1 once licensing is decided ([ADR-0008](09-adr/0008-licensing.md)).
- Cybersecurity certifications. We'll teach what we need; what we want is curiosity, rigour, and willingness to read.

## What you do need

- A laptop you can run Linux on (VM or bare-metal). Phase 1 is Linux-first.
- Basic Git literacy.
- For sensor / daemon work: comfort reading C and Rust; willingness to debug kernel-userland boundaries.
- For ML work: comfort with PyTorch / ONNX, basic understanding of adversarial robustness.
- For control-plane work: comfort with async Rust, a basic understanding of distributed systems.

## Common stumbling blocks

- **"I can't find an answer in the docs."** Open an issue (when GitHub Issues is enabled) or ping the project owner. Don't guess.
- **"The kernel build broke my eBPF program."** CO-RE drift; check ADR-0003 and the kernel matrix in CI.
- **"I don't know if this is a P-pillar or a generic infra concern."** If it's used by ≥2 pillars, it's infra. Put it in `crates/artemis-core` (when we have one).
- **"I want to add a feature that isn't in the roadmap."** Write a draft ADR and discuss before coding.
