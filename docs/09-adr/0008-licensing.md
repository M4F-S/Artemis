# ADR-0008 — Licensing strategy

## Status
**Deferred** (Phase 0). Repo is default-closed until decided.

## Context
Three viable paths:
1. Open source (Apache-2 / MIT) — maximises adoption, hardens via community contribution, harder to monetise core.
2. Source-available (BSL / SSPL / Elastic v2) — public source, restricted commercial use; common path for security startups (e.g. SentinelOne kept core closed; Falco is OSS).
3. Closed source — maximum control over IP and pricing.

## Decision
Pending. Default behaviour:
- Repository is private.
- No license file committed.
- All contributors sign a CLA template (drafted, not yet signed).

## Considerations to resolve
- Distribution model: agent-on-customer-machine implies binary distribution regardless; the question is mostly about the source.
- Specific components that benefit from being OSS even if the core isn't: rule format (so detection authors can ship), MV3 extension (for trust), CKKS aggregator (for verifiability).
- Federated IoC exchange might benefit from a non-profit / consortium structure.

## Action
Re-evaluate at end of Phase 1 with go-to-market data and design-partner feedback.
