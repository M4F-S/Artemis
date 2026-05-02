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

---

## 2026-05-01 — Session 3 (Claude Code, opus-4-7)

### What was done

- **Implementation-readiness pack** added (5 docs):
  - `docs/17-engineering-bootstrap.md` — workspace layout, devcontainer/nix flake, build/test, branching, code style, secrets.
  - `docs/18-team-and-headcount.md` — concrete answer to "how many colleagues?" + role profiles R1–R10 + hiring sequence.
  - `docs/19-cost-model.md` — Phase 1–4 monthly burn (~$1.1k/mo at start, scaling to ~$5k/mo by Phase 4) + people cost ranges.
  - `docs/20-definition-of-done.md` — observable per-phase exit criteria with cross-cutting always-green list.
  - `docs/21-kickoff-checklist.md` — single-page gate before first commit.
- **Apollo offensive testing companion** designed and documented:
  - `docs/22-apollo-offensive-companion.md` — what Apollo is, what it isn't, scope, capabilities, repo layout.
  - `docs/09-adr/0012-apollo-scope.md` — separate-repo isolation, target-allowlist enforcement at three layers, no-novel-attack-synthesis bound, future-SKU gating per jurisdiction (US ECCN / EU Dual-Use 2021/821 / Wassenaar / pen-testing licences).
  - Owner decision recorded: "Internal lab + future SKU for advanced customers."
- **Active Defense tier ladder** added:
  - `docs/09-adr/0013-active-defense-tiers.md` — Tier 0–5 ladder; NacConnector trait; reversibility / multi-signal / rate-limit / cancel-window contract.
  - `docs/04-detection-pillars/p14-active-defense.md` rewritten around tiers; capability G (NAC) added; capabilities A–F mapped to tiers.
  - Owner decision recorded: NAC v0 connector = FreeRADIUS + 802.1X reference. UniFi + pfSense in Phase 6.
- **42 Berlin Tier 4/5 flow** added in `docs/15-42-berlin-adaptation.md` (network-block + escalate-to-administration with default authority chains and 60-second cancel).
- **GitHub config skeletons** added: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/CODEOWNERS`, `.github/workflows/ci.yml.tpl`, `.github/workflows/security.yml.tpl`. Templates include hard-rules-scan and Apollo-isolation invariants.
- **Cross-cutting updates**:
  - `README.md` — links the implementation-readiness pack + Apollo doc + 42 docs.
  - `CLAUDE.md` — adds Hard Rules #11 (Apollo isolation) and #12 (P14 tier-ladder safety).
  - `docs/01-threat-model.md` — adds threat tables for Tier-4 NAC abuse, NAC connector layer, Apollo, and the autonomic loop (T6 surface).
  - `docs/02-system-architecture.md` — alert-path now references tiers; Apollo box added.
  - `docs/08-roadmap.md` — Phase 5 adds Tier 0–3 + NAC v0; Phase 6 adds Apollo Phase 1 + UniFi/pfSense.
  - `docs/12-task-backlog.md` — Phase-0 expanded (P0-T08 kickoff checklist, P0-T09 42 outreach); Phase-1 P1-T00 added; Phase-5 expanded with tier + NAC + Apollo seed (P5-T09–T13); Phase-6 expanded with Apollo bootstrap + connectors (P6-T14–T18).

### Decisions made (this session)

- **Product/scope**: Complete XDR is locked from session 2; this session converts it into actionable Phase-5–8 tickets.
- **Apollo**: Internal lab + future SKU. Separate repo (`m4f-s/apollo`). Per-SKU legal gate captured in ADR-0012.
- **NAC v0 vendor**: FreeRADIUS + 802.1X. Generic `NacConnector` trait; vendor-specific implementations layered later.
- **Headcount**: 4–5 colleagues for Phase 1 comfortable; 2 minimum + you. ~10 from school by end of Year 2.
- **Autonomic safety contract** ([ADR-0010](09-adr/0010-autonomic-safety.md)) and **rollback safety** ([ADR-0011](09-adr/0011-self-healing-rollback.md)) extended to cover Tier 4/5 (ADR-0013).

### Open questions awaiting the project owner

1. Legal review of ADR-0009 + ADR-0012 + ADR-0013 + P14 + threat model is the critical-path blocker for any P14 unlock.
2. Compensation model (paid / unpaid / hybrid) for school colleagues — affects ADR-0008 (licensing) and CLA wording.
3. Specific 42 Berlin contact + warm intro path (cold-email template ready in `docs/16-42-berlin-outreach.md`).
4. Hosting / cloud-provider commitment (default proposal: GCP primary, AWS secondary; not yet ratified).
5. Apollo opening signal: when do we authorise a red-team engineer to start the `m4f-s/apollo` repo?

### What's next (priority order)

1. **Project owner**: send the 42-Berlin pitch (template in `docs/16-42-berlin-outreach.md`). If they say yes, even informally, start a working channel.
2. **Project owner**: convert legal review into a written reply on ADR-0009 / 0012 / 0013.
3. **Project owner + tech lead**: run the kickoff checklist (`docs/21-kickoff-checklist.md`) end-to-end. If green, pull `P1-T00`.
4. **Tech lead** (when on board): land workspace skeleton (`P1-T00`, `P1-T01`); rename CI templates to live; merge first canary CI run.
5. **Detection author** (when on board): begin Apollo seed scenarios (`P5-T13`) part-time; doesn't block Phase 1.

### Files touched

- New (10): `docs/17-21`, `docs/22`, `docs/09-adr/0012`, `docs/09-adr/0013`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/CODEOWNERS`, `.github/workflows/ci.yml.tpl`, `.github/workflows/security.yml.tpl`.
- Updated (8): `README.md`, `CLAUDE.md`, `docs/01-threat-model.md`, `docs/02-system-architecture.md`, `docs/04-detection-pillars/p14-active-defense.md`, `docs/08-roadmap.md`, `docs/12-task-backlog.md`, `docs/15-42-berlin-adaptation.md`, this file.
- Total: 10 new + 9 updated.

