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

- Ingest: per-tenant tokens-per-second, configurable.
- Detection engine: per-tenant CPU / memory budget; isolation prevents one noisy tenant degrading others.
- LLM copilot: per-tenant per-month token budget; degrades to template explanations when exceeded.

## Internal observability

- All control-plane services emit OTLP to a separate Artemis-internal observability stack (NOT customer's data).
- SLOs:
  - Ingest p99 < 500 ms
  - Alert p99 < 60 s end-to-end
  - Console TTI < 2.5 s
- Error budget policy: violations in 30-day window pause feature releases.

## Disaster recovery

- Per-region active/passive within cloud; per-tenant config and rule state replicated to a passive region.
- RTO 1 h for control plane; RPO 5 min for state, 0 for raw blobs (BYOK customer-owned).

## Vendor lock-in mitigation

- Storage: ClickHouse + Postgres are open-source; we deploy them ourselves rather than relying on cloud-managed lock-in (initially).
- Kafka: Redpanda compatible.
- LLM: provider abstraction in `llm-copilot` so we can swap or run multi-provider.
