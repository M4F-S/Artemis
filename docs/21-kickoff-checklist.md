# 21 — Kickoff Checklist

Before the first commit lands on `main`, every box below should be ticked. This is the only gate between Phase 0 and Phase 1.

## Owner / business

- [ ] Legal review of ADR-0009 (Active Defense) returned, or a written "OK to start without P14 capabilities for now."
- [ ] At least one design partner committed in writing (signed MOU is fine; informal email is enough to *start*).
- [ ] Compensation model decided (paid / unpaid / hybrid) — affects CLA wording.
- [ ] Bank / company structure exists if money is going to flow (not blocking if Phase 1 is still volunteer).
- [ ] Cyber-liability insurance scoped (quote, not bound).

## Repo & access

- [ ] GitHub org or named repo decided; default-private until ADR-0008 closes.
- [ ] Branch protection on `main`: at least one review, signed commits, status checks required.
- [ ] CODEOWNERS file lists at least the tech lead.
- [ ] PR template merged.
- [ ] CI workflow files present (`.github/workflows/*.yml.tpl` made live).
- [ ] Secrets-scanning + dependency review enabled.
- [ ] Issue templates for bug / feature / ADR.

## Engineering bootstrap

- [ ] Workspace skeleton merged (`crates/` + `apps/` + `tests/` + manifests; no functional code yet).
- [ ] Devcontainer or nix flake reproduces a working build for any new contributor.
- [ ] `cargo fmt && cargo clippy -D warnings && cargo test --workspace` runs green on a fresh clone.
- [ ] Performance suite skeleton in `tests/perf/` (idle-budget test that future work cannot regress).
- [ ] `dev/agent.toml` sample config in repo.
- [ ] At least one canned synthetic event injected end-to-end through ingest in CI.

## Team

- [ ] Tech lead (R1) onboarded.
- [ ] At least 2 colleagues (R2 / R3) onboarded; signed CLAs (or contributor agreement).
- [ ] Console colleague (R4) onboarded if Phase 1 console UI is in scope this cycle.
- [ ] Internal communication channel set up (Slack / Discord / Matrix); standing 30-minute weekly sync.
- [ ] Each colleague has read [`CLAUDE.md`](../CLAUDE.md), [`CONTRIBUTING.md`](../CONTRIBUTING.md), [`docs/11-onboarding.md`](11-onboarding.md), the latest [`14-session-handoff.md`](14-session-handoff.md), [`17-engineering-bootstrap.md`](17-engineering-bootstrap.md), and [`20-definition-of-done.md`](20-definition-of-done.md).

## Docs

- [ ] All `docs/` cross-links work (markdown link checker green).
- [ ] Latest session-handoff entry reflects "Phase 1 kickoff" with explicit "what's next."
- [ ] Glossary covers any new acronym from the recent iteration.

## Cost / runway

- [ ] Cloud account + billing alerts set up.
- [ ] LLM-API account + per-tenant quota plan in place.
- [ ] Per-month burn estimated (`docs/19-cost-model.md`); runway is ≥ 9 months.

## 42 Berlin (only if pursuing in parallel)

- [ ] Outreach plan in `docs/16-42-berlin-outreach.md` reviewed and personalised.
- [ ] First contact attempted; reply (yes / no / not yet) recorded.
- [ ] 42 cursus intent-template pack ticket (P8-T01) assigned to a colleague.
- [ ] DPIA draft begun.

## Apollo (only if starting in parallel)

- [ ] Decision recorded: do we start the Apollo repo now (Phase 6 work brought forward in spec only) or wait?
- [ ] If now: separate repo created (`m4f-s/apollo`); ADR-0012 committed; access locked to red-team engineer + tech lead.
- [ ] No Apollo dependencies pulled into Artemis product crates.

## "Are we ready?" signal

If every box above is ticked: **start Phase 1**. Pull `P1-T00` (repo bootstrap) and let the team self-assign downstream tickets. Run a 30-minute kickoff call — agenda: the goal of Phase 1, the DoD (`docs/20-definition-of-done.md`), the comm cadence.

If two or more boxes are unticked: **pause, fix, then start.** The cost of a 1-week delay is negligible compared to the cost of starting on a wobbly foundation.
