# ADR-0012 — Apollo offensive-testing companion: scope and isolation

## Status
Accepted (Phase 0).

## Context

The owner has approved building **Apollo** — a Kali-Linux-based offensive-testing companion to Artemis (`docs/22-apollo-offensive-companion.md`). The decided positioning is "internal lab + future SKU for advanced customers." This ADR locks Apollo's scope so the dual-use nature is bounded in code, not just in marketing.

Apollo offers exactly the kind of capability that, mis-scoped, becomes a regulatory and ethical problem (CFAA, EU Dual-Use Regulation 2021/821, Wassenaar Arrangement on intrusion software). Building Apollo carefully now is much easier than retrofitting safety after misuse.

## Decision

Apollo is bound by the following non-negotiable contracts:

### 1. Repository isolation
- Separate repository: `m4f-s/apollo`.
- Separate access control; default-deny until a contributor is explicitly added.
- No shared CI org, no shared package registry, no shared cache with the Artemis defensive product.
- Apollo does not depend on any Artemis crate. Artemis does not depend on any Apollo crate.

### 2. Target-allowlist enforcement (in code)
Every Apollo run requires:
- A signed `targets.yaml` declaring all hosts / IPs / networks the run is allowed to touch.
- A signed engagement authorisation (PDF + hash) covering the engagement window.
- An engagement window timestamp range. Apollo refuses to start outside it.

The runtime enforces these at three layers:
- **Scenario load**: any scenario step targeting an out-of-allowlist host fails to compile.
- **Pre-flight**: before launch, the controller resolves all targets and verifies each is in the allowlist.
- **Network namespace**: Apollo runs in a Linux netns with default-DROP egress; only allowlisted hosts have explicit ALLOW rules.

Bypassing one layer is still caught by the others.

### 3. Cannot ship with the Artemis defensive product
Apollo binaries must not appear on a customer's endpoint as part of the Artemis agent. This is enforced by:
- Independent build pipelines.
- Independent signing keys.
- A CI invariant in the Artemis pipeline that fails if any `apollo-*` crate is added to the workspace.

### 4. No novel-attack synthesis
The mutation engine is **bounded**: it generates variations of techniques in the curated library, where each mutation is grounded in a parent technique. The engine cannot create new attack families.

### 5. Output flow back to Artemis
Apollo's outputs (scenario results, gap reports) feed Artemis's Knowledge store (P16) only via a sandboxed, human-reviewed pipeline. Direct ingest of Apollo binaries / scripts into Artemis is unimplementable, not just disabled.

### 6. Future commercial SKU (locked behind separate gates)

The decided positioning includes a future commercial SKU. Each commercial milestone requires its own legal review and ADR (mirroring P14's gating):

- **Apollo Pro service** (Artemis-operated, customer-authorised pen-tests): requires
  - Pen-testing licence in each jurisdiction of operation (Germany: §202c StGB awareness; US: state-by-state for pentest licensing).
  - Master Services Agreement template + per-engagement Statement of Work template, both reviewed by counsel.
  - Customer's signed authorisation per engagement (allowlist + window + acknowledgement).
  - Insurance: errors-and-omissions; cyber-liability with "authorised testing" cover.

- **Apollo standalone product** (sold to customers' in-house teams):
  - Export-control classification (US ECCN check; EU Dual-Use Regulation 2021/821).
  - End-user verification (Wassenaar-compatible "know your customer" process).
  - Restricted to customers in jurisdictions that allow possession of such tooling.
  - Per-customer registration; revocable.

### 7. Audit
- Every Apollo run produces an immutable, signed audit record.
- Audit records are retained for ≥ 7 years.
- Audit records include: target allowlist, authorisation hash, scenario IDs, operator identity, outcomes.

### 8. Personnel
- Apollo PR review requires two approvers: the Apollo red-team engineer (R9) AND the Artemis tech lead (R1).
- Apollo access is logged; access patterns are reviewed quarterly.

## Adversarial threats addressed

| Threat | Defence |
|---|---|
| Apollo used against an unauthorised target | Triple-layer allowlist (load + pre-flight + netns) |
| Apollo accidentally bundled into Artemis customer agents | Independent build, independent signing, CI invariant |
| Mutation engine synthesises novel malware | Mutation depth bounded; parent-technique grounding |
| Insider exfiltrates Apollo binaries | Separate access model; periodic access review; binaries never on customer fleets |
| Future commercial path drifts into hack-back | Per-SKU legal-review gate; ADR superseding required for any change |
| Author of a scenario adds an out-of-bounds capability | Two-reviewer rule; second reviewer is Artemis tech lead, not Apollo team |

## Consequences

- Apollo development is deliberately slower than it could be without these gates. Accepted.
- Apollo cannot be open-sourced under our current planning; if open-source becomes desirable later, a new ADR superseding this one must take that decision intentionally.
- Marketing must describe Apollo accurately; never as "hack-back," never as a generic offensive tool. Always as adversary-emulation against authorised targets.
- The per-SKU legal-review gate adds time-to-revenue for Apollo Pro. We accept this; the alternative is regulatory exposure that would end the company.
