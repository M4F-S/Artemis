# Contributing to Artemis

Artemis is in **Phase 0 — architecture spec**. No production code yet. We expect to start Phase 1 (Linux MVP) shortly. This document explains how to contribute regardless.

## Who this is for

- **Project owner** — sets direction, owns the legal review, owns customer relationships.
- **Coding-school colleagues / external contributors** — co-build Phase 1, run the synthetic-SMB exercise, write detection rules, audit code.
- **AI agents (e.g., Claude Code)** — build code, write tests, draft docs, refine prompts, run benchmarks. AI agents must read [`CLAUDE.md`](CLAUDE.md) first.
- **Design partners** (when we have them) — surface real-world feedback. Not a contributor role; see [`docs/13-design-partner-program.md`](docs/13-design-partner-program.md).

## Ground rules

1. **Read the docs.** Especially the relevant pillar doc and `docs/09-adr/`. ADRs are locked decisions.
2. **Do not implement P14 outbound capabilities** until legal review is complete. See [ADR-0009](docs/09-adr/0009-active-defense-policy.md).
3. **No "hack-back" code, ever.** Anything that targets systems we don't own is unacceptable in this repo.
4. **Privacy by default.** No keystroke / clipboard / document-content collection.
5. **Tests required.** New code lands with tests. New rules land with rule-tests.
6. **Sign all updates, models, and rule bundles.** See P12.

## Workflow

1. Pick a ticket from [`docs/12-task-backlog.md`](docs/12-task-backlog.md). Tickets have acceptance criteria.
2. Branch: `<initials>/<short-task>-<id>` (e.g. `mf/linux-bpf-skel-P1-T03`). Claude Code uses `claude/...`.
3. Commit messages: imperative mood, scoped prefix (`feat:`, `fix:`, `docs:`, `chore:`, `test:`).
4. PR template in `.github/PULL_REQUEST_TEMPLATE.md` (added when CI is set up).
5. PRs need: passing CI, one human review minimum, threat-model check noted in the description if you touched a privileged path.
6. End your session by updating [`docs/14-session-handoff.md`](docs/14-session-handoff.md).

## What you should *not* contribute

- Features outside the locked roadmap without a new ADR.
- Code that violates the privacy posture (P6).
- Anything that bypasses the multi-tenant isolation contract.
- Speculative P14 capabilities — not until legal sign-off.

## Suggested first tasks for new contributors

(Once Phase 1 starts; tracked in `docs/12-task-backlog.md`.)

| Skill | Good first task |
|---|---|
| Rust + Linux | Implement a single LSM hook with `aya` and emit OTLP events |
| Rust + Windows | ETW consumer for `Microsoft-Windows-Threat-Intelligence` |
| Rust + macOS | Endpoint Security skeleton: `es_client_t` setup + exec subscription |
| TypeScript / WebExt | DOM-prompt-injection detector unit |
| Detection authoring | Two YAML rules ported from public ATT&CK examples |
| ML | Wire ONNX Runtime into the daemon + a placeholder model |
| Web / UI | Console alert-list view (Next.js + a sample API stub) |
| Security review | Audit the Rust unsafe blocks and propose minimisations |

## Code of conduct

- Be specific. "It's broken" is not a bug report; "panic in `bpf_loader::load` on 5.15.0-92-generic with EPERM" is.
- Be kind. Reviews are about the code, not the person.
- Disagree by writing a counter-ADR, not by silently rewriting.

## Getting help

- Architecture questions → re-read the pillar doc, then ask the project owner.
- Phase-1 build questions → start a thread on the task ticket.
- Legal / P14 questions → project owner only; do not act.

## Licensing

Undecided ([ADR-0008](docs/09-adr/0008-licensing.md)). Default-closed until resolved. By contributing, you agree the project owner may relicense the work as part of finalising the licensing decision.
