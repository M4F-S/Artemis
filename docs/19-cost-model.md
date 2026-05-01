# 19 — Cost Model

Rough monthly burn for Phases 1–4 (≈ year 1). Numbers are order-of-magnitude estimates; refine with real vendor quotes.

All figures in USD/month unless noted.

## Phase 1 (Linux MVP, ≈ months 1–3)

| Category | Item | Cost / mo |
|---|---|---|
| Cloud (control plane) | 1 small Kubernetes cluster (GKE Autopilot or EKS) for ingest + detection + DB | $400–800 |
| Cloud (storage) | ClickHouse (self-hosted on cluster) + Postgres (managed small) + 100 GB R2/S3 | $200–400 |
| LLM API | Anthropic Claude (Sonnet, with caching) — minimal Phase 1 use | $100–300 |
| Domains / DNS / TLS | $30 |
| CI minutes | GitHub Actions Linux runners | $200 |
| Email / collab | Workspace, password manager, 1Password / 1Pass | $50 |
| Observability | Self-hosted Grafana + Loki on cluster | included above |
| Misc tools | GitHub Org, Linear / Notion equivalent | $100 |
| **Phase 1 monthly cloud + tooling** | | **~$1,100–1,900** |

Plus optional design-partner compute (a 50-host Linux fleet to test against): $200–500/mo on a few small VMs.

## Phase 2 (Windows + LLM copilot, months 3–5)

Add:
- Windows code-signing EV cert (one-time, ~$300–500/yr, amortise to ~$30/mo).
- Higher LLM spend as P5 ships: $300–600/mo.
- Windows test infrastructure (a few VMs in the lab): $150/mo.

**Phase 2 monthly: ~$1,600–2,800**

## Phase 3 (macOS + browser + privacy, months 5–7)

Add:
- Apple Developer Program: $99/yr (~$8/mo).
- macOS code-signing infra: minimal incremental.
- Browser extension publishing fees: one-time, negligible.
- DP infrastructure: included.
- Federated IoC pipeline: includes OpenFHE compute (CPU heavy); ~$200/mo at small scale.

**Phase 3 monthly: ~$2,000–3,400**

## Phase 4 (Hardening + robust ML, months 7–9)

Add:
- ML training compute: spot GPU on RunPod / Lambda Labs, batch jobs ~$300–800/mo.
- Threat-intel feeds (optional commercial): $0–500/mo.
- BAS lab infrastructure: $100–300/mo.

**Phase 4 monthly: ~$2,500–5,000**

## Year-1 cumulative cloud + tooling

Roughly **$25k–40k** for the platform infrastructure across the year. Add legal / compliance (SOC 2 prep, counsel on ADR-0009 + ADR-0012): $20k–60k depending on counsel and audit firm.

## People cost (separate from infrastructure)

The dominant cost is people, not cloud. Indicative ranges (Berlin / EU rates, gross to contributor):

| Role | Hourly (junior) | Hourly (mid) | Hourly (strong) |
|---|---|---|---|
| Sensor / backend colleague | €15–25 | €30–45 | €50–70 |
| Console colleague | €15–25 | €30–40 | €45–60 |
| Detection author | €15–25 | €30–40 | €45–60 |
| Tech lead (R1) | n/a | n/a | €60–100 |
| Specialist (Win/macOS/ML) | n/a | €40–60 | €70–110 |

Rough year-1 people cost at the comfortable team size (5–8 colleagues at 20 hrs/week, mixed seniorities): **€80k–200k** depending on experience mix and whether you compensate with cash, equity, or hybrid (ADR-0008 still pending).

## Phases 5–7 (year 2)

Cloud cost grows superlinearly with tenant count, sublinearly with feature count. At 5 design partners and ~250 endpoints under management: cloud cost in the **$3k–8k/month** band.

Apollo (Phase 6+) adds a small lab footprint: $200–500/mo for the offensive-test fleet.

P7 (XDR domain expansion) adds:
- Email connector: minimal cost, mostly API call rate against M365 / Workspace (per-tenant).
- NDR appliance hardware (if shipped): one-time per site.
- CWPP collectors: included in K8s tenant clusters.
- LLM firewall: per-tenant compute, scales with their AI-app traffic.
- Hunting / DFIR: storage-heavy; backup integrations are pass-through.

## Pricing model (back of envelope)

If pricing as designed in `docs/07-deployment-and-ops.md`:
- Standard: $5–8/endpoint/month.
- Plus (P9 + P14 + autonomic): $10–15/endpoint/month.
- MDR add-on: $20+/endpoint/month.
- Apollo Pro (when SKU launches): $25k+ per engagement (pricing TBD; ADR-0012 path).

Break-even on cloud + tooling at ~250 endpoints under management. Break-even including people ~ 1k–2k endpoints under management, which Phase 7 should reach with 5–10 design partners.

## What this model is NOT

- It is not a forecast of revenue or customer count.
- It is not an exhaustive accounting (no rent, no taxes, no equipment, no offsite events).
- It is a sanity check that "do we have a runway problem?" answers honestly.

If your runway is < 9 months at the Phase-1 number above, talk to the owner before kickoff — there's a faster, leaner Phase-1 we can scope.
