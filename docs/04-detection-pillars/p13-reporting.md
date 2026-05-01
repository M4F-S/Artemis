# P13 — Reporting & Dashboards

**User-added pillar.** SMBs buy because they need to *show* security posture (cyber insurance, customer questionnaires, SOC 2 audit), not just have it. Reporting is a primary differentiator, not an afterthought.

## Audiences

| Audience | Output | Frequency |
|---|---|---|
| End user | Inline alert explanations, "why was this blocked?" | Real-time |
| IT lead / MSP analyst | SOC dashboard, alert queue, playbooks | Live |
| Owner / CFO | Executive summary PDF | Weekly + monthly |
| Auditor | Compliance evidence bundles | On-demand |
| Insurer | Posture report | Quarterly |

## Live SOC dashboard

- Top of fold: open alerts, open incidents, MTTR trend, active intent sessions, agent health.
- ATT&CK heatmap colour-coded by detection coverage and recent activity per technique.
- Per-host drilldown: last 7 days timeline + provenance graph snapshot.
- "Who needs attention now" panel: ranked list of users / hosts by risk score.

## Executive summary (weekly / monthly PDF)

LLM-generated narrative (P5) on top of structured data:

- "How was the company attacked this period?" — bucketed by adversary tier and ATT&CK tactic.
- "What did Artemis stop?" — concrete blocked actions, with examples redacted appropriately.
- "What changed?" — new hosts, new identities, new packages, new policy decisions.
- "What needs your attention?" — top 3 actionable items, each with a 1-click "do it" path.
- Comparison vs. previous period and vs. anonymised peer benchmark (federated, P6).

PDF layout via Pandoc + a custom LaTeX template with brandable accent colour and the customer's logo.

## Compliance evidence bundles

For each control set (SOC 2, ISO 27001, HIPAA, PCI-DSS v4, NIS2, DORA), Artemis maintains a mapping:

- Control → which telemetry/alert types prove it → query → exhibit.
- Auditor-mode export: all exhibits packaged with WORM-stored provenance (signed, timestamped).
- Time-bounded queries (e.g., "all admin logins for Q2 2026").

## Posture report (insurer-facing)

- Standardised score model (separate from internal risk score) aligned with insurer questionnaires (Coalition / Travelers / Chubb formats).
- Auto-fills common questionnaires by exporting to their schemas (where supported).

## Custom reports

- SQL-via-Console interface against pseudonymised event store.
- Saved queries become scheduled reports.

## Privacy in reporting

- All outbound reports respect the tenant's pseudonymisation policy.
- The customer admin can re-link pseudonyms before export if needed (audited).

## API access

- Read-only REST + GraphQL endpoints for SIEM ingest (Splunk, Sentinel, Elastic).
- Webhooks for alert-events into Slack, Teams, PagerDuty.
