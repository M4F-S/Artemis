# 12 — Task Backlog

Actionable tickets organised by roadmap phase. Each ticket has a stable ID (e.g. `P1-T03`), an owner type, an estimate, dependencies, and acceptance criteria. Pick from the top of a phase; don't skip ahead unless the ticket is marked `parallel`.

Status legend: ☐ open · ◐ in progress · ☑ done · ✗ blocked.

---

## Phase 0 — Spec lock (current)

| ID | Title | Owner | Est | Deps | Status |
|---|---|---|---|---|---|
| P0-T01 | Capture spec in repo | Claude | 1 d | — | ☑ |
| P0-T02 | Hand legal docs (ADR-0009 + ADR-0012 + ADR-0013 + P14 + threat model) to security counsel | Project owner | external | P0-T01 | ◐ awaiting reply |
| P0-T03 | Identify 2 design-partner SMB candidates (1 US, 1 EU) | Project owner | 2 wk | — | ☐ |
| P0-T04 | Recruit founding engineers / colleagues per `docs/18-team-and-headcount.md` | Project owner | 2 wk | — | ☐ |
| P0-T05 | Stand up GitHub repo, CI scaffolding (templates exist; rename `.tpl` to active when team formed) | Any contributor | 1 d | P0-T04 | ☐ |
| P0-T06 | External advisor reviews threat model | External | external | P0-T01 | ☐ |
| P0-T07 | Draft contributor CLA (link from CONTRIBUTING.md) | Project owner + counsel | 1 wk | P0-T02 | ☐ |
| P0-T08 | Run kickoff checklist (`docs/21-kickoff-checklist.md`) end-to-end | Project owner + tech lead | 1 d | P0-T05 | ☐ |
| P0-T09 | First contact with 42 Berlin (per `docs/16-42-berlin-outreach.md`) | Project owner | 2 wk | — | ☐ |

**Phase-0 exit criteria:** P0-T02 returned, ≥1 design partner signed, ≥2 contributors lined up, CI scaffolding active, kickoff checklist green.

---

## Phase 1 — Linux MVP (≈ 10 weeks)

### 1.A — Repository scaffolding

| ID | Title | Est | Deps | Acceptance |
|---|---|---|---|---|
| P1-T00 | Repo bootstrap: clone, devcontainer/nix flake, branch protection, CODEOWNERS, PR template (templates already in `.github/`) | 0.5 d | P0-T08 | new contributor can `git clone` + run a passing build in < 30 minutes |
| P1-T01 | Workspace layout per `docs/17-engineering-bootstrap.md`: `crates/artemis-core`, `crates/artemis-agentd`, `crates/artemis-bpf`, `crates/artemis-sensor-linux`, `crates/artemis-cli`, `crates/artemis-rules`, `crates/artemis-ingest`, `crates/artemis-detection` | 1 d | P1-T00 | `cargo build` succeeds; `cargo clippy -D warnings` clean |
| P1-T02 | CI: rename `ci.yml.tpl` to `ci.yml`; verify lint, build, test matrix (Ubuntu 22.04 + 24.04, kernels 5.15/6.1/6.6/6.12) | 1 d | P1-T01 | green pipeline on push |
| P1-T03 | Security CI: rename `security.yml.tpl`; cargo-audit, dependency-review, trufflehog, SLSA build attestations | 1 d | P1-T02 | attestations published as artefacts |

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

## Phase 5 — Active Defense + autonomic foundation (≈ 8 weeks)

| ID | Title | Owner | Est |
|---|---|---|---|
| P5-T01 | P14 capabilities A–E shippable, locked off by default | Daemon eng + control-plane eng | 10 d |
| P5-T02 | Per-jurisdiction policy framework | Control-plane eng | 5 d |
| P5-T03 | Dual-control workflow for destructive actions | Console eng | 3 d |
| P5-T04 | PQ signing in code-update pipeline | Daemon eng | 5 d |
| P5-T05 | P15.S1 agent self-protection + cloud watchdog re-deploy | Daemon eng | 5 d |
| P5-T06 | P15.S2 Btrfs/ZFS/VSS snapshot integration + rollback (manual approval) | Daemon eng | 7 d |
| P5-T07 | Knowledge store skeleton (Postgres + signed manifests) | Control-plane eng | 5 d |
| P5-T08 | LLM rule-synthesiser + human review queue | Detection author + control-plane eng | 7 d |
| P5-T09 | P14 Tier ladder (0–3) implemented in orchestrator | Control-plane eng | 4 d |
| P5-T10 | NacConnector trait + `artemis-nac-freeradius` reference (Tier 4) | Control-plane eng | 7 d |
| P5-T11 | P14 Tier 5 report generator (template + delivery via email DL / webhook) | Control-plane eng + detection author | 4 d |
| P5-T12 | ADR-0010 / ADR-0011 / ADR-0013 CI invariants (action allowlist, multi-signal gate, NAC reversibility, rate limits) | All | 3 d |
| P5-T13 | Apollo seed scenarios (10 from Atomic Red Team / Caldera) — part-time | Detection author | 5 d |

---

## Phase 6 — Autonomic loop GA + Apollo Phase 1 (≈ 10 weeks)

