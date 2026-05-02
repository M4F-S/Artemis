# 27 — Internal Incident Response

What we do when **Artemis itself** is the target. We sell endpoint security; an incident in our own stack is existential. This doc is the runbook.

## Scope

Covers:
- Compromise of Artemis control-plane infrastructure.
- Compromise of Artemis source code, build pipeline, or signing keys.
- Compromise of an Artemis staff account (PAM / cloud / GitHub / LLM-provider).
- Insider abuse by Artemis staff.
- Compromise of Apollo (separate repo, but tightly related — see ADR-0012).
- Compromise of a customer tenant via *our* mistake (versus their breach we detected).

Out of scope (handled elsewhere):
- Customer-side breaches detected by Artemis. Those are normal product flow.
- Apollo-engagement scope failures. Those are governed by per-engagement SoW.

## Severity classes

| Class | Examples | Initial response |
|---|---|---|
| SEV-1 | Signing key compromise; cross-tenant data leak; control-plane RCE | War-room within 30 minutes; CEO + counsel on call |
| SEV-2 | Single-tenant data leak; staff account compromise; LLM-provider key theft | War-room within 2 hours |
| SEV-3 | Internal-tooling compromise without customer impact | Standard IR within 24 hours |
| SEV-4 | Suspicious activity, possible compromise, no proof | Investigate within 48 hours |

## On-call structure

- 24/7 on-call rotation; 2 regions.
- Primary on-call → secondary → engineering manager → CTO → CEO.
- War-room channel auto-created on SEV-1/2; PagerDuty escalates if unacked in 5 min.
- Counsel paged on any SEV-1, on any incident touching customer data, and on any law-enforcement-touching event.

## Response phases

### Phase A — Detect (always running)

- Internal observability stack alerts on:
  - Unauthorised access to control-plane services.
  - Anomalous patterns in our own audit log (the same hash-chained log we sell to customers, with the same controls).
  - Failures in CI hard-rules-scan (drifts toward dual-use code, Apollo dep leaking into Artemis).
  - Signing-key usage outside scheduled release windows.
  - Federation-aggregation outliers (per ADR-0010 / P16).
- We use Artemis on Artemis. Eat our own dog food: deploy our agent on staff laptops + control-plane infrastructure.

### Phase B — Triage (within 30 minutes of detection)

1. Assign an incident commander (separate from technical responder).
2. Open a private war-room channel; add: primary on-call, secondary, engineering manager, counsel (if SEV ≤ 2).
3. Classify severity.
4. Decide: contain now (may degrade service) vs. observe-and-collect (may risk further damage). Default: contain.
5. Activate communication protocol (see Phase E).

### Phase C — Contain (action depends on class)

#### Signing key compromise (SEV-1)
1. Immediately revoke the compromised key in the public revocation list.
2. Push an emergency knowledge-bundle update signed by the backup key (we hold a sealed offline backup signing key; bringing it online is an irreversible event with its own runbook).
3. Pause all releases.
4. Notify customers within 4 hours, before any rumour reaches them.

#### Cross-tenant data leak (SEV-1)
1. Identify scope: which tenants, what data, what window.
2. Block the leak path immediately.
3. Begin forensic capture (provenance graph + audit log + cloud audit log).
4. Notify affected customers within 24 hours (or sooner per regulation: GDPR 72 h max).
5. Notify regulators where required.

#### Control-plane RCE (SEV-1)
1. Isolate affected services via cluster controls.
2. Snapshot for forensics; do not just terminate.
3. Failover to passive region if customer impact warrants.
4. Begin root-cause investigation.

#### Staff account compromise (SEV-2)
1. Revoke all sessions, rotate hardware key, force re-enrolment.
2. Audit every action by that account in the last 90 days.
3. If admin account: assume worst case until proven otherwise.

#### Apollo compromise (SEV-1, irrespective of customer impact)
1. Disable Apollo CI immediately.
2. Audit every Apollo binary released in the last 30 days.
3. If any Apollo content has reached customer tenants (it shouldn't, per ADR-0012, but verify): treat as a SEV-1 customer event simultaneously.
4. Counsel reviews regulatory exposure (ECCN, EU Dual-Use 2021/821, Wassenaar).

### Phase D — Eradicate + Recover

- Patch the root cause; do not just paper over the symptom.
- Rotate every secret that the compromised entity could have accessed (default: rotate the ring + the next ring out).
- Restore from known-good backup if needed.
- Re-enable services in dependency order; canary first.

### Phase E — Communicate

- Internal: war-room channel + hourly status updates + post-incident all-hands within 7 days.
- Customers: per the matrix below.
- Regulators: per each jurisdiction's notification clock (GDPR 72 h; some US states 30 d; NIS2 24 h initial / 72 h detailed).
- Public: status page + blog post for SEV-1; status page only for SEV-2 with customer impact.

| Customer impact | Channel | Timing |
|---|---|---|
| None confirmed | None | n/a |
| Possible | Email tenant admins; status page note | < 24 h of suspicion |
| Confirmed, low impact | Email + console banner | < 24 h of confirmation |
| Confirmed, high impact (data leak / outage > 1 h) | Email + console banner + phone for top tenants | < 4 h of confirmation, even if details are still unfolding |

### Phase F — Learn

- Blameless post-mortem within 14 days. Public summary for SEV-1 incidents.
- Action items tracked to closure; CI invariants added where applicable.
- Threat model updated; new ADR if architectural changes made.
- Customer-facing transparency report annually (incident counts, classes, mean response times).

## Drills

- Tabletop exercise quarterly; one SEV-1 scenario per drill.
- Annual chaos exercise on a passive region (controlled outage + recovery).
- Annual third-party red-team against control plane.
- Annual signing-key recovery drill (verify the backup process actually works).

## Communications templates

Maintained in `ops/ir-templates/` (created during Phase 5 ops work):
- Customer "we detected an issue" email
- Customer "what we did, what's next" email
- Regulator notification (per jurisdiction)
- Status-page update
- Blog post outline
- Post-mortem outline (public)
- Post-mortem outline (internal, full detail)

## Hard rules

- Never destroy evidence to make a problem go away. Forensics first; cleanup second.
- Never communicate with customers without counsel review for SEV-1.
- Never mislead about scope; under-promise and over-deliver in updates.
- Never blame named individuals in public communications; learn, don't shame.
- Never ship a fix that bypasses a CI invariant; fix the invariant + the underlying issue.
- The on-call has authority to escalate to CEO + counsel; no manager may override that.
