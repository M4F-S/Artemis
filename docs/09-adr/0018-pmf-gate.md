# ADR-0018 — Product-Market-Fit gate at end of Phase 4

## Status
Accepted (Phase 0).

## Context

The Artemis roadmap takes ~9–14 months to reach Phase 4 (1.0.0). That is a substantial capital outlay. Phase 0 has design-partner sign criteria; Phases 1–4 have engineering Definition-of-Done criteria; but no point in the roadmap asks the harder question: *is this the product the market actually wants?*

Building 22 pillars based on a strong thesis without market validation is a known failure mode in security startups. (See: countless EDR-pretenders that built brilliant tech and shipped to a market that already had Defender free with Windows.)

## Decision

A **PMF gate** is inserted between Phase 4 (Hardening + Robust ML) and Phase 5 (Active Defense + Autonomic). Phase 5 cannot start until the PMF gate passes.

### PMF gate criteria

All four must be met:

1. **Production deployment scale.** ≥ 3 design partners running Artemis on ≥ 25 endpoints each, for ≥ 60 consecutive days, without unscheduled downgrade.

2. **Conversion signal.** ≥ 1 design partner has converted to a paying tier OR signed a Letter of Intent for paid conversion at GA. (LOI must include price + intended endpoint count + intended start date.)

3. **NPS-style sentiment.** Net Promoter Score from design-partner admins ≥ 30, measured via a 5-question survey conducted by an independent (non-Artemis) party.

4. **Critical-feature validation.** ≥ 80% of design-partner admins identify ≥ 1 of the differentiating pillars (P1, P3, P4, P15, P16) as "essential — would not switch back without it."

### What happens if the gate fails

A failure means **pause feature work**. Phase 5 does not start. Instead:

1. **Customer-development sprint** — 4 weeks of structured user interviews, log analysis, and on-site observation with the design partners and a target list of 10 prospect SMBs.
2. **Re-plan** — produce an updated roadmap (new ADR superseding the original Phase 5+) reflecting what was learned. May involve cutting pillars, repositioning, or pivoting altogether.
3. **Re-gate** — repeat the PMF criteria check after the re-plan ships incremental adjustments.

A failure is not a project death sentence; it is a course correction. But it is also not an outcome to be papered over.

### What happens if the gate passes

Phase 5 begins, with explicit risks tracked:
- Continued PMF check at end of Phase 6.
- Conversion of remaining design partners by end of Phase 7.
- Public GA announcement at end of Phase 7.

### Rationale for these specific criteria

- **3 design partners, 25 endpoints, 60 days**: statistically meaningful enough to distinguish "we built something that runs" from "we built something that's used."
- **1 paying or LOI**: at least one customer must be willing to pay. A free product that's loved is not a product.
- **NPS ≥ 30**: industry healthy-product threshold (B2B SaaS typical NPS for top quartile is 30–50).
- **80% identify ≥ 1 essential feature**: filters for products customers can't replace easily.

### Authority

- The PMF gate decision is made by the project owner, with input from the tech lead and the design partners.
- A "tied" decision — gate ambiguous — defaults to extending Phase 4 by 4 weeks rather than passing.
- Counsel does not vote; legal review is necessary but not sufficient.

## Consequences

- Phases 5–7 are not unconditional. The team must accept that the carefully-spec'd autonomic and Active-Defense pillars may be deferred or cut if the market doesn't validate them.
- Expectations management: investors, founding contributors, design partners are told about the gate at onboarding. No surprise.
- A pause-and-re-plan cycle is normalised. Cultural acceptance that pauses are sometimes the right call.

## Verification

- Each criterion is measurable and dated.
- The independent NPS survey vendor is contracted by Phase 3.
- The conversion / LOI conversation begins at Phase 2 onboarding, not at gate time.
- A senior advisor (board observer or external CISO) attends the gate review.
