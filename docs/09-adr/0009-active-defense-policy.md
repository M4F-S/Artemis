# ADR-0009 — Active Defense (P14) legal-clearance gating

## Status
Accepted (Phase 0).

## Context
Customer requested an "attack-back" capability. Real attack-back — accessing systems the customer does not own to disrupt or retrieve — is illegal under:

- **US**: Computer Fraud and Abuse Act (18 U.S.C. § 1030). The proposed Active Cyber Defense Certainty Act (ACDC) has been reintroduced multiple times (2017, 2019, 2021, 2023, 2025) but never passed.
- **UK**: Computer Misuse Act 1990, ss. 1–3.
- **EU**: NIS2 Directive Art. 6 permits some active measures within the defender's perimeter or with host authorisation; offensive action across the public Internet is generally unlawful under member-state computer-crime statutes.
- **AU**: Criminal Code Act 1995, Part 10.7.
- **CA**: Criminal Code s. 342.1.
- **JP**: Unauthorized Computer Access Law.

Some governments are *discussing* legalising scoped active defence. Until those pass, the lawful surface is: **inside the defender's perimeter, on systems the defender owns, or via legitimate third-party channels (abuse reports, takedown vendors).** Honeytokens are lawful: the attacker brings the data to a controlled environment.

## Decision

P14 is built as architecture; capabilities A–E (perimeter-internal) ship code-complete but **disabled**, and capability F (legitimate-channel takedowns) is gated behind a separate flag. Anything that would be unlawful — outbound probing, exploitation, payload delivery, accessing attacker systems — **is unimplementable**, not merely disabled.

Specifically, the Active Defense Orchestrator:

1. Accepts only signed playbooks from a fixed allowlist.
2. Evaluates each action against a per-jurisdiction policy file before dispatch.
3. Rejects any action whose target IP/hostname is outside the tenant's declared assets (resolves "is this our perimeter?" via the tenant's asset registry).
4. Rejects any payload whose category is not in the perimeter-internal allowlist.
5. Logs every dispatched action immutably; the log is exposed to tenant admins and Artemis legal.

Enabling P14 requires:

- Tenant admin opts in **per capability**, not all-or-nothing.
- Per-jurisdiction policy file is loaded; jurisdictions where the action is unlawful get hard-disabled.
- Customer uploads a signed legal acknowledgement (Artemis-supplied template + their counsel's review).
- Dual-control: a second admin must approve any third-party-touching action.

## Rationale

Building it now and keeping it locked off is the right balance:
- The customer wants it.
- Legislation is moving (ACDC re-introduced; NIS2 expansions in some EU member states).
- Designing it correctly with hard limits is much easier than retrofitting safety later.
- Most P14 value (containment, fingerprinting, deception escalation) is already lawful today; the user gains 90% of the benefit before any legal change.

## Consequences

- Engineering will resist the temptation to shortcut the policy gate; CI checks enforce it.
- Marketing must describe P14 carefully — never as "hack-back" — to avoid misleading prospects.
- Legal review is on the critical path before each new outbound capability ships.
- We retain the right to refuse a customer's request to enable a capability we believe is unlawful in their jurisdiction.
