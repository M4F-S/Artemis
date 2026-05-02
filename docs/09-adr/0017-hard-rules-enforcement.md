# ADR-0017 — Hard-rules enforcement: beyond grep

## Status
Accepted (Phase 0).

## Context

`.github/workflows/ci.yml.tpl` ships a `hard-rules-scan` job that uses `grep` to refuse certain string patterns (e.g. `scan_attacker`, `exploit_remote`, `hack_back`, `apollo-(core|controller|...)`). The previous audit (`docs/29-senior-audit.md`) flagged this as inadequate: a grep over source is trivially bypassed by string concatenation, base64 encoding, dynamic dispatch, calling out to a third-party crate that does the bad thing, or simply renaming a variable.

The hard rules are:
1. No outbound action targeting non-customer-owned hosts (the lawful-perimeter rule).
2. Apollo dependencies never appear in Artemis crates.
3. No collection of document content / clipboard / keystrokes.
4. Multi-tenant isolation respected.
5. All shipped artefacts signed.

These rules are enforced today via documentation + reviewer attention + grep. That is not enough.

## Decision

A layered enforcement model. Each rule has at least two enforcement points; no rule depends on grep alone.

### Layer 1 — Capability-allowlist on the daemon's outbound network

The daemon's process runs in a Linux netns / cgroup with a default-DROP outbound policy. Allowed destinations:
- Configured ingest endpoint(s) per agent config.
- Configured update endpoint(s).
- Configured identity-provider endpoints (P10).
- Configured federation aggregator (P6 / P16, when enabled).
- LLM provider (P5, only if enabled and local-Llama mode is off).

Anything else is refused at the kernel; the daemon literally cannot connect to an arbitrary attacker host because there is no socket route. This is enforced at runtime, not at compile time, so grep bypasses don't matter.

### Layer 2 — AST / MIR analysis on PRs

For each PR touching `crates/`:
- **Semgrep** ruleset (versioned in `.github/semgrep/`) checks for:
  - Calls to `std::process::Command::new("nmap"|...)` or known offensive tool launchers.
  - Direct invocation of raw socket APIs in non-allowlisted modules.
  - Calls into `crates/apollo-*` symbols (refused at the cargo dependency level too).
- **Cargo-deny** config (`deny.toml`) enforces:
  - License allow-list (Apache-2 / MIT / BSD / MPL-2 / ISC).
  - Vulnerability database (`cargo audit` integrated).
  - Banned crates: anything matching `nmap-*`, `*-exploit`, `metasploit-*`, `apollo-*`.
  - Source allow-list: `crates.io` only; private registries explicitly enumerated.
- **Custom MIR pass** (Phase 5+) flagging direct calls to network primitives outside `crates/artemis-egress/` (the only crate allowed to open new sockets).

### Layer 3 — Privileged-path two-reviewer rule

- `crates/artemis-active-defense/**`, `crates/artemis-self-healing/**`, `crates/artemis-signer/**`, and `crates/artemis-nac-*/**` require **two human reviewers** on every PR (CODEOWNERS).
- One reviewer is the tech lead or designated security reviewer.
- Reviewers must explicitly check the PR template's hard-rules checklist.

### Layer 4 — Sandboxed test runs

- For any PR touching active-defense or self-healing or NAC, CI runs a battery of negative tests (Apollo's authorised lab targets) verifying the change cannot escalate scope.
- Tests run in network-isolated containers; failure of an isolation test fails the PR.

### Layer 5 — Runtime self-audit by the daemon

- The daemon at startup verifies its own capabilities (CAP_BPF, CAP_PERFMON, etc.). Mismatches abort startup and emit a tamper alert.
- Periodically the daemon reads its own seccomp / netns config and verifies it matches the expected baseline; deviation = self-tamper alert.

### What gets removed

- The grep-based `hard-rules-scan` job stays (cheap, catches obvious mistakes), but it is **not** the canonical enforcement; the layers above are.
- Documentation must not point at the grep job as proof of safety.

## Per-rule enforcement matrix

| Hard rule | Layer 1 | Layer 2 | Layer 3 | Layer 4 | Layer 5 | Plus grep |
|---|---|---|---|---|---|---|
| No outbound to non-allowed hosts | ✓ runtime | ✓ AST | ✓ review | ✓ tests | ✓ runtime audit | ✓ string check |
| Apollo deps not in Artemis | — | ✓ cargo-deny | ✓ review | — | — | ✓ string check |
| No content / clipboard / keystrokes | — | ✓ AST (forbidden APIs: clipboard, keylog) | ✓ review | — | — | — |
| Multi-tenant isolation | — | ✓ AST (tenant_id propagation) | ✓ review | ✓ fuzz | — | — |
| Signed artefacts only | — | ✓ build verifier | ✓ release process | — | ✓ verify on update | — |

Every rule has ≥ 2 enforcement points; layer 1 + layer 5 are runtime; layer 2 + 4 are CI; layer 3 is human; grep is the cheap belt-and-braces last resort.

## Consequences

- CI runtime increases (Semgrep + cargo-deny + isolated tests). Acceptable.
- Some PRs require more reviewers, slowing throughput on privileged paths. Intended.
- Honest-marketing dividend: we can describe enforcement as runtime-bounded + AST-verified + reviewed + fuzzed, not "we grep for it."

## Verification

- Annual external audit specifically targeting hard-rules bypass.
- Apollo's red-team scenarios include "convince Artemis to do an offensive thing" tests; failures here are CRITICAL.
- The Apollo CI invariant ("no Apollo dep in Artemis workspace") tested in both repos.
