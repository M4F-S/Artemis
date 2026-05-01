# 12 — Task Backlog

Actionable tickets organised by roadmap phase. Each ticket has a stable ID (e.g. `P1-T03`), an owner type, an estimate, dependencies, and acceptance criteria. Pick from the top of a phase; don't skip ahead unless the ticket is marked `parallel`.

Status legend: ☐ open · ◐ in progress · ☑ done · ✗ blocked.

---

## Phase 0 — Spec lock (current)

| ID | Title | Owner | Est | Deps | Status |
|---|---|---|---|---|---|
| P0-T01 | Capture spec in repo | Claude | 1 d | — | ☑ |
| P0-T02 | Hand legal docs (ADR-0009 + P14 + threat model) to security counsel | Project owner | external | P0-T01 | ◐ awaiting reply |
| P0-T03 | Identify 2 design-partner SMB candidates (1 US, 1 EU) | Project owner | 2 wk | — | ☐ |
| P0-T04 | Recruit founding engineers / colleagues | Project owner | 2 wk | — | ☐ |
| P0-T05 | Stand up GitHub repo, CI scaffolding (no code yet) | Any contributor | 1 d | P0-T04 | ☐ |
| P0-T06 | External advisor reviews threat model | External | external | P0-T01 | ☐ |
| P0-T07 | Draft contributor CLA (link from CONTRIBUTING.md) | Project owner + counsel | 1 wk | P0-T02 | ☐ |

**Phase-0 exit criteria:** P0-T02 returned, ≥1 design partner signed, ≥2 contributors lined up, CI scaffolding in place.

---

## Phase 1 — Linux MVP (≈ 10 weeks)

### 1.A — Repository scaffolding

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T01 | Workspace layout: `crates/artemis-core`, `crates/artemis-agentd`, `crates/artemis-bpf`, `crates/artemis-cli`, `crates/artemis-rules` | 1 d | — | `cargo build` succeeds; `cargo clippy -D warnings` clean |
| P1-T02 | CI: lint, build, test matrix (Ubuntu 22.04 + 24.04, kernels 5.15/6.1/6.6/6.12) | 1 d | P1-T01 | green pipeline on push |
| P1-T03 | `.github/workflows/security.yml`: cargo-audit, supply-chain SLSA build attestations | 1 d | P1-T02 | attestations published as artefacts |

### 1.B — Linux sensor (eBPF substrate, P2)

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T10 | Bootstrap aya project; load a no-op LSM hook | 2 d | P1-T01 | program loads on supported kernels; CO-RE works |
| P1-T11 | LSM hook on `bpf` syscall — capture program-load events | 2 d | P1-T10 | event emitted with loader PID + program type |
| P1-T12 | LSM hook on `bprm_check_security` — exec events | 1 d | P1-T10 | event emitted with parent chain |
| P1-T13 | Tracepoints `sched_process_exec/exit`, `tcp_connect` | 2 d | P1-T10 | events deduplicated against LSM events |
| P1-T14 | Userland daemon: ring-buffer consumer → in-memory event bus | 3 d | P1-T11 | <0.1% drop under stress-ng workload |
| P1-T15 | OTLP gRPC client; mTLS to a stub ingest | 2 d | P1-T14 | events visible in stub server |

### 1.C — Rule engine + canonical rules

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T20 | Falco-style YAML rule schema + parser | 2 d | P1-T01 | schema validation + golden-file tests |
| P1-T21 | Wasm rule sandbox (rules compiled to Wasm at load) | 4 d | P1-T20 | sample rule fires on synthetic event |
| P1-T22 | Rule pack v0: 20 rules across kernel, exec, net | 3 d | P1-T21 | 95% precision on labelled corpus |

### 1.D — Endpoint deception (P3)

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T30 | Canary placer: `~/.aws`, `~/.ssh`, `~/.kube`, `~/Documents/passwords.txt`, fingerprint-randomised | 3 d | P1-T11 | placement is per-host unique; rotation working |
| P1-T31 | Tripwire: eBPF `file_open` + alert on canary path | 2 d | P1-T30 | alert fires within 1 s |
| P1-T32 | Honeytoken AWS sub-account integration (decoy creds → CloudTrail webhook → alert) | 4 d | P1-T30 | end-to-end demo |

### 1.E — LLM-fed-malware heuristic (P1.1)

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T40 | LLM-API endpoint allowlist + outbound TLS SNI capture | 2 d | P1-T13 | event emitted on connect to known LLM hosts |
| P1-T41 | Embedded API-key pattern scan in process memory / recent file reads | 3 d | P1-T11 | fires on synthetic MalTerminal-style stub |
| P1-T42 | Correlator: LLM-call → `execve` chain within N seconds | 3 d | P1-T40, P1-T41 | rule combines into HIGH alert with 0 FP on `cargo build`/`npm install` corpus |

