# ADR-0010 — Autonomic-loop safety contract

## Status
Accepted (Phase 0).

## Context

P15 (self-healing) and P16 (self-evolving), plus P17 (BAS), P14 (active defense), and P22 (auto-restore) together make Artemis an autonomic system: it observes, decides, and acts on its own. That's the value. It is also a category of risk that traditional EDR doesn't have — the system itself can be tricked into being the attacker's weapon.

The structure follows IBM's **MAPE-K** loop:
- **Monitor**: sensors + ingest pipeline.
- **Analyze**: detection engine, ML scorers, provenance graph.
- **Plan**: playbook ranker, RL agent.
- **Execute**: Active Defense orchestrator (P14), self-healing controller (P15).
- **Knowledge**: rule store, model registry, attack-graph cache, deception placement memory.

This ADR fixes the **safety contract** governing what Plan and Execute may do without a human, what they may never do, and how Knowledge is protected from poisoning.

## Decision

The autonomic loop is **bounded** at every stage. Specifically:

1. **No new action types may be invented at runtime.** Plan ranks a fixed allowlist of playbooks; Execute runs only signed playbooks from the Knowledge store. The LLM never produces actions; it produces *proposals* that go to a human review queue.

2. **Destructive actions require explicit per-tenant authorisation in advance.** Auto-rollback, account-disable, secret-rotation, and host-isolation are all classified as destructive and gated by tenant-admin pre-authorisation; default = require human approval.

3. **High-impact actions require multi-signal confirmation.** Auto-rollback (P15 S2) needs ransomware-encryption rate threshold *and* mass-rewrite signature *and* CRITICAL alert *and* tenant policy = `auto-rollback`. No single signal is sufficient.

4. **The self-evolving loop never demotes a rule below `audit-only`.** Operator dismissals reduce confidence and effective severity, but a rule is never silently disabled by feedback alone.

5. **Knowledge is signed, hash-chained, and append-only at the audit layer.** Rule rollbacks are atomic; tampering is detectable; tenant admins can replay any state.

6. **Federated aggregation is Byzantine-robust.** Median / Krum / FLTrust-style; no single tenant's contribution can move the global model beyond a bounded radius. Outlier contributors are quarantined automatically.

7. **The LLM rule synthesiser cannot reach instruction position with attacker-controlled content.** Inputs are structured, schema-validated. Output is YAML-parsed and checked against a whitelist of rule grammars before entering the review queue.

8. **BAS execution is sandboxed.** P17 may only execute techniques from the curated library, against the tenant's own canary scope, with a fixed mutation depth. It cannot synthesise novel attacks.

9. **Self-protection is read-only with respect to destructive primitives.** The mesh fallback (P15 S5) is read-only — it can keep rules firing, queue alerts, and run perimeter-internal P14 actions, but it cannot trigger auto-rollback, account-disable, or secret-rotation. Those require cloud confirmation.

10. **Every autonomic action is reversible where physically possible.** Irreversible actions (key rotation, account disable, restore from snapshot) require human approval each time, even with auto-rollback enabled. Reversible actions (process kill, network isolate) may auto-execute under documented conditions.

## Adversarial threats explicitly addressed

| Threat | Defence layer |
|---|---|
| Federated training-data poisoning | Byzantine aggregation + per-tenant contribution caps + outlier quarantine |
| Targeted local model poisoning | Local model is one signal; ensemble + rule + provenance vote |
| RL agent driven into bad-action region | Hard policy gate; RL ranks from fixed allowlist |
| Operator-feedback gaming | FPR tuning bounded; promotion requires true-positive |
| LLM-rule-synthesiser injection | Schema validation + human review |
| Triggering auto-rollback as a destructive primitive | Multi-signal confirmation + tenant pre-authorisation |
| Triggering auto-isolate as a DoS | Reversible-by-default; rate limits per tenant |
| Knowledge-store tampering | Sign + hash-chain + append-only audit |
| Mesh-elected coordinator abuse | Mesh is read-only for destructive actions |
| BAS technique mutation generates real malware | Mutation bounded; library is closed-set; no novel synthesis |

## Consequences

- Some of the autonomic value is held back behind explicit tenant authorisation. We accept the slower onboarding because the alternative — a system that can be tricked into attacking the customer it protects — is unacceptable.
- Engineering must enforce these constraints in code, not just in policy. CI invariant tests check the action allowlist, the multi-signal gate, the federated aggregation parameters, and the schema validation.
- Marketing must describe autonomic capabilities accurately. "Self-healing" does not mean "no human in the loop ever"; it means "no human in the loop for the recoverable + verifiable cases."
