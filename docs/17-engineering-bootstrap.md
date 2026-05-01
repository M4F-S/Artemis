# 17 — Engineering Bootstrap

What a contributor needs in order to make their first commit on Phase 1. This is the only doc that should ever be required reading on day one for an engineer.

## Workspace layout (Cargo + pnpm)

```
artemis/                              ← repo root
├── Cargo.toml                        ← workspace
├── rust-toolchain.toml               ← pinned toolchain
├── crates/
│   ├── artemis-core/                 ← shared types, schema, rule engine, OTLP client
│   ├── artemis-bpf/                  ← eBPF programs (no_std, target = bpfel-unknown-none)
│   ├── artemis-agentd/               ← Linux userland daemon (Phase 1 entrypoint)
│   ├── artemis-sensor-linux/         ← LSM/eBPF loader + ring-buffer consumer
│   ├── artemis-sensor-windows/       ← (Phase 2) ETW + minifilter glue
│   ├── artemis-sensor-macos/         ← (Phase 3) ES client
│   ├── artemis-cli/                  ← `artemis` operator CLI
│   ├── artemis-rules/                ← rule schema + Wasm sandbox
│   ├── artemis-ml/                   ← ONNX scorer host (Phase 4)
│   ├── artemis-ingest/               ← control-plane ingest service
│   ├── artemis-detection/            ← control-plane detection engine
│   ├── artemis-self-healing/         ← (Phase 5) P15 controller
│   ├── artemis-knowledge/            ← (Phase 5) signed Knowledge store
│   ├── artemis-rule-synth/           ← (Phase 5) LLM rule synthesiser
│   ├── artemis-bas/                  ← (Phase 6) BAS orchestrator
│   ├── artemis-active-defense/       ← P14 orchestrator + NAC connector framework
│   ├── artemis-nac-freeradius/       ← FreeRADIUS connector (v0)
│   ├── artemis-llm-firewall/         ← (Phase 7) P21 sidecar
│   └── artemis-cwpp/                 ← (Phase 7) container/K8s collectors
├── apps/
│   ├── console/                      ← Next.js multi-tenant console
│   └── webext/                       ← MV3 browser extension
├── rules/
│   └── pack-v0/                      ← initial YAML rule pack
├── tests/                            ← cross-crate integration tests
│   └── e2e/                          ← end-to-end scenarios
├── ops/
│   ├── helm/                         ← K8s charts for control plane
│   ├── terraform/                    ← cloud infra
│   └── images/                       ← agent installer build scripts
├── docs/                             ← (existing)
└── .github/
    ├── workflows/
    ├── PULL_REQUEST_TEMPLATE.md
    └── CODEOWNERS
```

This layout is **a target**, not a from-day-1 requirement. Phase 1 only needs `artemis-core`, `artemis-bpf`, `artemis-agentd`, `artemis-sensor-linux`, `artemis-cli`, `artemis-rules`, `artemis-ingest`, `artemis-detection`, `apps/console`, `tests/`, `rules/pack-v0/`. Other crates are placeholders that arrive when their phase begins.

## Toolchain

- `rust-toolchain.toml` pins to **stable + nightly** for eBPF (nightly only used in `artemis-bpf`).
- Cargo profiles:
  - `dev` — fast incremental.
  - `release` — LTO on, strip symbols, panic=abort.
  - `release-with-debug` — release optimisations + debug info, used for binaries shipped to design partners.
- `pnpm` for `apps/`. Node version pinned via `.nvmrc`.

## Dev environment

Two supported paths — pick one:

### Path A: devcontainer (recommended for new contributors)

`.devcontainer/devcontainer.json` defines:
- Ubuntu 24.04 base with kernel headers.
- Rust toolchain (stable + nightly) preinstalled.
- `aya-tool`, `bpftool`, `clang`, `llvm`.
- `pnpm`, Node LTS.
- Docker-in-Docker for sandbox tests.

### Path B: nix flake (for nix-curious / reproducible)

`flake.nix` defines the same dependency set. Anyone with `nix develop` gets a working shell.

Either path: a single command brings up a clean, passing-tests workspace.

## Build & test

```bash
# from repo root
cargo fmt --check
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
pnpm -C apps/console install && pnpm -C apps/console test
```

Phase 1's CI runs these on every PR plus a kernel-matrix test (Ubuntu 22.04 / 24.04, kernels 5.15 / 6.1 / 6.6 / 6.12).

## Code style

- Rust: `cargo fmt` defaults; clippy as gate. No `unsafe` without a comment justifying it; `unsafe` blocks reviewed twice.
- TypeScript: Biome / Prettier; ESLint; strict `tsconfig`.
- YAML rules: `yamllint` + custom schema validator.
- Markdown: `markdownlint`.

## Branching, commits, PRs

- `main` is protected; PRs only.
- Branches: `<initials>/<short-task>-<ticket-id>`, e.g. `mf/lsm-bpf-skel-P1-T11`. Claude Code uses `claude/...`.
- Commits: imperative + scope prefix (`feat:`, `fix:`, `docs:`, `chore:`, `test:`, `perf:`).
- PRs: filled-out template (`.github/PULL_REQUEST_TEMPLATE.md`). At least one human review. Privileged-path edits flagged.

## Testing strategy

- **Unit tests** next to code (`#[cfg(test)] mod tests`). Required for every public API.
- **Integration tests** in `tests/` per crate. Required for sensor + detection paths.
- **End-to-end tests** in `tests/e2e/`. Spin agent + ingest + detection in containers; assert alert output for canned scenarios.
- **Performance suite** (`tests/perf/`). `stress-ng`, kernel build, npm install, video render. CI gates merges if regression > 10%.
- **Adversarial / red-team tests** (Phase 4+). Drives P17 BAS coverage report.

## Telemetry budget enforced in CI

CI runs `tests/perf/idle-budget.rs` against a clean Ubuntu image. Fail-on-regress: > 2% CPU, > 150 MB RAM, > 50 MB/day net.

## Secrets & credentials

- No secrets in repo. CI uses GitHub OIDC → cloud short-lived creds.
- Local dev: `.env.local` (in `.gitignore`); never committed.
- Signing keys for releases live in cloud KMS only, never on a human's laptop.

## Documentation expected per PR

- Code comment only when WHY is non-obvious.
- For user-visible behaviour: a one-paragraph note in the relevant pillar doc.
- For locked decisions: a new ADR.

## Local agent runtime (Phase 1)

```bash
# build + run on the local Linux host
cargo build -p artemis-agentd --release
sudo ./target/release/artemis-agentd --config dev/agent.toml
```

`dev/agent.toml` ships in repo, points at `localhost:4317` for OTLP, no mTLS in dev mode (separate `dev` build flag).
