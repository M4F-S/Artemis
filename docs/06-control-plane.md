# 06 — Control Plane

## Deployment

- Multi-tenant SaaS on Kubernetes (GKE primary, EKS secondary for failover).
- Region pinning: US-East / US-West, EU-West (Frankfurt), AP-South.
- All state region-pinned; no cross-region replication of customer data without explicit consent.

## Components

```
                                        ┌── alert-router
                                        │
ingest ─► kafka ─► detection-engine ────┼── provenance-builder
                                        │
                                        └── llm-copilot
                                        
identity-connector ─► kafka                  reporting-service
                                              compliance-export
federated-ioc-aggregator ──┐                  active-defense-orchestrator
                           │                  
                           └── tenant-model
                              (per-tenant
                               OFHE keys)
```

| Service | Tech | Notes |
|---|---|---|
| ingest | Rust + tonic | mTLS; per-tenant rate limit; OTLP |
| kafka | Confluent / Redpanda | per-tenant topic partitioning |
| detection-engine | Rust + ONNX Runtime + Wasm rule sandbox | rules in Wasm so authors can ship updates without redeploy |
| provenance-builder | Rust → Memgraph | one Memgraph cluster per region per shard |
| llm-copilot | Rust + Anthropic SDK | prompt caching mandatory |
| alert-router | Rust | webhooks, email, PagerDuty |
| reporting-service | Next.js + Pandoc + Grafana embed | PDFs / dashboards |
| compliance-export | Rust | WORM-stored evidence bundles |
| active-defense-orchestrator | Rust | signed playbooks; legal-clearance gate |
| identity-connector | Rust | OAuth/SAML to Entra/Okta/Google |
| federated-ioc-aggregator | Rust + OpenFHE | CKKS aggregation |

## Storage

- **ClickHouse** — events + alerts (columnar, fast aggregations).
- **Postgres** — config, RBAC, billing, audit.
- **Memgraph** — provenance graph.
- **R2 / S3** — raw blob (BYOK encrypted).
- **Redis** — short-term caches and rate limit state.

## Auth

- Customer admins: OIDC SSO to Entra/Okta/Google with mandatory MFA. No local accounts.
- Agents: per-device cert issued at enrolment; cert rotation yearly; revocation list refreshed every 60 s by agents.
- Internal staff: SSO + hardware key + Just-In-Time access via PAM tooling. All access audited.

## Tenant isolation

- DB: per-tenant schema in Postgres; per-tenant DB in ClickHouse; per-tenant Memgraph database.
- Compute: shared services with strict tenant ID propagation (CI invariant).
- Per-tenant secrets in a per-tenant KMS partition (cloud-provider KMS).

## Multi-tenant rate limits

Concrete defaults per tenant tier (override per-tenant in admin console):

| Tier | Events/sec | LLM tokens/mo | NAC actions/5min | Tier-5 reports/day |
|---|---|---|---|---|
| Trial | 5,000 | 50,000 | 1 | 5 |
| Standard | 20,000 | 500,000 | 3 | 25 |
| Plus | 50,000 | 2,000,000 | 5 | 50 |
| MDR | 100,000 | 5,000,000 | 10 | 100 |

Mechanism:
- Token-bucket per tenant per service.
- `THROTTLE` ack returned to ingest when bucket empty (per `samples/control_plane.proto`).
- Detection engine isolates per-tenant CPU / memory budget via cgroups (one tenant cannot starve another).
- LLM copilot per-tenant per-month token budget; degrades to template explanations when exceeded.

## Internal observability

- All control-plane services emit OTLP traces + metrics + structured logs to a separate Artemis-internal observability stack (NOT customer's data).
- Stack: Grafana + Tempo (traces) + Mimir (metrics) + Loki (logs) on the same K8s cluster, isolated namespace.
- SLOs:
  - Ingest p99 < 500 ms.
  - Alert end-to-end p99 < 60 s.
  - Console TTI < 2.5 s.
  - LLM copilot p99 < 8 s; cached p99 < 1 s.
  - Knowledge-bundle pull p99 < 5 s.
  - NAC action dispatch p99 < 2 s.
- Error-budget policy: SLO violations in 30-day window pause feature releases; only bug fixes ship until budget restored.
- Distributed tracing: every request from agent → ingest → detection → alert-router → console carries a trace ID; trace propagation via OpenTelemetry baggage.
- We use Artemis on Artemis: deploy our own agent on staff laptops + control-plane infrastructure (per `docs/27-internal-incident-response.md`).
- Internal alerts (the kind we don't sell — e.g. "Kafka lag > 1 min") go to PagerDuty for the on-call.

## Disaster recovery

- Per-region active/passive within cloud; per-tenant config and rule state replicated to a passive region.
- RTO 1 h for control plane; RPO 5 min for state, 0 for raw blobs (BYOK customer-owned).
- Quarterly DR drill: controlled outage of primary region; passive region picks up traffic; runbook in `ops/dr/` (created in Phase 5 ops work).
- Annual signing-key recovery drill (per `docs/27-internal-incident-response.md`).

## Vendor lock-in mitigation

- Storage: ClickHouse + Postgres are open-source; we deploy them ourselves rather than relying on cloud-managed lock-in (initially).
- Kafka: Redpanda compatible.
- LLM: provider abstraction in `llm-copilot` so we can swap or run multi-provider.
