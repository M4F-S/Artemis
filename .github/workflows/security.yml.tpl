# Security workflow template. Rename to security.yml when Phase 1 begins.
# Runs cargo-audit, dependency review, secret scan, and SLSA build attestations.

name: security

on:
  pull_request:
  schedule:
    - cron: "13 4 * * *"  # nightly
  push:
    branches: [main]

permissions:
  contents: read
  id-token: write
  attestations: write

jobs:
  cargo-audit:
    name: cargo-audit
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - run: cargo install cargo-audit --locked
      - run: cargo audit --deny warnings

  dependency-review:
    name: dependency review
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: actions/dependency-review-action@v4

  secret-scan:
    name: secret scan
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: trufflesecurity/trufflehog@main
        with:
          path: .
          base: ${{ github.event.repository.default_branch }}
          head: HEAD

  slsa-build:
    name: SLSA L3 build + attestation
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - run: cargo build --workspace --release
      - name: attest provenance
        uses: actions/attest-build-provenance@v1
        with:
          subject-path: target/release/artemis-*
