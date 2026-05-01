# ADR-0006 — Multi-tenant data isolation model

## Status
Accepted (Phase 0).

## Context
Two prevailing patterns:
1. **Row-level isolation** — a single table with `tenant_id` column, enforced via row-level security or app-level filters.
2. **Schema- or DB-per-tenant isolation** — each tenant gets its own DB schema (Postgres) or DB (ClickHouse, Memgraph).

Trade-offs: row-level is operationally simpler at scale but a single bug = cross-tenant exposure. Schema-per-tenant is more secure but increases ops cost.

## Decision
- **Postgres (config, RBAC, audit):** schema-per-tenant.
- **ClickHouse (events, alerts):** DB-per-tenant.
- **Memgraph (provenance):** DB-per-tenant.
- **Object storage (raw blobs):** prefix-per-tenant + per-tenant KMS key (BYOK).

## Rationale
- For a security product, the cost of a cross-tenant leak is existential.
- Schema/DB separation gives explicit, auditable isolation; queries cannot accidentally cross tenants.
- Operational overhead is manageable with standard automation; we accept the cost.

## Consequences
- Schema migrations must run per-tenant (we provision a fan-out runner).
- Per-tenant dashboards in Grafana use templated queries.
- Onboarding a new tenant takes ~30 s instead of being instant.