### Risks / things I'd flag

- **Phase 7 in parallel is genuinely hard.** With 5 domain tracks (P18–P22), even at full headcount, sequencing might be safer. Defensible alternative: P18 → P21 → P19 → P22 → P20 by user-visible value. Locked in as a Phase-7 decision once we see Phase-6 throughput.
- **Apollo timing.** Starting the Apollo repo too early dilutes Phase-1 focus. ADR-0012 lets it start in Phase 6, with seed scenarios (P5-T13) part-time before then. Resist pulling Apollo forward.
- **NAC compatibility surprises.** FreeRADIUS reference will work; vendor-specific quirks (Cisco ISE CoA timing, UniFi controller versioning, Aruba ClearPass cluster behaviour) will require vendor-by-vendor empirical validation. Budget time per connector.
- **42 onboarding requires DPIA effort.** The DPIA is real legal work, not a checkbox. Allocate someone with German privacy-law literacy or counsel.
- **The hard-rules CI scan is necessary but insufficient.** It catches obvious patterns; sophisticated bypasses still possible. Backstop with code review by the tech lead on every privileged-path PR.

---

## 2026-05-01 — Session 4 (Claude Code, opus-4-7) — Implementation-readiness audit

### What was done

End-to-end audit of the repo (65 files including this entry's adds), verified pillar-vs-roadmap-vs-backlog cross-coverage, ADR completeness, and cross-link sanity. Found and fixed gaps blocking parallel implementation sessions:

- **`docs/23-parallel-sessions.md`** — full workstream protocol: 8 streams (WS-A through WS-H), file ownership rules, dependency graph, branching protocol, daily handoff template, coordinator playbook references.
- **`docs/24-first-pr.md`** — concrete WS-A bootstrap PR scope: every file added, CI gates that must pass, acceptance checklist, what unblocks downstream.
- **`docs/25-dev-runbook.md`** — clone → running agent in three paths (devcontainer, nix flake, manual); end-to-end verification steps; common-issues table.
- **`samples/`** — concrete reference artefacts for the first PR:
  - `samples/event.proto` — OTLP-shaped event schema with example payloads.
  - `samples/rule.example.yaml` — the eBPF-untrusted-loader rule with positive + negative tests.
  - `samples/agent.toml.example` — full dev-profile agent config.
- **`docs/session-prompts/`** — paste-ready prompts for parallel Claude Code sessions:
  - `ws-a-tech-lead.md`
  - `ws-b-sensor-linux.md`
  - `ws-c-daemon-rules.md`
  - `ws-d-control-plane.md`
  - `ws-e-console.md`
  - `ws-f-detection.md`
  - `ws-g-llm-malware.md`
  - `ws-h-hardening.md`
  - `coordinator-playbook.md` (for the human owner; not pasted into a session).
- **`docs/10-glossary.md`** — extended with all terms introduced in sessions 2–4 (Apollo, NAC, NacConnector, MAPE-K, T6, Tier 0–5, RuleGenie/RulePilot, JA4, EAP-TLS, ML-DSA, SLH-DSA, ATLAS, BAS, NDR, CWPP, DFIR, DPIA, RL, SLSA, Caldera, EU Dual-Use Regulation 2021/821, Wassenaar, WS-A…H, 802.1X, RADIUS).
- **`README.md`** — links the new docs (23, 24, 25, session-prompts, samples).
- **`CLAUDE.md`** — references the parallel-session protocol so any future session knows the file-ownership and branch rules.

### Audit findings (no further action required)

- All 22 pillars referenced in both roadmap and task-backlog.
- All 13 ADRs present, consistent.
- No orphaned cross-links (false positives in the auto-checker; manual sample-check confirms).
- Hard-rules CI invariants documented and ready to activate when CI templates are renamed live.
- File-ownership rules cleanly separate the workstreams; the only natural coupling point is the shared event schema (handled by an explicit schema-evolution protocol).

### Decisions made (this session)

- Phase 1 is divided into 8 parallel workstreams, with WS-A as the only hard precondition.
- Eight session-prompt files are the durable artefacts that let the owner spin up parallel Claude Code sessions confidently.
- The shared event schema is the chief coordination artefact; changes to it follow an explicit cross-stream protocol.

### Open questions awaiting the project owner (status snapshot)

1. Legal review of ADR-0009 + ADR-0012 + ADR-0013 + P14 + threat model — *waiting (owner-noted)*.
2. 42 Berlin pitch — *owner will send when ready (owner-noted)*.
3. Recruitment — *owner will pursue when implementation starts (owner-noted)*.
4. Compensation model — *deferred*.
5. Hosting / cloud-provider commitment — *deferred*.
6. License decision (ADR-0008) — *deferred to end of Phase 1*.

### What's next

This session's deliverable concludes the spec stage. The repo is **implementation-ready**.

When the owner signals "go", the very first action is to run the Phase-1 kickoff:
1. Owner runs `docs/21-kickoff-checklist.md` end-to-end.
2. Owner pastes `docs/session-prompts/ws-a-tech-lead.md` into a Claude Code session.
3. WS-A produces the bootstrap PR per `docs/24-first-pr.md`.
4. Once merged, owner spins WS-B, WS-D, and WS-F in parallel using their prompts.
5. Coordinator playbook (`docs/session-prompts/coordinator-playbook.md`) drives the daily cadence.

Subsequent sessions inherit context via this handoff log; no oral history needed.

### Files touched

- New (15): `docs/23-25` (3), `samples/event.proto`, `samples/rule.example.yaml`, `samples/agent.toml.example`, `docs/session-prompts/{ws-a..h, coordinator-playbook}.md` (9).
- Updated (3): `README.md`, `CLAUDE.md`, `docs/10-glossary.md`, this file.
- Total: 15 new + 4 updated.

### Risks / things I'd flag

- **Coordination overhead is real.** Parallel sessions amplify both throughput and risk. Run 2–3 in parallel before scaling to 5+; tune the cadence as you go.
- **Tired coordination is dangerous.** When in doubt, pause sessions rather than guess; the cost of pause is minutes; the cost of bad merge is days.
- **The sample artefacts in `samples/` are illustrative, not production.** Do not import them into crates verbatim; treat them as design anchors that the corresponding session re-creates inside the proper crate.
- **Shared event-schema discipline is critical.** A single careless mutation will cascade across WS-B, WS-C, WS-D. The schema-evolution protocol (in WS-C and WS-B prompts) must be followed.

---

## 2026-05-01 — Session 5 (Claude Code, opus-4-7) — Second-pass gap fix

### What was done

Owner-requested second review of the entire repo for vagueness, missing technical detail, and contradictions. Found 8 real implementation gaps (no contradictions in the spec); fixed all.

**New samples (5 files):**
- `samples/control_plane.proto` — gRPC service definitions: `EnrollmentService`, `IngestService` (bidirectional stream + `IngestAck` with `OK`/`RETRY`/`REJECT`/`THROTTLE` and `backoff_hint_ms`), `KnowledgeService` (signed manifest + chunked download). Was missing entirely.
- `samples/migrations/postgres_001_init.sql` — illustrative per-tenant Postgres schema: `devices`, `admins`, `authority_chains`, `active_defense_policy`, `intent_sessions`, `identity_sources`, `audit_log` (hash-chained), `knowledge_pins`, `honeytoken_hits`. Per ADR-0006 (schema-per-tenant).
- `samples/migrations/clickhouse_001_init.sql` — illustrative per-tenant ClickHouse schema: `events` table with TTL + cold-tier storage, materialised view, `alerts`, `bas_runs`, `federation_ledger`. Per ADR-0006 (DB-per-tenant).
- `samples/cli-commands.md` — `artemis` CLI command surface contract (status, enroll, intent, rules, alerts, decoy, ad, doctor, version) with exit-code semantics. Was missing.
- `samples/console-api.openapi.yaml` — REST API surface for the console: alerts, incidents, devices, identities, rules (incl. proposed rules from P16 LLM synthesiser), active-defense policy, reporting, federation. Was missing.

**New docs (3 files):**
- `docs/26-customer-lifecycle.md` — Discovery → trial → onboarding → steady-state → change events → offboarding. Concrete day-by-day plan, exit criteria, GDPR right-to-erasure handling, signed offboarding receipt.
- `docs/27-internal-incident-response.md` — What we do when Artemis itself is the target. SEV classes, on-call structure, response phases, signing-key compromise + cross-tenant leak + Apollo compromise runbooks, customer comms matrix, drills, hard rules.
- `docs/28-versioning-and-compatibility.md` — SemVer; agent↔control-plane N–2 compat with 90-day deprecation; knowledge bundle versioning + pinning; event/alert/provenance/Postgres/ClickHouse schema-evolution rules; expand-contract migration pattern.

**Tightened existing docs (4 files):**
- `docs/05-data-model.md` — added Time/ordering/clock-skew section (sensor `ts` + control-plane `ingest_ts`, hash-chained per-device sequence, Lamport-style cross-device ordering, drift-detect events). Added schema-evolution protocol summary linking to doc 28. Added Wire-level reliability section (gRPC retry/backoff base 250ms cap 60s, idempotency via `batch_id`, encrypted SQLite spool with overflow handling, backpressure on `THROTTLE`). Added Federation participation contract.
- `docs/06-control-plane.md` — replaced vague rate-limit paragraph with a concrete per-tier table (Trial/Standard/Plus/MDR with events/sec, LLM tokens/mo, NAC actions/5min, Tier-5 reports/day). Expanded internal observability (Tempo+Mimir+Loki stack, SLO list with 6 targets, distributed tracing via OTel baggage, "we use Artemis on Artemis"). Expanded DR with quarterly drill cadence + annual signing-key recovery drill.
- `docs/25-dev-runbook.md` — fixed missing `cp samples/agent.toml.example dev/agent.toml` step.
- `README.md` — links the new docs (26, 27, 28) and updated samples list.

### Audit confirmed (no action needed)

- Phase timeline consistent across `08-roadmap.md` and `12-task-backlog.md` (10/8/8/8/8/10/16 weeks).
- LLM provider strategy consistent: Anthropic primary in P5 doc and ADR-0005.
- All 22 pillars referenced in roadmap + backlog.
- All 13 ADRs present and consistent.
- Cross-link sanity confirmed manually (the "broken link" auto-checker false-positives because relative paths from `docs/04-detection-pillars/` resolve correctly).

### Decisions made (this session)

- Concrete rate-limit numbers per tenant tier locked in `docs/06-control-plane.md`.
- Wire-level reliability contract locked in `docs/05-data-model.md` (retry policy, spool behaviour, idempotency).
- Time/clock model locked: dual-timestamp + hash-chain sequence + Lamport-style cross-device.
- Customer lifecycle stages and offboarding receipt format locked in `docs/26-customer-lifecycle.md`.
- Internal IR structure (SEV classes + on-call escalation) locked in `docs/27-internal-incident-response.md`.
- SemVer + schema-evolution rules + 90-day deprecation cycle locked in `docs/28-versioning-and-compatibility.md`.

### Open questions (unchanged from session 4)

1. Legal review of ADR-0009 / ADR-0012 / ADR-0013 + P14 + threat model — owner waiting.
2. 42 Berlin pitch — owner will send when implementation starts.
3. Recruitment — owner will pursue when implementation starts.
4. Compensation model — deferred.
5. Hosting / cloud-provider commitment — deferred.
6. License decision (ADR-0008) — deferred to end of Phase 1.

### What's next

Repo is now **production-ready for parallel implementation sessions** by every objective gate I can think of. When the owner signals "go":

1. Owner runs `docs/21-kickoff-checklist.md`.
2. Owner pastes `docs/session-prompts/ws-a-tech-lead.md` into a Claude Code session.
3. WS-A produces the bootstrap PR per `docs/24-first-pr.md` (using contracts in `samples/` as anchors).
4. Then WS-B + WS-D + WS-F open in parallel.

### Files touched

- New (8): `samples/control_plane.proto`, `samples/migrations/postgres_001_init.sql`, `samples/migrations/clickhouse_001_init.sql`, `samples/cli-commands.md`, `samples/console-api.openapi.yaml`, `docs/26-customer-lifecycle.md`, `docs/27-internal-incident-response.md`, `docs/28-versioning-and-compatibility.md`.
- Updated (5): `docs/05-data-model.md`, `docs/06-control-plane.md`, `docs/25-dev-runbook.md`, `README.md`, this file.
- Total: 8 new + 5 updated.

### Risks / things I'd flag

- **Sample artefacts grow.** Be disciplined: `samples/` is a design-anchor showcase, not a lib. The corresponding workstream re-creates them inside its crate; the samples themselves never get imported.
- **Schema-evolution discipline is a culture thing.** The protocol is documented; whether the team follows it depends on tech-lead enforcement during reviews.
- **Internal-IR runbooks need real practice, not just docs.** Tabletop exercise quarterly is a hard rule in `docs/27-internal-incident-response.md`; first one should be Phase 5 ops work.
- **Versioning doc commits us to N–2 compatibility.** That is a real engineering tax. Worth it for customer trust; track the cost.
- **Tier-rate-limit numbers in `docs/06-control-plane.md` are guesses.** Re-tune from production telemetry after Phase 1 design-partner exposure.

---

## 2026-05-01 — Session 6 (Claude Code, opus-4-7) — Senior auditor pass

### What was done

Acted as a senior technical auditor / advisor. Reviewed the entire spec against the latest research and against what an experienced security architect would catch. Found **no contradictions** but **8 critical issues**, **9 important issues**, and **12 research-driven improvements**. Critical issues remediated in this commit; important + research items tracked in a new backlog.

**New audit document:**
- `docs/29-senior-audit.md` — full audit memo: what's working, 8 critical issues with severity rationale, 9 important issues, 12 research items, 9 minor inconsistencies, recommended next sequence, and a green-with-conditions verdict.

**New ADRs (4) addressing the critical issues:**
- ADR-0014 federation-security: multi-layered scheme (per-contributor magnitude bound + coordinate-wise trimmed median + validator weighting + outlier quarantine + round-key freshness + central DP) with explicit threat model and pause conditions. Supersedes the prior hand-wavy "Byzantine-robust" reference in ADR-0010.
- ADR-0015 signing-key-management: HSM-backed root of trust, threshold signing (2-of-3 / 3-of-5), Sigstore-style transparency, annual rotation, offline root, public log. Replaces the implicit signing story.
- ADR-0016 update-channel-security: two-party update consent, TUF metadata roles, Sigstore transparency, phased canary→stable rollout, watchdog auto-rollback, threat-model coverage. New, was missing.
- ADR-0017 hard-rules-enforcement: layered enforcement (capability allowlist + AST analysis + two-reviewer rule + sandboxed tests + runtime self-audit) replacing grep-only as the canonical control. Per-rule enforcement matrix.
- ADR-0018 pmf-gate: hard PMF gate at end of Phase 4 (≥3 design partners × 25 endpoints × 60 days, ≥1 paying or LOI, NPS ≥ 30, ≥80% identify essential feature). Prevents Phase 5+ feature work without market validation.

**Tightened existing docs (3):**
- P8 (cert-robust ML) — honest-framing section added; "certified" specifically means "bounded perturbation norm + small radius"; UI shows radius numerically; marketing must not abbreviate.
- P15 (self-healing) — S5 scope downgraded from "decentralised mesh fallback" to "graceful cloud-outage degradation" (no agent-to-agent coordination). Original ambitious version moved to post-Phase-7 R&D.
- 00-vision — added "Honest framing" section listing the bounded claims.

**New research backlog:**
- `docs/30-research-backlog.md` — 12 research items (R1–R12) covering EU CRA + AI Act + DORA, Rust-for-Linux, confidential AI inference, DSPy/LMQL, NIST AI RMF, OCSF version pin, Hypershield watch, classifier sandwiches, Constitutional AI, doc versioning, SBOM, cargo-deny — plus 9 important items (I1–I9) from the audit. Each with what / why / when / owner.

### Decisions made

- Federation security threat model and limits explicit (ADR-0014).
- Signing-key model uses HSM + threshold + Sigstore transparency (ADR-0015).
- Update channel uses TUF + transparency + phased rollout + watchdog rollback (ADR-0016).
- Hard rules enforced at runtime + AST + review + tests + self-audit, not grep (ADR-0017).
- PMF gate inserted between Phase 4 and Phase 5 (ADR-0018).
- "Certified-robust ML" is qualified everywhere; UI surfaces the radius.
- "Self-healing mesh fallback" is descoped; current spec is graceful degradation only.

### What this means for Phase 1

The new ADRs add concrete CI invariants that WS-A must wire in (cargo-deny config, Semgrep ruleset, capability-allowlist test, transparency-log scaffold). Tracked in WS-A's bootstrap PR. The PMF gate is calendar-distant but informs design-partner conversations from Phase 0.

### Open questions (status)

1. Legal review of ADR-0009 / ADR-0012 / ADR-0013 — owner waiting.
2. ADR-0014 / ADR-0015 / ADR-0016 / ADR-0017 / ADR-0018 also benefit from counsel review; flag at next legal sync.
3. 42 Berlin pitch — owner will send when implementation starts; ALSO: pair 42 with a *paying* EU design partner (audit issue M1).
4. Recruitment — owner will pursue when implementation starts.
5. Compensation, hosting, license — deferred.
6. PMF survey vendor — to be contracted by Phase 3 (per ADR-0018).

### What's next

Repo is **green-with-conditions ready** for parallel implementation sessions:
1. Owner runs `docs/21-kickoff-checklist.md`.
2. WS-A bootstrap PR (per `docs/24-first-pr.md`) + wires in ADR-0014–0018 CI invariants.
3. WS-B + WS-D + WS-F begin in parallel.
4. Phase 1 includes the I7 (intent UX validation) sprint.
5. SBOM generation in CI from PR #1 (per R11 in research backlog).

### Files touched

- New (6): `docs/29-senior-audit.md`, `docs/30-research-backlog.md`, `docs/09-adr/0014-federation-security.md`, `docs/09-adr/0015-signing-key-management.md`, `docs/09-adr/0016-update-channel-security.md`, `docs/09-adr/0017-hard-rules-enforcement.md`, `docs/09-adr/0018-pmf-gate.md`. (Audit doc + 5 ADRs + research backlog = 7. Counted as 6 above by mistake — actual 7.)
- Updated (4): `docs/04-detection-pillars/p8-certified-ml.md`, `docs/04-detection-pillars/p15-self-healing.md`, `docs/00-vision.md`, `README.md`, this file.
- Total: 7 new + 5 updated.

### Risks / things I'd flag

- **The audit found weaknesses; remediations add real engineering tax.** HSM + threshold signing + Sigstore + Semgrep + capability-allowlist all add operational and CI cost. Worth it; track the cost.
- **PMF gate is psychologically hard to honour.** When Phase 4 ends and morale wants to push into Phase 5, the gate becomes pressure. Make sure the survey vendor is contracted and the conversion conversation starts at Phase 2.
- **Honest framing is a discipline.** Marketing will pull toward unhedged claims. Keep ADR-0017's two-reviewer rule applied to customer-facing claims as well.
- **Apollo + future SKU exposure is real.** Even though we've designed the legal/dual-use posture carefully, Wassenaar / EU 2021/821 obligations grow as the SKU launches; counsel-on-retainer (not just one-off review) is the right answer.
- **Two safety-contract ADRs (0014 + 0015) lean heavily on threshold cryptography.** The threshold-ECDSA / threshold-ML-DSA implementations are not yet stable in the open-source Rust ecosystem; we may need to pay for a vendor (Fireblocks, etc.) or accept a single-key scheme for early phases. Track this as ad-hoc tickets, don't defer silently.

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
