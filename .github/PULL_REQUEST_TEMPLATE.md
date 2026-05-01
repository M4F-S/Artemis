<!--
Thank you for contributing to Artemis. Please complete this template fully.
-->

## Summary
<!-- What does this PR do, in 1-2 sentences? -->

## Ticket / ADR
<!-- Link to ticket in docs/12-task-backlog.md or to a relevant ADR. -->
- Ticket: P?-T??
- ADR (if architectural): ADR-???

## Type
- [ ] Feature
- [ ] Fix
- [ ] Refactor
- [ ] Docs
- [ ] Test
- [ ] Performance
- [ ] Chore

## Pillars touched
<!-- Tick all that apply. -->
- [ ] P1 AI-aware     - [ ] P2 Kernel visibility   - [ ] P3 Deception
- [ ] P4 Intent       - [ ] P5 LLM copilot         - [ ] P6 Privacy
- [ ] P7 Provenance   - [ ] P8 Cert-robust ML      - [ ] P9 HW attest
- [ ] P10 Identity    - [ ] P11 Supply-chain       - [ ] P12 PQ signing
- [ ] P13 Reporting   - [ ] P14 Active Defense     - [ ] P15 Self-Healing
- [ ] P16 Self-Evolving - [ ] P17 BAS              - [ ] P18 Email
- [ ] P19 NDR         - [ ] P20 CWPP               - [ ] P21 LLM firewall
- [ ] P22 Hunting+DFIR+Backup
- [ ] Cross-cutting (core, infra, CI)

## Privileged-path changes
<!-- Tick if this PR touches any of the following; explain how it was reviewed. -->
- [ ] `unsafe` Rust added or modified
- [ ] Kernel-mode / driver code
- [ ] Cross-tenant data path
- [ ] Authentication / authorisation
- [ ] Cryptographic / signing code
- [ ] LLM input/output handling
- [ ] Active Defense (P14) action allowlist or playbook
- [ ] Self-Healing (P15) destructive primitive
- [ ] Federation aggregation (P16) or Knowledge store
- [ ] BAS (P17) sandbox / mutation depth

If any of the above is ticked, name the second reviewer here:

## Testing
- [ ] Unit tests added / updated
- [ ] Integration tests added / updated
- [ ] Performance suite still green (if applicable)
- [ ] Manual test scenario described below

## Manual test scenario
<!-- Steps a reviewer can run to verify. -->

## Telemetry budget impact
<!-- Idle CPU/RAM/net change estimate. Skip if not applicable. -->

## Threat-model delta
<!-- Did this introduce a new attack surface, asset, or trust boundary? If yes, link to a docs/01-threat-model.md update. -->

## Hard rules check (CLAUDE.md)
- [ ] No P14 outbound capability without ADR-0009 sign-off.
- [ ] No code targeting systems we don't own.
- [ ] No collection of document content / clipboard / keystrokes.
- [ ] Multi-tenant isolation respected.
- [ ] All telemetry treated as untrusted input.
- [ ] All shipped artefacts signed (ADR-0007 / ADR-0010 / P12).
- [ ] Autonomic actions stay within the action allowlist (ADR-0010).
- [ ] Auto-rollback respects the multi-signal gate (ADR-0011).
- [ ] Apollo dependencies not pulled into Artemis crates (ADR-0012).
