# 14 — Session Handoff

This file is the chronological log of work sessions on Artemis. **Every session ends with an entry here.** Read the most recent entry first when you pick up.

Format: dated heading + what was done + what's next + open questions.

---

## 2026-05-01 — Session 1 (Claude Code, opus-4-7)

### What was done

- Phase 0 spec lock.
- Wrote 33 docs across `README.md` + `docs/` covering:
  - Vision, threat model, system architecture, sensor design.
  - 14 detection-pillar specs (P1–P14), including user-added P13 Reporting and P14 Active Defense.
  - Data model (OTLP wire format, OCSF alerts, Memgraph provenance schema).
  - Control plane (multi-tenant SaaS, ClickHouse + Postgres + Memgraph + R2/S3).
  - Deployment & ops (installer, telemetry budget, SLAs, cost model).
  - Roadmap (5 phases, ~40 weeks).
  - 9 ADRs, including ADR-0009 capturing the Active-Defense legal-clearance gate.
  - Glossary.
- Added contributor onboarding: `CLAUDE.md`, `CONTRIBUTING.md`, `docs/11-onboarding.md`, `docs/12-task-backlog.md`, `docs/13-design-partner-program.md`, this handoff file.
- Committed and pushed initial commit on `claude/research-antivirus-ideas-BWqcG`.

### Decisions made

- Cross-platform from day 1 (Linux + Windows + macOS + browser).
- Audience: SMB / mid-market (10–500 employees).
- This round: architecture spec only. No production code.
- License: deferred (ADR-0008).
- P14 Active Defense: built and shippable but disabled at runtime; legal review in flight.

### Open questions awaiting the project owner

- Legal counsel reply on P14 / ADR-0009 / threat model.
- Two design-partner SMBs (1 US, 1 EU) — sourcing.
- Founding engineer / colleagues recruitment — see `docs/13-design-partner-program.md` and `CONTRIBUTING.md`.
- License decision (re-evaluate at end of Phase 1 per ADR-0008).
- Hosting / cloud-provider commitment for the control plane (default: GCP primary, AWS secondary; not yet ratified).

### What's next (priority order)

1. **External legal review of ADR-0009 + P14 + threat model.** Owner action; Claude blocked.
2. **Recruit 1–2 founding engineers / colleagues.** Owner action.
3. **Source 2 design partners.** Owner action; criteria in `docs/13-design-partner-program.md`.
4. **Set up CI scaffolding (no code yet).** Any contributor; ticket P0-T05.
5. **Begin Phase 1 (Linux MVP)** when 1–3 are in motion. Tickets in `docs/12-task-backlog.md` Phase 1.

### Files touched

- All under `/`, `/docs/`, `/docs/04-detection-pillars/`, `/docs/09-adr/`.
- Total: 38 files (5 new this commit beyond the prior 33: `CLAUDE.md`, `CONTRIBUTING.md`, `docs/11-onboarding.md`, `docs/12-task-backlog.md`, `docs/13-design-partner-program.md`, this `docs/14-session-handoff.md`).

### Risks / things I'd flag

- The spec is ambitious. Phase 1 alone is ~10 weeks of engineering for a 2–3-person team. Cut scope before quality.
- P14 is the biggest legal hot-spot. Resist any temptation to enable it ahead of legal sign-off, even for a demo.
- LLM-cost forecasting in P5 assumes prompt caching is honoured; verify with Anthropic before committing pricing.
- eBPF kernel ABI churn risk is real; CI matrix is non-negotiable.
- Apple's Endpoint Security entitlement approval is on the critical path for Phase 3; apply early.

---

---

## 2026-05-01 — Session 2 (Claude Code, opus-4-7)

### What was done

