# CLAUDE.md — context for Claude Code sessions on this repo

You are working on **Artemis**, a next-generation cross-platform endpoint protection product targeted at the 10–500-seat SMB / mid-market.

## Current state

- **Phase 0 — architecture spec.** No production code yet. Repo contains only design documents.
- The user (project owner) has approved the spec and handed `docs/09-adr/0009-active-defense-policy.md` plus surrounding docs to a security lawyer for review.
- Phase 1 (Linux MVP, Rust + eBPF) is queued but not started. Begin only when the user says so.

## Read these first, in order

1. [`README.md`](README.md) — overview.
2. [`docs/00-vision.md`](docs/00-vision.md) — problem and customer.
3. [`docs/01-threat-model.md`](docs/01-threat-model.md) — adversary tiers and trust boundaries.
4. [`docs/02-system-architecture.md`](docs/02-system-architecture.md) — components.
5. [`docs/04-detection-pillars/`](docs/04-detection-pillars/) — every capability pillar P1–P14.
6. [`docs/08-roadmap.md`](docs/08-roadmap.md) — phasing.
7. [`docs/12-task-backlog.md`](docs/12-task-backlog.md) — actionable tickets, organised by phase.
8. [`docs/14-session-handoff.md`](docs/14-session-handoff.md) — what the previous session did, what's next.

## How to continue

- Pick a ticket from `docs/12-task-backlog.md`. Tickets carry acceptance criteria.
- If running as one of the parallel implementation workstreams, use the matching prompt in `docs/session-prompts/` (WS-A through WS-H), and respect the file-ownership rules in `docs/23-parallel-sessions.md`.
- If the ticket touches a pillar, re-read the pillar doc before coding.
- Honor the ADRs in `docs/09-adr/` — they're locked decisions; argue for changes via a new ADR superseding the old one, not by silently deviating.
- Branch naming: `claude/<short-task>-<id>` (general) or the workstream-specific prefix `tl/`, `sensor/`, `daemon/`, `cp/`, `ui/`, `det/`, `llm/`, `harden/`.
- Commit messages: imperative mood, scoped prefix (`feat:`, `fix:`, `docs:`, `chore:`, `test:`).
- Always update `docs/14-session-handoff.md` at the end of a working session.

## Hard rules — read these every session

1. **Do not implement P14 (Active Defense) outbound capabilities** until the legal review comes back and the project owner says so. Capabilities A–E (perimeter-internal) may be built and shipped *off*.
2. **No outbound action that targets attacker-controlled hosts**, ever. Anything resembling probing, exploitation, payload delivery, or unauthorised access against third-party systems is **out of scope** and must not be implemented even on speculation.
3. **Privacy-by-default.** Document content, clipboard, keystrokes — never collected.
4. **Multi-tenant isolation is sacred.** Any code path that handles a `tenant_id` must be reviewed for isolation.
5. **Treat all telemetry as untrusted input** — including for the LLM copilot and the LLM rule synthesiser. Schema-validate, never let it reach instruction position raw.
6. **Sign everything.** Updates, models, rules, RL policies, BAS techniques — see ADR-0007 / ADR-0009 / ADR-0010 / P12.
7. **Autonomic actions are bounded** ([ADR-0010](docs/09-adr/0010-autonomic-safety.md)). The autonomic loop never invents new action types at runtime; it ranks playbooks from a fixed allowlist. RL only proposes; deterministic policy gates execute. Do not silently widen the action allowlist.
8. **Auto-rollback is multi-signal-gated** ([ADR-0011](docs/09-adr/0011-self-healing-rollback.md)). Auto-rollback never triggers without severity gate + multi-signal confirmation + verified backup + tenant pre-authorisation + cloud confirmation + 60-second cancel window. Mesh-elected fallback coordinators are read-only with respect to destructive actions.
9. **Federation is Byzantine-robust.** Any change to the aggregation algorithm or contribution caps requires a new ADR.
10. **BAS execution is sandboxed.** P17 may only run techniques from the curated library against canary scope. The mutation engine cannot synthesise novel attacks.
11. **Apollo is a separate repo, lab-only** ([ADR-0012](docs/09-adr/0012-apollo-scope.md)). Apollo crates must NEVER appear in this Artemis workspace. CI invariant `hard-rules-scan` enforces this. Apollo's outputs reach Artemis only via the sandboxed, human-reviewed pipeline.
12. **P14 tier ladder is explicit** ([ADR-0013](docs/09-adr/0013-active-defense-tiers.md)). Tiers 4 (NAC neutralisation) and 5 (escalate to authority) require per-scope opt-in, multi-signal confirmation, 60-second cancel window, and admin notification. NAC connectors implement the `NacConnector` trait; deny actions return reversible tokens.

## When in doubt

- Re-read the relevant pillar doc.
- If a decision feels architectural, write an ADR rather than encoding the choice silently.
- Ask the project owner; do not guess on legal, privacy, or licensing.

## Tools and conventions

- Language: Rust for sensors + daemon + control plane services. TypeScript + Next.js for console + browser extension.
- Linter / formatter: `cargo fmt` + `cargo clippy -D warnings`; `pnpm lint`; `markdownlint` on docs.
- Test layout: unit tests next to code; integration in `tests/` per crate; end-to-end in `e2e/` at workspace root.
- Threat-model updates: any new component or external integration triggers a threat-model review (`docs/01-threat-model.md`).