### 1.F — Intent sessions (P4)

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T50 | `artemis intent` CLI subcommand; on-disk signed state | 2 d | P1-T01 | start/stop/show works; tampering detected |
| P1-T51 | Intent template format + 3 templates (`code:repo`, `idle`, `tax-prep`) | 2 d | P1-T50 | templates parse + validate |
| P1-T52 | Out-of-intent detection rule set (soft-flag → hard-block escalation) | 3 d | P1-T22, P1-T51 | demo: writes to `~/.aws` outside `code:repo` intent flag |

### 1.G — Control plane MVP

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T60 | Ingest service (Rust + tonic), per-tenant rate limit | 4 d | P1-T15 | passes 50k events/sec/tenant in load test |
| P1-T61 | ClickHouse schema + writer | 3 d | P1-T60 | events queryable; per-tenant DB |
| P1-T62 | Detection engine: rule sandbox + alert emission | 3 d | P1-T60, P1-T22 | alerts arrive in <60 s p99 |
| P1-T63 | Console v0 (Next.js): alert list + drilldown | 5 d | P1-T62 | basic UI usable |

### 1.H — Reporting (P13) — minimal

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T70 | Live dashboard (open alerts, MTTR, ATT&CK heatmap stub) | 4 d | P1-T63 | dashboard loads, charts populate |

### 1.I — Phase-1 hardening

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T80 | Performance suite: stress-ng, kernel build, npm install — baseline + regression CI | 3 d | P1-T14, P1-T22 | <2% CPU, <150 MB RAM at idle |
| P1-T81 | Synthetic-SMB exercise harness (20 VMs, attacker scripts, defender Artemis) | 5 d | P1-T70 | one full attack→detect→contain cycle scripted |
| P1-T82 | Design-partner deployment package (.deb + .rpm + tarball) | 2 d | P1-T81 | one design partner running on ≥10 hosts |

**Phase-1 exit criteria:** design partner runs Artemis on a 50-host Linux fleet for 2 weeks; performance budget met; 0 cross-tenant test failures.

---

## Phase 2 — Windows + LLM copilot (≈ 8 weeks)

(See `docs/08-roadmap.md` for milestones; tickets to be expanded when Phase 1 nears done.)

| ID | Title | Owner | Est |
|---|---|---|---|
| P2-T01 | ETW consumer for `Microsoft-Windows-Threat-Intelligence` | Win sensor eng | 5 d |
| P2-T02 | Filesystem minifilter driver skeleton | Win sensor eng | 10 d |
| P2-T03 | AMSI provider integration | Win sensor eng | 5 d |
| P2-T04 | LLM copilot (P5) — narrative generation per alert | Daemon eng | 5 d |
| P2-T05 | Reporting (P13) — weekly executive PDF | Console eng | 5 d |
| P2-T06 | TPM enrolment + Secure Boot status (P9 phase 1) | Daemon eng | 4 d |
| P2-T07 | Entra connector (P10 phase 1) | Control-plane eng | 5 d |

---

## Phase 3 — macOS + browser + privacy (≈ 8 weeks)

(Outline only; expand near end of Phase 2.)

- macOS sensor: Endpoint Security + Network Extension (~10 d).
- Browser MV3 extension: DOM injection + agent tool-call audit (~8 d).
- DP egress filter (~5 d).
- Provenance graph GA (~7 d).

---

## Phase 4 — Hardening & robust ML (≈ 8 weeks)

(Outline.)

- DRSM-style smoothed classifier (~8 d).
- CKKS federated IoC aggregator MVP (~8 d).
- CFI policy enforcement (P9 phase 2) (~5 d).
- Okta + Google connectors (~5 d).
- Supply-chain runtime guard (~10 d).
- SOC 2 + ISO 27001 evidence export (~5 d).

---

## Phase 5 — Active Defense unlock (≈ 6 weeks, gated by legal)

- P14 capabilities A–E shippable, locked off by default (~10 d).
- Per-jurisdiction policy framework (~5 d).
- Dual-control workflow (~3 d).
- PQ signing in code-update pipeline (~5 d).

---

## Stretch / unscheduled

Track here as ideas surface. Move into a phase when ready.

- Mobile sensors (Android via MDM posture).
- Confidential-VM workloads (P9 phase 3).
- Marketplace for third-party rules.
- Rule store federation.
