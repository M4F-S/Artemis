# 20 — Definition of Done

Per-phase exit criteria. If a row is not green, the phase is not done. No exceptions; no "we'll fix it next phase."

## Phase 1 — Linux MVP

- [ ] `cargo fmt --check && cargo clippy -D warnings && cargo test --workspace` passes on every PR.
- [ ] CI matrix green on Ubuntu 22.04 + 24.04 with kernels 5.15 / 6.1 / 6.6 / 6.12.
- [ ] Linux sensor: ≥ 4 LSM hooks live (`bpf`, `bprm_check_security`, `file_open`, `socket_connect`).
- [ ] Userland daemon emits OTLP events to a stub ingest with mTLS.
- [ ] Rule pack v0: ≥ 20 rules; ≥ 95% precision on labelled corpus; ≥ 0 alerts on a clean kernel build + npm install + video render.
- [ ] Endpoint deception (P3): canary placement working; tripwire fires within 1 s.
- [ ] LLM-fed-malware heuristic (P1.1): synthetic MalTerminal-style stub triggers HIGH; false positives = 0 on clean dev workflow corpus.
- [ ] Intent sessions (P4): CLI works; tampering detected; "out of intent" rules fire as designed.
- [ ] Control plane MVP: ingest, ClickHouse, detection engine, console v0 alert list — all running, talking to each other.
- [ ] Performance budget: < 2% CPU sustained, < 150 MB RAM, < 50 MB/day net at idle.
- [ ] At least one design partner has Artemis on ≥ 10 hosts for ≥ 2 weeks; collected feedback documented.
- [ ] All Phase-1 tickets closed or explicitly deferred to Phase 2 in the backlog.
- [ ] Threat-model deltas reviewed; ADR drafts opened where necessary.

## Phase 2 — Windows + LLM copilot

- [ ] Windows agent: ETW consumer + minifilter driver + AMSI provider all running and emitting OTLP.
- [ ] Defender coexistence: Artemis registered as 3rd-party AV via WSC; no double-scanning regressions.
- [ ] LLM copilot (P5): plain-English narrative on every alert; citation discipline enforced (every claim references an event ID); JSON-schema-validated output.
- [ ] Weekly executive PDF generates and renders for ≥ 3 design partners.
- [ ] TPM enrolment + Secure Boot status posted at agent enrolment for ≥ 90% of Win machines.
- [ ] Entra connector: sign-in events flow into the provenance graph; first ITDR rule fires correctly.
- [ ] Performance budget met on Windows.
- [ ] Authenticode + ML-DSA double-signing on Windows installer.

## Phase 3 — macOS + browser + privacy

- [ ] macOS agent notarised; Endpoint Security entitlement approved.
- [ ] Browser extension published in Chrome / Edge / Firefox stores; native messaging end-to-end.
- [ ] DOM prompt-injection patterns detected on a curated corpus of injection-bait pages.
- [ ] Differential-privacy egress filter on by default; ε budget reporting in console.
- [ ] Provenance graph (P7) general availability: incident page renders with sub-graph + LLM narrative + citations.
- [ ] Performance budget met on macOS.

## Phase 4 — Hardening + robust ML

- [ ] DRSM-style smoothed classifier shipped; certified-radius reported per prediction; UI distinguishes certified vs. uncertified verdicts.
- [ ] Federated IoC: ≥ 3 tenants opted in; CKKS aggregation produces a usable nightly model update.
- [ ] CFI policy enforcement: tenants can opt-in to block non-CFI binaries; legacy allowlist works.
- [ ] Okta + Google Workspace connectors live; ITDR fusion rules cover top-5 identity-attack patterns.
- [ ] Supply-chain runtime guard: install-time hooks for `npm`, `pip`, `cargo install` working; sandbox detects red-flag behaviours.
- [ ] SOC 2 + ISO 27001 evidence export produces auditor-ready bundle for ≥ 1 design partner.
- [ ] Annual external pen-test passed (no Critical findings open).

