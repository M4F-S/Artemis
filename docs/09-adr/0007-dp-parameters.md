# ADR-0007 — Differential privacy parameters

## Status
Accepted (Phase 0).

## Context
P6.1 commits to differential privacy on egressed event categories. We must pick concrete ε budgets per category, with a defensible rationale.

## Decision
Initial budgets (per-user, per-day, total over a 30-day rolling window):

| Category | ε / day | Mechanism |
|---|---|---|
| `process.exec` | 1.0 | Randomised response on category labels; noise on aggregate counters |
| `file.canary-touch` | unbounded (deterministic) — these are alerts | exempt |
| `net.connect` | 1.0 | RR on destination ASN buckets; Laplace on counts |
| `kernel.bpf-load` | unbounded — security-critical | exempt |
| `auth.local` | 0.5 | RR on outcome categories |
| `agent.health` | 0.1 | counters only |
| `browser.dom-prompt-pattern` | 1.0 | RR on pattern category |
| `incident.*` | exempt | alert / playbook events bypass DP |

Total per-user-day ε: ~3.6 (excluding exempts). Privacy loss budget is monitored centrally; tenants in `incident-mode` may temporarily lift DP for a named scope (audit-logged).

## Rationale
- Security-critical events (canary tripwires, bpf loads, alerts) must not be noised — losing them silently would defeat the product.
- Behavioural / aggregate categories are noised so the cloud cannot reconstruct individual behaviour with high fidelity from a single user.
- 30-day rolling budget caps long-term composition.

## Consequences
- Detection sensitivity for purely statistical anomalies is reduced; we compensate with rule-based and graph-based detection upstream.
- Tenants in regulated industries (HIPAA / GDPR sensitive deployments) get tighter defaults.
