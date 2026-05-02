# 26 — Customer Lifecycle

End-to-end flow from "we want Artemis" through "we're done with Artemis." Covers onboarding, daily operation, change events, and clean offboarding.

## Stages

```
Discovery → Trial → Onboarding → Steady-state → Change events → Offboarding
```

## Stage 1 — Discovery

- Inbound: customer finds Artemis (web, referral, design-partner intro).
- 30-min intro call: who they are, what they protect, what their constraints are.
- Decision: trial-yes / not-now / never. Recorded.

## Stage 2 — Trial (≤ 30 days, free)

Pre-flight checks the customer must pass:
- They have at least one OS in our supported set.
- They have a tenant admin who can install software / change network rules where needed.
- They have somewhere to receive alerts (email DL, Slack/Teams, ticketing system).

Trial scope:
- One tenant created in Artemis control plane.
- Per-tenant region pin (US-East / EU-West / etc.).
- Up to 50 endpoints free; throttled above.
- Pillars enabled: P1, P2, P3, P4, P5, P7, P10, P13. Phase-1 product cut.
- Active Defense (P14) Tier 0–2 only during trial; Tiers 3–5 require legal sign-off + paid plan.

Trial exit:
- Customer converts to paid (Standard / Plus / MDR).
- Customer leaves: full data deletion within 30 days; cert revocation + KMS key destruction documented in offboarding runbook.

## Stage 3 — Onboarding (week 1 of paid)

Day 1 (kickoff call):
1. Sign MSA + DPA + (if applicable) BAA.
2. Walk through `docs/01-threat-model.md` to confirm scope and consent.
3. Choose data-residency region; choose pillar set; choose tier-policy per scope; choose authority chain for Tier 5.
4. Connect identity provider (Entra/Okta/Google) for P10.
5. Generate enrolment token, distribute to customer's IT lead.

Day 2–7:
1. Customer rolls out the agent to a pilot subset (~10 hosts).
2. Joint review of first 48 h of telemetry to tune rules / canaries / intent templates.
3. Connect ticketing / Slack / Teams / PagerDuty as alert sinks.
4. Deliver first executive PDF (P13) at end of week 1 even with thin data.

Onboarding success criteria:
- Heartbeats from ≥ 90% of intended fleet.
- Zero open Critical alerts older than 24 h (or all triaged).
- Customer admin has logged into the console at least 3 times.
- Customer signed a per-scope policy for Tier 4/5 if they want them.

## Stage 4 — Steady-state operation

Cadence:
- Customer-side: daily console check (or alert-driven).
- Artemis-side: weekly QBR (quarterly business review for larger tenants).
- Monthly: executive PDF; ATT&CK heatmap; coverage report from BAS.
- Quarterly: tier-policy review; intent-template review; design-partner-only deeper sync.

Updates (per `docs/07-deployment-and-ops.md`):
- Stable channel: fortnightly.
- Beta channel (opt-in): weekly.
- Major versions: handled per `docs/28-versioning-and-compatibility.md`.

Knowledge-bundle updates (rules / models / playbooks):
- Pulled by agents on directive or schedule.
- Customer can pin a version (`knowledge_pins` table — see `samples/migrations/postgres_001_init.sql`).

## Stage 5 — Change events

| Event | What we do |
|---|---|
| New device joins | Auto-enrol if token valid; fleet inventory updated; baseline starts |
| Device leaves | Cert revoked; tombstone retained 30 d for forensics |
| New admin added | OIDC + MFA enforced; onboarding email; audit event |
| Admin removed | All sessions revoked; audit event |
| Identity provider changed | New connector; old connector quarantined; consent re-confirmed |
| Region migration | Tenant data ported to new region; downtime window communicated |
| New tenant scope (e.g., new office) | Per-scope tier policy added; authority chain extended |
| Pillar enabled / disabled | Audit event; rule pack reloaded; agent restart not required |
| Compliance audit (auditor-mode) | Time-bounded read-only access; signed evidence-bundle export |

## Stage 6 — Offboarding

Triggered by: contract end, customer-initiated termination, or non-payment after grace period.

Day 0 (notice received):
1. Grace period begins (30 days unless customer accelerates).
2. New events still ingest; new alerts still fire.
3. Reporting service exports a final compliance bundle if requested.

Days 1–30:
1. Customer chooses: download all telemetry archive (signed), or skip.
2. Customer revokes their identity-provider connector(s).
3. Customer chooses: keep evidence/audit logs for the legal floor (7 y default), or delete now.

Day 30 (final cutover):
1. Agents disabled remotely (heartbeat denial; cert revoked).
2. Customer-held BYOK keys destroyed by them; we cannot decrypt remaining blobs.
3. Tenant Postgres schema dropped; tenant ClickHouse DB dropped.
4. Tenant Memgraph DB dropped.
5. Federation aggregator forgets the tenant's contributions (per round-key destruction).
6. Audit log entries retained per legal floor; otherwise purged.
7. Signed offboarding receipt delivered: hash-chained list of every tenant artefact + its disposition.

Day 30+:
- Audit log retained per legal-floor agreement only.
- Account marked offboarded; cannot be re-enrolled without a fresh signup.

## Hard rules across the lifecycle

- Customer data never leaves the agreed region (per ADR-0006).
- Customer-held BYOK keys are not held by Artemis at any point.
- Tenant pseudonyms cannot be re-linked by Artemis without an explicit, audited customer grant.
- Offboarding is honoured even if billing is in dispute; the dispute resolves separately.
- Right-to-erasure (GDPR Art. 17) requests are honoured per individual user, not just whole-tenant.