| ID | Title | Owner | Est |
|---|---|---|---|
| P6-T01 | P15.S3 secret-rotation integrations (Vault, AWS SM, GCP SM, Azure KV) | Control-plane eng | 7 d |
| P6-T02 | P15.S4 continuous attestation reconciliation | Daemon eng | 5 d |
| P6-T03 | P15.S5 decentralised mesh fallback (read-only) | Daemon eng | 10 d |
| P6-T04 | P15.S6 damage-assessment + restore plan | Daemon eng + control-plane eng | 7 d |
| P6-T05 | P16.E1 online ML with Byzantine-robust federated aggregation | ML eng | 10 d |
| P6-T06 | P16.E3 RL response ranker (with safety constraints) | ML eng | 10 d |
| P6-T07 | P16.E4 operator-feedback FPR tuning (bounded) | Detection author | 5 d |
| P6-T08 | P16.E6 auto-deception placement learning | ML eng | 5 d |
| P6-T09 | P16.E7 attack-graph mining job | Control-plane eng | 5 d |
| P6-T10 | P17 BAS curated technique library v0 (20 ATT&CK techniques) | Detection author + red-team | 10 d |
| P6-T11 | P17 BAS scheduled runner + canary scope enforcement | Control-plane eng | 5 d |
| P6-T12 | P17 BAS gap-to-rule pipeline | Detection author | 5 d |
| P6-T13 | Additional CI invariants for ADR-0012 / ADR-0013 (Apollo isolation, NAC reversibility, tier rate limits) | All | 5 d |
| P6-T14 | Apollo: separate repo bootstrap (`m4f-s/apollo`); ADR-0001 (clone of ADR-0012); core scenario runtime | Red-team eng | 7 d |
| P6-T15 | Apollo: target-allowlist enforcement (load + pre-flight + netns layers) | Red-team eng | 7 d |
| P6-T16 | Apollo: 30-scenario library covering top ATT&CK tactics | Red-team eng + detection author | 10 d |
| P6-T17 | Apollo → Artemis P16 gap-to-rule pipeline (sandboxed, human-reviewed) | Red-team eng + detection author | 5 d |
| P6-T18 | NAC connectors: pfSense + UniFi (Tier 4) | Control-plane eng | 7 d |

Exit criterion: 30-day tenant run; ≥10 incidents auto-assisted; zero false-rollbacks; measurable rule-quality lift; Apollo lab-only enforcement validated by red-team review.

---

## Phase 7 — Domain expansion (≈ 16 weeks; sub-tracks can run in parallel)

| ID | Title | Owner | Est |
|---|---|---|---|
| P7-T01 | P18 Microsoft 365 + Google Workspace API connector | Email-track eng | 10 d |
| P7-T02 | P18 URL detonation sandbox | Email-track eng | 7 d |
| P7-T03 | P18 attachment microVM (Firecracker) | Email-track eng | 10 d |
| P7-T04 | P19 endpoint co-sensor for network metadata | Sensor eng | 5 d |
| P7-T05 | P19 tap/SPAN appliance MVP | NDR-track eng | 15 d |
| P7-T06 | P19 JA4 + DGA + DNS-tunnel detectors | NDR-track eng + ML eng | 7 d |
| P7-T07 | P20 container runtime annotation + per-image baselines | CWPP-track eng | 7 d |
| P7-T08 | P20 K8s admission webhook (validating + mutating) | CWPP-track eng | 7 d |
| P7-T09 | P20 image scanner integration (Trivy/Grype) | CWPP-track eng | 5 d |
| P7-T10 | P20 cloud-config posture sweepers (AWS/GCP/Azure) | CWPP-track eng | 10 d |
| P7-T11 | P21 LLM firewall sidecar + SDK shim | AI-app-track eng | 10 d |
| P7-T12 | P21 prompt-injection + data-egress classifiers | ML eng | 10 d |
| P7-T13 | P22 hunter's notebook UI | Console eng | 10 d |
| P7-T14 | P22 IR runbook engine | Control-plane eng | 7 d |
| P7-T15 | P22 backup connectors (Veeam, Rubrik, AWS Backup, restic) | Control-plane eng | 10 d |

---

## Phase 8 — 42 Berlin pilot (parallel to Phase 1+)

| ID | Title | Owner | Est |
|---|---|---|---|
| P8-T01 | 42 cursus intent-template pack (born2beroot, minishell, ft_irc, webserv, inception, ctf/pwn) | Detection author + 42 contributor | 5 d |
| P8-T02 | BYOD per-user enrolment flow + consent UI | Console eng + sensor eng | 7 d |
| P8-T03 | EU residency + DPIA template package | Control-plane eng + counsel | 5 d |
| P8-T04 | Public bug-bounty programme launch | Project owner | 1 wk |
| P8-T05 | "Break Artemis" CTF event preparation | Red-team + 42 liaison | 2 wk |
| P8-T06 | First demo + outreach with 42 leadership (per `docs/16-42-berlin-outreach.md`) | Project owner | ongoing |

---

## Stretch / unscheduled

Track here as ideas surface. Move into a phase when ready.

- Mobile sensors (Android via MDM posture).
- Confidential-VM workloads (P9 phase 3).
- Marketplace for third-party rules.
- Rule-store federation.
- Federation across all 42 campuses (~50 sites) once Berlin pilot succeeds.
- Quantum-safe networking (beyond P12 code signing).
