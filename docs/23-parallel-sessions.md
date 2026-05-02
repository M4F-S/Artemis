# 23 — Parallel Implementation Sessions

The owner intends to run multiple Claude Code sessions in parallel, each playing a distinct team-member role. This doc defines the **workstreams**, the **branch protocol**, the **file ownership** that prevents stomping, and the **session prompts** to paste at the start of each session.

## Concept

One human (project owner) drives multiple parallel Claude Code sessions. Each session:

- Adopts one role from `docs/18-team-and-headcount.md`.
- Owns a specific set of files / crates (defined below).
- Branches from `main` with a stable per-session prefix.
- Opens PRs only against `main`; never directly merges into another session's branch.
- Records its work in `docs/14-session-handoff.md` at the end of each working block.

A **coordinator session** (the owner running `git` directly, or a dedicated tech-lead session) sequences merges and resolves cross-session conflicts.

## Phase-1 workstreams

Five workstreams, each runnable as one or more parallel sessions. Sized so a single session can make meaningful progress in a working block (~2–4 hours of human-supervised time).

| Stream | Role | Owns | Branch prefix | Tickets |
|---|---|---|---|---|
| **WS-A Tech Lead / Bootstrap** | R1 (tech lead) | workspace skeleton, CI activation, root manifests, ADR drafts, code-style configs | `tl/...` | P1-T00, P1-T01, P1-T02, P1-T03 |
| **WS-B Sensor (Linux/eBPF)** | R2 (sensor engineer) | `crates/artemis-bpf/`, `crates/artemis-sensor-linux/`, eBPF programs, kernel-side glue | `sensor/...` | P1-T10, P1-T11, P1-T12, P1-T13 |
| **WS-C Daemon + Rules** | R2/R3 paired | `crates/artemis-agentd/`, `crates/artemis-core/`, `crates/artemis-rules/`, ring-buffer consumer, OTLP client, rule engine | `daemon/...` | P1-T14, P1-T15, P1-T20, P1-T21, P1-T22 |
| **WS-D Control Plane** | R3 (backend engineer) | `crates/artemis-ingest/`, `crates/artemis-detection/`, ClickHouse schema, Postgres schema, alert routing | `cp/...` | P1-T60, P1-T61, P1-T62 |
| **WS-E Console + UX** | R4 (console engineer) | `apps/console/`, alert list view, drilldown, basic settings | `ui/...` | P1-T63, P1-T70 |
| **WS-F Detection + Deception** *(supports A–E)* | R5 (detection author) | `rules/pack-v0/`, deception template files, intent template files, P3 + P4 rules | `det/...` | P1-T22 (rules), P1-T30, P1-T31, P1-T32, P1-T50, P1-T51, P1-T52 |
| **WS-G LLM Heuristic** | R5 / R3 paired | `crates/artemis-core/llm_malware/`, P1.1 detector | `llm/...` | P1-T40, P1-T41, P1-T42 |
| **WS-H Hardening** | R1 + R2 | `tests/perf/`, `tests/e2e/`, performance suite, packaging | `harden/...` | P1-T80, P1-T81, P1-T82 |

Eight workstreams, but they are **not all active at once** — a normal Phase-1 cadence runs A in week 0, B+C+D in weeks 1–6 in parallel, E+F in weeks 2–8, G in weeks 4–8, H in weeks 7–10.

## Dependency graph

```
WS-A (bootstrap)
   │
   ├──► WS-B (sensor)  ──► WS-G (LLM heuristic) ──┐
   │       │                                       │
   │       └──► WS-C (daemon + rules) ◄────────────┘
   │                  │
   │                  └──► WS-D (control plane)
   │                              │
   │                              └──► WS-E (console)
   │
   └──► WS-F (detection content; runs alongside WS-C/D)
                │
                └──► WS-H (hardening; week 7+)
```

WS-A is a hard precondition. WS-B and WS-D can begin in parallel as soon as WS-A merges. WS-C depends on a minimal WS-B (a stub event source is fine). WS-E depends on a minimal WS-D (stub alerts are fine).

## File ownership rules (avoid stomping)

