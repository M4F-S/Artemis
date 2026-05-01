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
