# 28 — Versioning and Compatibility

How Artemis evolves without breaking customers. Covers product semver, agent ↔ control-plane wire compatibility, knowledge bundle versioning, schema evolution (event, alert, provenance, Postgres, ClickHouse), and the deprecation process.

## Product version

**SemVer.** `MAJOR.MINOR.PATCH`.

- `MAJOR`: breaking changes to public surfaces (CLI, console API, on-the-wire protocol). We aim for ≤ 1 major version per year.
- `MINOR`: new features, additive only.
- `PATCH`: bug fixes only.

Pre-1.0:
- `0.MINOR.PATCH` while we're in Phases 1–4. Breaking changes allowed in MINOR with explicit upgrade notes.
- `1.0.0` ships at the end of Phase 4 (hardening + robust ML). After 1.0.0, breaking-change discipline is strict.

## Agent ↔ control-plane compatibility

The agent's wire protocol (gRPC, OTLP-shaped) must support **N–2** compatibility:

- Control plane MUST accept agents from the previous two MINOR versions.
- Agents MUST tolerate control-plane responses one version newer (forward-compat for non-critical fields).
- Breaking wire changes go through a 90-day deprecation cycle (see Deprecation below).

How:
- `protoc` deprecation annotations + a CI check that fails any field deletion or type change.
- Bidirectional integration tests in `tests/e2e/` matrix `(agent_version, control_plane_version)` for the support window.

## Knowledge bundle versioning

Knowledge = rules, models, deception templates, intent templates, RL policies, BAS scenarios, NAC connector configs.

- Each bundle has its own SemVer (`rules/v3.4.1`, `models/v0.7.0`, etc.).
- `KnowledgeManifest` carries the active set with signatures (per `samples/control_plane.proto`).
- Tenants can **pin** a bundle version via the `knowledge_pins` table (per `samples/migrations/postgres_001_init.sql`); pinned tenants explicitly opt out of auto-updates for that bundle until they unpin.
- Rolling pins back is always safe (signed manifest stored).
- Forward incompatible bundle changes are MAJOR — they require operator confirmation per tenant before activation.

## Event schema evolution

The most consequential schema. Touched by sensors (WS-B), daemon (WS-C), control plane (WS-D).

Rules:
1. **Field additions**: always allowed. Existing parsers ignore unknown fields (protobuf, standard).
2. **Field deletions**: never. Deprecated fields stay in the schema marked `[deprecated = true]` for at least 2 MAJOR versions; readers must tolerate the field being absent.
3. **Field type changes**: never. Add a new field with a new name; deprecate the old.
4. **Semantic changes** (e.g., a count that used to be per-process now per-thread): require a new field name. Don't change meaning silently.
5. **Top-level taxonomy** (`category` / `subtype`): additions allowed; existing strings frozen.
6. **Schema versioning**: a `schema_version` field at the top of every event identifies the producer version; readers gate behaviour on the version.

Process for any change:
- Open a draft PR to `samples/event.proto` AND `crates/artemis-core/event.rs`.
- Tag WS-B + WS-C + WS-D in CODEOWNERS.
- 72-hour review window (waivable for security-fix events).
- After merge, write entry in `docs/14-session-handoff.md`.

## Alert schema evolution

Same rules as event schema. Plus:
- The `narrative` LLM-generated field is free text; consumers tolerate any change.
- The `attck_techniques` array is additive — removing a technique from the taxonomy is a MAJOR.
- The `verdict` enum follows the standard "add new variants only at the end" rule.

## Provenance graph schema evolution

Memgraph (Cypher). Rules:
- Adding new node labels / edge types: minor.
- Adding new node / edge properties: minor.
- Removing or renaming labels / types / properties: major (90-day deprecation).
- Index changes don't affect schema compatibility but require migration runbook.

## Postgres schema evolution

Per ADR-0006 — schema-per-tenant.

- Migrations versioned `NNN_description.sql`; tracked in `_migrations` table.
- Migration tooling: pick during Phase 1 (refinery / sqlx / sea-orm-migration).
- Per-tenant fan-out runner applies migrations across tenants serially during a maintenance window.
- Backwards-incompatible migrations (column removal) follow expand-contract:
  1. **Expand**: add new column; dual-write.
  2. **Migrate**: backfill; switch reads.
  3. **Contract**: remove old column.
  Each step a separate migration, separate release, separate go/no-go decision.

## ClickHouse schema evolution

- Migrations versioned `NNN_description.sql`; tracked in tenant DB's `_migrations` table.
- Adding columns: cheap (no rewrite).
- Removing columns: expand-contract.
- Changing partition key: not done. Create a new table + materialised view; swap reads when caught up.
- TTL changes: applied per-partition; no data loss without explicit drop.

## Deprecation process

When a public surface (CLI command, REST endpoint, gRPC field, event field, rule schema field) is deprecated:

| Day | Action |
|---|---|
| 0 | Mark deprecated in code + spec; release notes call it out; usage emits a warning event |
| 30 | Customer dashboard shows deprecation banner with remediation link |
| 60 | Email reminder to admins of tenants still using the deprecated surface |
| 90 | Removal in next MAJOR; old surface returns a clear "removed" error pointing at the replacement |

Security-driven deprecations may compress this timeline (e.g., to 7 days for a serious flaw); compression requires CTO + counsel approval.

## Migration tooling

- Schema migrations (DBs): `refinery` or `sqlx::migrate!` (decision in Phase 1).
- Wire-protocol migrations: protoc-gen `--deprecation_check` + integration test matrix.
- Knowledge-bundle migrations: signed manifest; pin / unpin via console (`/v1/knowledge/...`).

## Customer-visible version surfaces

- Agent: `artemis version` shows version + git commit + supported pillars + supported NAC connectors.
- Console: footer shows control-plane version + commit + region.
- API: every response includes a `Server-Version` header.
- Knowledge bundles: shown in console with pin status.

## Customer-facing release notes

- Per stable release: human-readable notes covering changes, deprecations, security fixes, upgrade guidance.
- Stored in `docs/RELEASES.md` (created when first release ships).
- Posted to status page and emailed to admin DLs.
