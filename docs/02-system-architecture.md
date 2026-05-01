# 02 — System Architecture

## High-level

```
┌──────────────────────── Customer Endpoint ────────────────────────┐
│                                                                   │
│  ┌─ Sensor (per-OS) ─────────────────────────────────────────┐    │
│  │ Linux:   eBPF (aya) + LSM hooks                           │    │
│  │ Windows: ETW + minifilter + AMSI + WFP                    │    │
│  │ macOS:   Endpoint Security framework + Network Extension  │    │
│  │ Browser: WebExtension (MV3) — DOM, agent tool-call audit  │    │
│  └────────────────────────┬──────────────────────────────────┘    │
│                           │ shared-mem ring buffer                │
│  ┌─ Userland Daemon (Rust core) ────────────────────────────┐    │
│  │  • Rule engine (Falco-style YAML)                         │    │
│  │  • Local ML scorer (ONNX Runtime, certified-robust)       │    │
│  │  • Provenance builder (in-memory rolling graph)           │    │
│  │  • Deception placer (P3)                                  │    │
│  │  • Intent session manager (P4)                            │    │
│  │  • LLM-malware heuristic (P1)                             │    │
│  │  • Supply-chain hooks (P11)                               │    │
│  │  • PQ-sig verifier (P12)                                  │    │
│  │  • Differential-privacy egress filter (P6)                │    │
│  └────────────────────────┬──────────────────────────────────┘    │
│                           │ OTLP/gRPC over mTLS                   │
└───────────────────────────┼───────────────────────────────────────┘
                            │
                            ▼
┌──────────────────── Artemis Control Plane (SaaS, multi-tenant) ───┐
│                                                                   │
│  Ingest API ──► Kafka ──► Detection Engine (rules + ML)           │
│                                       │                           │
│                                       ▼                           │
│                              Alerts → Alert Router                │
│                                       │                           │
│                              ┌────────┼────────┐                  │
│                              ▼        ▼        ▼                  │
│                        Provenance  Active   LLM SOC-Copilot       │
│                        Graph DB    Defense  (Anthropic API)       │
│                        (Memgraph)  Agent                          │
│                                    (P14)                          │
│                                                                   │
│  Tenant Console (Web UI, Next.js)                                 │
│  Reporting Service (P13) → PDF / ATT&CK heatmap / SOC2 evidence   │
│  Identity Connector (P10) — Okta, Entra, Google Workspace         │
│  Federated IoC Exchange (P6) — CKKS encrypted                     │
│  Admin / RBAC / Billing                                           │
└───────────────────────────────────────────────────────────────────┘
```

## Autonomic loop (MAPE-K)

The platform is structured as an autonomic system. Each block above maps to a stage of the IBM MAPE-K loop:

- **Monitor** — sensors + ingest pipeline (P1, P2, P10, P18, P19, P20, P21).
- **Analyze** — detection engine + ML scorers + provenance graph (P7, P8).
- **Plan** — playbook ranker + RL policy (P5 narration, P16 selection).
- **Execute** — Active Defense Orchestrator (P14) + Self-Healing Controller (P15).
- **Knowledge** — signed Knowledge store: rules, models, deception memory, attack-graph cache, BAS results (P16, P17).

The autonomic-safety contract ([ADR-0010](09-adr/0010-autonomic-safety.md)) bounds what Plan and Execute may do without humans, and how the Knowledge store is protected from poisoning. The rollback-safety contract ([ADR-0011](09-adr/0011-self-healing-rollback.md)) bounds destructive auto-actions.

## Core services

| Service | Responsibility | Tech |
|---|---|---|
| Ingest | Receive OTLP events from agents, validate device cert, push to Kafka | Rust + tonic |
| Detection Engine | Rule + ML scoring, alert emission | Rust + ONNX Runtime + Wasm rule sandbox |
| Provenance Graph | Build/query causal graphs per tenant | Memgraph |
| LLM Copilot | Plain-English alert explanations, triage suggestions | Anthropic SDK + Claude Sonnet (cached system prompts) |
| Active Defense | Containment playbook executor (P14, gated) | Rust + signed playbooks |
| **Self-Healing Controller (P15)** | Watchdog re-deploy, snapshot rollback, secret rotation, attestation reconciliation, mesh fallback coordination | Rust |
| **Knowledge Store (P16)** | Versioned, signed store of rules, models, RL policies, attack-graphs, deception memory | Rust + Postgres (versioned) + signed manifests |
| **Rule Synthesiser (P16)** | LLM-driven rule drafting from closed incidents → human review queue | Rust + Claude API |
| **Federation Aggregator (P16)** | Byzantine-robust aggregation of encrypted gradients across tenants | Rust + OpenFHE |
| **BAS Orchestrator (P17)** | Schedules + runs curated attack techniques against canary scope | Rust + sandboxed runners |
| **Email Connector (P18)** | Microsoft 365 / Google Workspace API integration; URL detonation; attachment microVM | Rust + Firecracker |
| **NDR Sensor (P19)** | Tap/SPAN appliance + cloud-VPC mirror collector | Rust + DPDK / netlink |
| **Cloud Workload Sensors (P20)** | Container annotation, K8s admission webhook, image scanner, cloud-config sweeper | Rust + Go (K8s client) |
| **LLM Firewall (P21)** | Sidecar / SDK / gateway inspecting AI-app traffic | Rust |
| **Hunting Service (P22)** | Notebook UI, IR runbook engine, backup connectors | Next.js + Rust workers |
| Reporting | Dashboards + PDF + compliance bundles | Next.js + Grafana + Pandoc |
| Identity Connector | OAuth/SAML federation, ITDR signals | Rust |
| Federated IoC | Encrypted aggregate signals across tenants | OpenFHE (CKKS) |

## Data flow — happy path

1. Sensor emits an event (e.g. `process.exec`) into the local ring buffer.
2. Daemon enriches (parent chain, hash, signer), runs rules + local ML.
3. If verdict = clear, daemon DP-filters and batches events.
4. Batches go OTLP/gRPC over mTLS to ingest.
5. Ingest writes to Kafka; detection engine subscribes.
6. Detection engine runs cloud-tier rules + provenance correlation.
7. Alert is emitted, routed to console + LLM copilot for narrative.
8. Reporting aggregates daily/weekly.

## Data flow — alert path

1. Detection engine emits an alert.
2. LLM copilot generates plain-English explanation (with prompt caching).
3. Alert + explanation appears in console; pager goes to on-call if severity ≥ HIGH.
4. Operator clicks "contain" → Active Defense plays an approved playbook (kill process, revoke session, isolate host).
5. P14 escalation actions (abuse report, takedown) require a second approval and are blocked unless `legal_clearance.enabled = true` for the jurisdiction.

## Failure modes

| Failure | Effect | Mitigation |
|---|---|---|
| Network down | Agent buffers locally up to 24 h | On-disk encrypted spool |
| Control plane outage | Local rules still fire; deception still trips | Agent autonomy budget |
| Detection model drift | False positive surge | Canary tenant + rollback |
| LLM provider down | Copilot features degrade to template explanations | Multi-provider abstraction (Claude → GPT → local Llama) |
| Tenant key compromise | Per-device cert revocation within 60 s | Short-lived enrolment tokens |

## Component sizes (initial estimate)

- Sensor binary: 8–15 MB per OS.
- Daemon RAM at idle: <150 MB.
- CPU overhead: <2% on a 4-core machine under normal use.
- Daily uplink: <50 MB/endpoint at idle, <500 MB during active incident.
