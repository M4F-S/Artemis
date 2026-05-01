# 13 — Design-Partner Program

## What a design partner is

A real SMB that:

- Runs Artemis on its production fleet (typically 20–100 endpoints to start).
- Reports real false positives, real missed detections, real performance issues.
- Sits with us for an hour every two weeks while we observe how their IT lead actually uses the product.
- Pays a steeply discounted rate (or nothing) in exchange for shaping the roadmap.
- Brings their own threat model — compliance pressures, sector-specific TTPs, cyber-insurance requirements.

We will sign two design partners during Phase 0–1. Targets:

- 1 in the **US** (so we hit CFAA + SOC 2 + insurer questionnaires).
- 1 in the **EU** (so we hit GDPR + NIS2 + EU data-residency).

## Why design partners can't be replaced

We cannot substitute a design partner with:

| Substitute | Why not |
|---|---|
| AI agent (Claude, etc.) | No real fleet, no real attackers, no auditor, no compliance pressure |
| Coding-school colleagues | Can build the product; cannot represent a buyer / IT-lead / auditor |
| Synthetic-SMB exercise | Reveals product gaps but not buyer mindset; no real "we'd never pay for this" feedback |
| Internal testing | Founder's-eye view; misses "the shape of the actual day" |

The unique value of a design partner is the **surprises** — the things we never thought to ask. Everything else can be built; this can only be heard.

## What we offer the design partner

- Free or steeply discounted use of Artemis throughout Phase 1–4 (rough comparable list price: $5–8/endpoint/month at GA; design partners pay $0–$2).
- A direct line to the founding team. Their voice shapes the roadmap.
- Co-branded case study at GA (with their approval).
- Right of first refusal on the next pricing tier when launched.
- Service-level support without contractual SLA penalty (we will work hard, but cannot promise enterprise support yet).

## What we ask of the design partner

- Run Artemis on at least 10 endpoints starting Phase 1, growing to 50–100 by Phase 2.
- Bi-weekly 60-minute review (recorded, with consent).
- Tag-along on incident-response simulations (we run, they observe / play attacker).
- Honest feedback delivered in writing within a week of each cycle.
- Permit anonymised / redacted telemetry samples to be used to improve detection (subject to their privacy controls and our DP defaults).

## What we DO NOT ask

- Public endorsement before they're ready.
- Confidential customer data.
- A long-term contract.
- Any waiver of legal rights or liability.

## Selection criteria — who we want

Strong fit:
- 30–250 employees, mixed Linux/Windows/macOS fleet.
- Has felt enough security pain to care (insurance audit, near-miss breach, sector pressure).
- Has at least one IT lead who can spend 2 hours a week on this.
- Operates in a regulated sector (so compliance reporting matters): finance, healthcare-adjacent, SaaS-with-customer-PII, dev tools, professional services.

Less strong fit (but possible):
- < 30 employees — too small to stress the multi-tenant + identity surface.
- Fully BYOD shops — initial Linux focus may not be ideal.

Avoid for now:
- Heavily regulated environments where deploying a v0.1 sensor would itself be a compliance issue (e.g. live PCI-DSS production with no test fleet).
- Customers who only want a finished product — they'll be unhappy.

## What colleagues from coding school CAN do (since the project owner asked)

Colleagues can absolutely contribute and add enormous value, just not as design partners. Concretely:

1. **Co-build Phase 1** as engineers (sensor, daemon, console, browser ext, ML). See `docs/12-task-backlog.md` Phase 1 tickets.
2. **Run the synthetic-SMB exercise** (P1-T81). Stand up 20 VMs, simulate a fictional company, red-team it, defend with Artemis. Cheap and high-signal for product gaps.
3. **Author detection rules.** YAML rule pack v0 (P1-T22) and follow-on packs are great first PRs.
4. **Build the evaluation harness.** Repeatable benchmark suite that runs every PR.
5. **Audit privileged code.** Fresh eyes find issues the author can't.
6. **Browser-extension cross-site testing.** Tedious, valuable.

What colleagues cannot do well: stand in for an auditor, a CFO, a buyer, a real attacker, an MSP analyst. Those experience-based viewpoints come only from real partners.

## Process — getting design partners

1. **Personal-network sourcing.** First two design partners typically come from the founder's network or a single warm intro. Ask in your alumni network, local CISO meetups, the open-source security community.
2. **Vetting.** 30-min intro call → 60-min product walkthrough using these docs → mutual decision.
3. **Paperwork.** A short MOU (not a real contract): expectations, term (3–6 months renewable), data handling, IP. Counsel reviews.
4. **Onboarding.** Once Phase 1 has a deployable build, install on 10 hosts, ramp from there.
5. **Bi-weekly cadence** through Phase 1–4.
