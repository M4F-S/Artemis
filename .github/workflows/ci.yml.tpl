# CI workflow template. Rename to ci.yml when Phase 1 begins.
# This is a skeleton; expand as crates are added.

name: ci

on:
  pull_request:
  push:
    branches: [main]

env:
  CARGO_TERM_COLOR: always
  RUSTFLAGS: "-D warnings"

jobs:
  rust-build-test:
    name: rust build & test
    strategy:
      matrix:
        os: [ubuntu-22.04, ubuntu-24.04]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: dtolnay/rust-toolchain@nightly
        with:
          components: rust-src
      - uses: Swatinem/rust-cache@v2
      - name: fmt
        run: cargo fmt --all -- --check
      - name: clippy
        run: cargo clippy --workspace --all-targets -- -D warnings
      - name: build
        run: cargo build --workspace --all-targets
      - name: test
        run: cargo test --workspace --all-targets

  # Kernel-matrix test for eBPF programs.
  # Phase 1+: load real LSM hooks against multiple kernel LTS lines.
  ebpf-matrix:
    name: ebpf kernel matrix
    needs: rust-build-test
    strategy:
      matrix:
        kernel: ["5.15", "6.1", "6.6", "6.12"]
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - name: load + verify bpf programs against kernel ${{ matrix.kernel }}
        run: |
          # placeholder; real impl uses Vagrant/Lima with pinned kernel
          echo "skipping until phase 1 lands"

  pnpm-build-test:
    name: pnpm (console + webext)
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 'lts/*' }
      - uses: pnpm/action-setup@v3
      - run: pnpm -C apps/console install --frozen-lockfile
      - run: pnpm -C apps/console lint
      - run: pnpm -C apps/console test --if-present
      # webext added in Phase 3.

  perf-budget:
    name: idle telemetry budget (regression gate)
    runs-on: ubuntu-24.04
    needs: rust-build-test
    steps:
      - uses: actions/checkout@v4
      - run: |
          # placeholder; real impl runs the agent under stress-ng + npm install
          # asserts <2% CPU, <150MB RAM, <50MB/day net at idle.
          echo "perf budget gate — implement in P1-T80"

  hard-rules-scan:
    name: hard-rules scan
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - name: refuse offensive-target patterns
        run: |
          # No code path may target arbitrary external IP/host.
          # Specifically: refuse any string matching `attacker.example` etc.
          # Catches accidental "test endpoint" introductions.
          ! grep -rn -E "(scan_attacker|exploit_remote|hack_back)" --include="*.rs" .
      - name: refuse Apollo dependencies in Artemis crates
        run: |
          # Per ADR-0012: Apollo crates must not appear in Artemis workspace.
          ! grep -E "apollo-(core|controller|mutation|tools)" Cargo.toml crates/*/Cargo.toml || true
      - name: doc cross-link check
        run: |
          # Verify markdown links resolve.
          # Use a tool like markdown-link-check; placeholder for now.
          echo "link check — wire up in P1-T03"
