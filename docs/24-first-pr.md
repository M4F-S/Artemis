# 24 — The First PR

What literally lands when Phase 1 begins. This is the WS-A bootstrap PR — small, careful, sets the foundation so every subsequent PR composes cleanly.

## Goal

After this PR merges, any contributor should be able to:

```bash
git clone <repo>
cd artemis
# either: open in VS Code with devcontainer
# or: run `nix develop` if they have nix
cargo build --workspace
cargo test --workspace
```

…and get a passing build with zero functional code shipped, but every crate, manifest, lint, and CI workflow in place.

## Branch

`tl/bootstrap-P1-T00-T01-T02-T03`

## Files added (by category)

### Repo root

```
artemis/
├── Cargo.toml              ← workspace, lists every member crate
├── rust-toolchain.toml     ← stable + nightly pins
├── .editorconfig
├── .markdownlint.json
├── deny.toml               ← cargo-deny config (license + ban policies)
├── rustfmt.toml
├── clippy.toml
├── .vscode/extensions.json ← recommended dev extensions
└── flake.nix               ← reproducible dev env (nix path)
```

### Devcontainer

```
.devcontainer/
└── devcontainer.json       ← Ubuntu 24.04 + Rust + aya-tool + clang + Node + pnpm
```

### Crates (placeholders, each with `lib.rs` containing one doc-comment + a passing trivial test)

```
crates/
├── artemis-core/           ← shared types and traits; depended on by ~all
├── artemis-bpf/            ← cargo-bpf placeholder; #![no_std] target = bpfel-unknown-none
├── artemis-agentd/         ← daemon binary; main.rs prints version and exits cleanly
├── artemis-sensor-linux/   ← lib placeholder
├── artemis-cli/            ← CLI binary; clap skeleton with `--version`
├── artemis-rules/          ← rule schema + Wasm sandbox placeholder
├── artemis-ingest/         ← server binary; tokio + tonic placeholder
└── artemis-detection/      ← detection engine placeholder
```

Each crate's `Cargo.toml` declares the workspace dependency it needs (`tokio`, `tracing`, `serde`, `anyhow`, `thiserror`); no business logic beyond stub.

### Apps

```
apps/
└── console/                ← Next.js skeleton via `pnpm create next-app`
    └── (default scaffold + a single placeholder /alerts route)
```

### Tests

```
tests/
├── e2e/                    ← README only at this stage
└── perf/
    └── idle_budget_smoke.rs  ← runs the daemon for 5 s, asserts < 5% CPU (relaxed gate; tightened in P1-T80)
```

### Rules

```
rules/
└── pack-v0/
    └── README.md           ← rule pack stub; rules added in WS-F
```

### Ops

```
ops/
├── helm/
│   └── README.md           ← placeholder
├── terraform/
│   └── README.md           ← placeholder
└── images/
    └── README.md           ← placeholder
```

### Dev configuration sample

```
dev/
└── agent.toml              ← see samples/agent.toml.example
```

### Sample artifacts (committed for reference)

- [`samples/event.proto`](../samples/event.proto) — OTLP-shaped event schema.
- [`samples/rule.example.yaml`](../samples/rule.example.yaml) — Falco-style YAML.
- [`samples/agent.toml.example`](../samples/agent.toml.example) — sample dev config.

### CI activation

- `.github/workflows/ci.yml` — renamed from `.tpl`.
- `.github/workflows/security.yml` — renamed from `.tpl`.

## CI gates that must pass on this PR

- `cargo fmt --all -- --check`
- `cargo clippy --workspace --all-targets -- -D warnings`
- `cargo build --workspace --all-targets`
- `cargo test --workspace --all-targets`
- `pnpm -C apps/console install --frozen-lockfile && pnpm -C apps/console test --if-present`
- `cargo deny check`
- Hard-rules-scan invariant green
- Markdown link check green

## Acceptance checklist for this PR

- [ ] All listed files present.
- [ ] `cargo build --workspace` succeeds on Ubuntu 22.04 and 24.04.
- [ ] `cargo test --workspace` succeeds (each crate has at least one trivial test).
- [ ] CI green.
- [ ] PR template filled out.
- [ ] CODEOWNERS placeholders updated to real GitHub handles for the WS-A reviewer at minimum.
- [ ] Branch protection enabled on `main` with: required CI checks, 1 review minimum, signed commits.
- [ ] `docs/14-session-handoff.md` updated with the WS-A entry.

## What this PR explicitly does NOT do

- No eBPF programs (WS-B).
- No real OTLP wire (WS-C).
- No real ingest (WS-D).
- No real UI beyond the placeholder route (WS-E).
- No real rules (WS-F).
- No LLM heuristic (WS-G).

Each downstream PR composes cleanly on top.

## What unblocks immediately after this PR merges

| Workstream | Can start | Initial ticket |
|---|---|---|
| WS-B Sensor | yes | P1-T10 (aya bootstrap; load no-op LSM hook) |
| WS-D Control Plane | yes | P1-T60 (ingest skeleton; mTLS off in dev) |
| WS-F Detection | yes | P1-T22 (write 5 of the 20 rules into `rules/pack-v0/`) |
| WS-C Daemon + Rules | needs WS-B's first event source (stub fine) | P1-T20 (rule schema + parser, no engine yet) |
| WS-E Console | needs WS-D's first stub alert | P1-T63 (alert list view, mock data initially) |
| WS-G LLM Heuristic | needs WS-C's event bus | wait one tick |
| WS-H Hardening | needs WS-A merged | P1-T80 (perf-budget skeleton) |

## Sequencing once kicked off

The coordinator (owner) issues, in this order:

1. WS-A starts; merges within ~24 hours.
2. WS-B + WS-D + WS-F start in parallel.
3. WS-C joins as soon as WS-B has a stub event source.
4. WS-E joins as soon as WS-D has a stub alert.
5. WS-G + WS-H join per dependency graph.

If any session blocks for > 4 hours waiting on another stream, the coordinator either pulls a branch forward to unblock or re-points the session at an independent ticket.