- Reviewed prior spec; identified coverage gaps (no email, no NDR, no CWPP, no DLP, no mobile, no native vuln-mgmt, no LLM-app firewall, no native hunting/DFIR/backup integration) and the absence of an explicit autonomic loop.
- Researched: self-healing security, MAPE-K, continual ML with adversarial poisoning, autonomous SOC, LLM rule synthesis (RuleGenie / RulePilot / LLMCloudHunter), BAS / AEV.
- Discussed scope with project owner. Owner chose: **Complete XDR platform**, **AI-native + autonomic both as marquee**, **add P15 self-healing + P16 self-evolving + P17 BAS + P18 email** (and by implication the other XDR domains), **adapt for 42 Berlin and target now**.
- Wrote 8 new pillar docs: P15 (self-healing), P16 (self-evolving), P17 (BAS), P18 (email), P19 (NDR), P20 (CWPP), P21 (LLM/AI-app firewall), P22 (hunting + DFIR + backup).
- Wrote two new ADRs: ADR-0010 (autonomic-loop safety contract — MAPE-K bounding, action allowlist, federation safety, knowledge integrity) and ADR-0011 (self-healing rollback safety — multi-signal gate, tenant pre-authorisation, 60-second cancel window).
- Wrote 42-Berlin-specific docs: `docs/15-42-berlin-adaptation.md` (intent template pack, BYOD enrolment, EU residency, peer-review supply-chain extension, "Break Artemis" CTF idea) and `docs/16-42-berlin-outreach.md` (pitch template + demo plan + objection prep).
- Updated `docs/00-vision.md` to reframe marquee as "AI-native autonomic platform" and added P15–P22 to competitive matrix.
- Updated `docs/01-threat-model.md` to add T6 (autonomic-loop abuser) and new asset classes (email, network, cloud workloads, AI apps, backups, Knowledge store).
- Updated `docs/02-system-architecture.md` to add MAPE-K mapping section and the new core services (Self-Healing Controller, Knowledge Store, Rule Synthesiser, Federation Aggregator, BAS Orchestrator, Email/NDR/CWPP/LLM-FW/Hunting components).
- Updated `docs/08-roadmap.md` to add Phase 6 (autonomic GA), Phase 7 (domain expansion), Phase 8 (42 Berlin pilot, runs in parallel).
- Updated `docs/12-task-backlog.md` with Phase 5–8 tickets.
- Updated `README.md` pillar table (P1–P22).
- Updated `CLAUDE.md` hard rules: added autonomic-action bounding, rollback gating, federation Byzantine safety, BAS sandbox.

### Decisions made

- Product shape: **Complete XDR platform** (broad, native).
- Marquee: **AI-native + autonomic, equally weighted**.
- New pillars added: P15, P16, P17, P18, P19, P20, P21, P22.
- 42 Berlin: adapt now, target now.
- Autonomic safety: codified in ADR-0010 + ADR-0011; CI invariants ticketed (P6-T13).

### Open questions awaiting the project owner

- Sourcing: 42 Berlin direct contact (warm intro vs. cold email). Outreach template ready in `docs/16-42-berlin-outreach.md`.
- Hosting commitment for the EU control-plane region (Frankfurt vs. Berlin colocation if 42 wants on-prem).
- Are there any *other* coding schools / dev orgs to target alongside 42 (e.g. Le Wagon, Holberton) once 42 lands?
- Existing legal-review status on ADR-0009 is unchanged.

### What's next (priority order)

1. **Project owner**: warm-intro plan for 42 Berlin (or cold email) using the template in `docs/16-42-berlin-outreach.md`.
2. **Project owner**: confirm scope of Phase 7 — should P18, P19, P20, P21, P22 truly all build in Phase 7 in parallel, or sequence?
3. **Project owner / counsel**: legal review of ADR-0009 (still pending from session 1).
4. **Engineering** (when started): Phase 1 tickets in `docs/12-task-backlog.md` remain the entry point.
5. **Engineering**: Phase 8 (42 Berlin) tickets (P8-T01–T06) are designed to be doable in parallel with Phase 1.

### Files touched

- New: `docs/04-detection-pillars/p15..p22.md` (8), `docs/09-adr/0010..0011.md` (2), `docs/15-42-berlin-adaptation.md`, `docs/16-42-berlin-outreach.md`.
- Updated: `README.md`, `CLAUDE.md`, `docs/00-vision.md`, `docs/01-threat-model.md`, `docs/02-system-architecture.md`, `docs/08-roadmap.md`, `docs/12-task-backlog.md`, this file.
- Total: 12 new + 8 updated.

### Risks / things I'd flag

- **Scope risk is real.** We just doubled the surface. Phase 7 in parallel is ambitious; sequencing P18→P21→P19→P22→P20 (by user-visible value) is a defensible alternative.
- The autonomic loop is the most valuable and most dangerous addition. ADR-0010 / ADR-0011 must be enforced in code; CI invariant tickets (P6-T13) are non-negotiable.
- Federation poisoning is a real attack vector; Byzantine-robust aggregation alone is necessary but not sufficient — combine with per-tenant contribution caps and outlier quarantine.
- 42 Berlin will treat Artemis as a target. Plan for it: bug-bounty + CTF + a documented escalation path. Surprise findings are guaranteed; a process for them is mandatory.
- The data-collection commitments at 42 must be exact in writing. Misstating GDPR posture would end the partnership instantly.

---

## (Future sessions add entries below)

> Template:
>
> ```
> ## YYYY-MM-DD — Session N (Claude Code, model | human, name)
>
> ### What was done
> ...
> ### Decisions made
> ...
> ### Open questions
> ...
> ### What's next
> ...
> ### Files touched
> ...
> ### Risks / things I'd flag
> ...
> ```