## Phase 5 — Active Defense + autonomic foundation

- [ ] P14 capabilities A–E shipped, locked off; ADR-0009 + ADR-0013 enforced in CI invariants.
- [ ] P14 Tier 0–3 working with an operator click; Tier 4 (NAC) connector for FreeRADIUS reference target validated; Tier 5 (escalate-to-authority) report-generation pipeline tested.
- [ ] P15.S1: agent self-protection + cloud watchdog re-deploy works in chaos tests (kill agent → re-injected within < 60 s).
- [ ] P15.S2: snapshot + manual-rollback works on Btrfs / ZFS / VSS for ≥ 1 sample workload.
- [ ] PQ signing in code-update pipeline (ML-DSA + Ed25519 hybrid).
- [ ] Knowledge store skeleton: signed manifests; rollbacks atomic.
- [ ] LLM rule synthesiser: review-queue UI working; 1 rule has shipped via this pipeline.
- [ ] ADR-0010 + ADR-0011 + ADR-0013 CI invariants merged and gating.

## Phase 6 — Autonomic loop GA + Apollo Phase 1

- [ ] P15 fully shipped (S1–S6); auto-rollback tested in lab against curated ransomware family without false-positive auto-rollback events.
- [ ] P16 fully shipped: online ML, Byzantine-robust aggregation, RL response (safety-bounded), operator-feedback FPR tuning, attack-graph mining.
- [ ] P17 BAS: 50 ATT&CK techniques in curated library; nightly canary runs; gap-to-rule pipeline closes ≥ 5 gaps in the quarter.
- [ ] Apollo: separate repo populated; lab-only enforcement passes red-team review; first 10 scenarios run successfully against Artemis lab fleet; ADR-0012 enforced in code (target allowlist).
- [ ] Tier-4 NAC connector working against pfSense + UniFi reference targets in addition to FreeRADIUS.
- [ ] 30-day tenant run with autonomic loop on; zero false rollbacks; measurable rule-quality lift documented.

## Phase 7 — Domain expansion

Per-domain DoD; each track exits independently:

- [ ] **P18 Email:** API-mode connectors for M365 + Workspace; URL detonation + attachment microVM; identity-coupled phishing detection working; 1 BEC scenario caught end-to-end.
- [ ] **P19 NDR:** endpoint co-sensor mode shipped; tap/SPAN appliance MVP deployed at ≥ 1 design partner; lateral movement scenario detected end-to-end.
- [ ] **P20 CWPP:** container annotation + K8s admission webhook + image scanner integrated; container-escape scenario detected.
- [ ] **P21 LLM firewall:** sidecar + SDK shim + standalone gateway shipped; prompt-injection scenario blocked; sensitive-data egress filter blocks PII in 95%+ of test corpus.
- [ ] **P22 Hunting+DFIR+Backup:** notebook UI; IR runbook engine with ≥ 5 runbooks; Veeam + AWS Backup connectors; restore test runs nightly on ≥ 1 design partner.

## Phase 8 — 42 Berlin pilot

- [ ] 42 cursus intent-template pack loaded; false-positive rate on a 7-day student-workload corpus < 1 alert per student per week.
- [ ] BYOD per-user enrolment flow signed off by 42 IT lead.
- [ ] DPIA template package shipped; counsel review noted.
- [ ] First "Break Artemis" CTF event held; ≥ 5 student submissions; ≥ 1 finding reproduced and a rule shipped via P16.
- [ ] 42 IT lead has used the platform unprompted for ≥ 1 real incident triage.

## Cross-cutting (always green)

- [ ] No CFAA / CMA / NIS2-violating code anywhere in the repo (CI scan).
- [ ] No collection of document content, clipboard, or keystrokes anywhere.
- [ ] All cross-tenant code paths reviewed by ≥ 2 humans.
- [ ] All `unsafe` Rust blocks justified in comments and reviewed by tech lead.
- [ ] No `// TODO: legal` comments unresolved at phase exit.
