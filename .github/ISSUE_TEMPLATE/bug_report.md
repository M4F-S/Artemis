---
name: Bug report
about: Report a defect, regression, or unexpected behaviour.
title: "bug: <short description>"
labels: [bug, triage]
---

## Summary
<!-- One sentence. -->

## Environment
- Artemis version (`artemis version`):
- OS + kernel (`uname -a`):
- Profile (`dev` / `school` / `personal` / `managed`):
- Pillar(s) likely involved (P1–P22):

## Reproduction
<!-- Steps. Be specific. -->
1.
2.
3.

## Expected behaviour
<!-- What should happen. -->

## Actual behaviour
<!-- What did happen. Include exact error text / log line. -->

## Telemetry budget impact
<!-- If this affects performance, current vs. budget. -->

## Privileged-path? (`crates/artemis-active-defense`, `artemis-self-healing`, `artemis-signer`, `artemis-nac-*`, `artemis-bpf`)
- [ ] Yes (will require two-reviewer rule on the fix)
- [ ] No

## Threat-model implications
<!-- Does this expose a new attack surface? Reference docs/01-threat-model.md if so. -->

## Attached
<!-- Logs, screenshots, agent.toml redacted, agent doctor output. -->