| Path | Primary owner stream | Other streams may touch? |
|---|---|---|
| `Cargo.toml` (workspace) | WS-A | only via PR + WS-A approval |
| `rust-toolchain.toml` | WS-A | no |
| `crates/artemis-core/**` | WS-C | WS-B + WS-G read-only; PRs against `crates/artemis-core/llm_malware/` allowed for WS-G |
| `crates/artemis-bpf/**` | WS-B | no |
| `crates/artemis-sensor-linux/**` | WS-B | no |
| `crates/artemis-agentd/**` | WS-C | WS-G adds modules under its own subdirectory |
| `crates/artemis-rules/**` | WS-C | WS-F may add YAML examples under `crates/artemis-rules/examples/` |
| `crates/artemis-ingest/**` | WS-D | no |
| `crates/artemis-detection/**` | WS-D | WS-F adds rules under `rules/`, never the engine itself |
| `apps/console/**` | WS-E | no |
| `rules/pack-v0/**` | WS-F | no |
| `tests/perf/**` and `tests/e2e/**` | WS-H | other streams may add test files specific to their crate under `crates/<name>/tests/` |
| `docs/**` | any stream may edit; PR review by tech lead required for cross-pillar changes |
| `docs/14-session-handoff.md` | every stream **must** append at end of session |
| `docs/09-adr/**` | tech lead approves; any session may draft an ADR |

Conflicts on shared files (e.g., `Cargo.toml` member additions) resolve by tech-lead-session merging serially.

## Branching protocol

- Branches per session: `<prefix>/<short-task>-<ticket-id>`. Examples: `sensor/lsm-bpf-skel-P1-T11`, `cp/ingest-mtls-P1-T60`.
- One branch per ticket; one ticket per branch (small PRs).
- PRs targeted at `main`. Two-reviewer rule for privileged paths (CODEOWNERS enforces).
- Sessions never push to `main` directly.
- The coordinator session merges PRs in dependency order; rebase, not merge-commit.

## Daily / per-block sync protocol

Each session ends with a structured update appended to `docs/14-session-handoff.md`:

```
### YYYY-MM-DD — WS-<X> session (Claude Code, model)
- What I did: <bullets>
- What's open in flight (branch / PR): <list>
- What I need from other streams: <list of asks>
- What's next: <bullets>
- Risks I'd flag: <list>
```

The coordinator scans these at the start of each working day to:
- Merge PRs whose deps just landed.
- Surface cross-stream blockers.
- Re-balance work.

## What each parallel session needs to know

Each session, when started, should be given:

1. The `CLAUDE.md` content (auto-loaded if present).
2. **A workstream prompt** (one per stream — see `docs/session-prompts/`) that says "you are WS-X owning these files and tickets."
3. The most recent `docs/14-session-handoff.md` entries for the streams it depends on.
4. A working branch (created by the human before pasting the prompt).

## When NOT to run sessions in parallel

- WS-A workspace bootstrap **must** complete and merge before others begin.
- Any ADR change pauses dependent streams until merged.
- Any change to `crates/artemis-core/event.rs` (the shared event schema) is a coordination event — sessions touching it must serialise with WS-C.
- Any privileged-path change (P14 / P15 / autonomic) goes through tech-lead review, blocking other sessions touching the same crate.

## Phase-2+ workstreams

Same model, different streams. Phase 2 (Windows + LLM copilot) adds:
- WS-I Windows sensor (R6).
- WS-J LLM copilot prompt + integration (R3 + R5).
- WS-K Reporting weekly PDF (R4).

Phase 7 (XDR domain expansion) is the highest-parallelism phase: 5 domain tracks running concurrently. The same protocol scales.

## Coordinator playbook (the owner's role)

- Start of working day: scan `docs/14-session-handoff.md` for the latest entries.
- Merge any PRs with green CI + reviews.
- For each active session: confirm it has a current ticket and unblocked dependencies.
- For new sessions: paste the prompt from `docs/session-prompts/<role>.md` plus the working branch already created.
- End of day: write a one-paragraph "coordinator note" entry in the handoff log.

## Risks of the parallel-session approach

- **Context drift** between sessions. Handoff doc must be honest and up to date.
- **Hidden coupling**: a "small" change in one crate breaks another. The CI matrix catches most; review catches the rest.
- **Single point of failure** on the coordinator (you). If the coordinator is unavailable, sessions should pause rather than guess.
- **Repeated work**: two sessions accidentally implementing the same thing. File-ownership rules above are the antidote; respect them.
- **Quality variance**: some sessions ship great code, others don't. Tech-lead review is the gate. Don't merge tired work.
