# P16 — Self-Evolving (Continual Learning + Auto-Rules)

**Marquee pillar (joint with P15).** Artemis gets better at its job over time without an army of detection engineers. The autonomic loop is **MAPE-K** (Monitor → Analyze → Plan → Execute → Knowledge), with each component continually learning, **safely**.

## Components

### E1 Online ML with poisoning resistance

- Local detectors retrained continuously on tenant-local data; aggregation across tenants via federated learning (P6).
- Aggregation uses **Byzantine-robust** rules (Krum / Median / FLTrust-style) so a single tenant's poisoned data cannot tip the global model.
- Bilevel-optimisation adversarial training (per recent literature) maintains robustness while ingesting new samples.
- Each model release is canary-tested on a held-out adversarial corpus before promotion; regressions roll back automatically.

### E2 LLM rule synthesis from incidents

- When an incident closes, the provenance sub-graph + analyst notes go to an LLM (RuleGenie / RulePilot-style pipeline).
- The LLM proposes:
  - A new YAML rule generalising the incident.
  - An ATT&CK-technique mapping.
  - A test case (synthetic event sequence) the rule must match.
  - A negative test set drawn from benign data.
- Output is schema-validated and pushed to a **review queue**, not auto-deployed.
- Rules approved by a human ship within hours rather than weeks.

### E3 Reinforcement learning on response

- The Plan stage of MAPE-K learns playbook selection from outcomes:
  - Reward: threat contained, no user disruption, low data loss.
  - Penalty: false positive, business outage, missed lateral move.
- RL agent only **proposes** playbooks; deterministic policy still gates execution.
- Safe-RL constraints encoded so destructive actions (auto-rollback, account disable) are never the optimisation target.

### E4 Operator-feedback FPR tuning

- Every analyst dismissal = signal: rule confidence score drifts down.
- Three dismissals on a stable rule → the rule auto-demotes to "audit-only" and a ticket is opened on the rule author.
- Promotion path: a rule that catches ≥ 1 confirmed-true incident in 30 days while keeping FPR < threshold auto-promotes from `audit` to `block`.

### E5 Federated transfer learning

- Detection embeddings shared across tenants under CKKS encryption (P6).
- New tenants benefit from fleet-level patterns from day one (cold-start problem solved).
- Per-tenant opt-in; opted-out tenants still contribute differentially-private summaries.

### E6 Auto-deception placement learning

- Where attackers actually land in a tenant's environment becomes the seed for next-cycle decoy placement.
- Attacker fingerprint + lateral path → prioritise canary-rich corridors on those paths.
- Models per ATT&CK technique cluster; updated nightly.

### E7 Attack-graph mining

- Periodically (weekly) the provenance store is mined for *latent* attack paths the customer's fleet exposes — e.g., "developer laptop → service account → prod RDS" — even when no attack was observed.
- Surfaces highest-value paths to harden, with concrete recommendations.

### E8 Knowledge base curation

- All approved rules, RL policies, deception placements, attack graphs are versioned in a single **Knowledge** store (the K of MAPE-K).
- Every component reads from one signed source of truth; rollbacks are atomic.

## Adversarial considerations (CRITICAL)

A self-evolving system is itself a target. Threats and mitigations:

| Threat | Mitigation |
|---|---|
| Training-data poisoning across the federation | Byzantine-robust aggregation; per-tenant contribution caps; outlier detection on contributed gradients |
| Targeted poisoning on a single tenant | Local model is just one signal; cloud + rule + provenance ensemble vote |
| Attacker triggers RL into bad-action regions | Hard policy gate: RL only ranks playbooks from a fixed allowlist; never invents actions |
| Attacker manipulates operator dismissals | FPR tuning is bounded (rules cannot fall below `audit-only`); promotion requires ≥ 1 true-positive |
| Attacker injects malicious YAML via the LLM rule synthesiser | Output schema-validated; review queue is human-gated; injected content can never reach instruction position raw |
| Attacker poisons attack-graph mining to hide their path | Mining is an additional signal, never sole source-of-truth; provenance integrity hash-chained |

See [ADR-0010](../09-adr/0010-autonomic-safety.md) for the unified autonomic-safety contract.

## Coverage

- Closes the loop: every incident makes Artemis better.
- Industrially relevant given Kaspersky's reported ~500k new malicious files per day in 2025; static rule authoring cannot keep up.
