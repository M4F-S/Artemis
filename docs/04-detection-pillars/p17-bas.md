# P17 — Built-In BAS / Self-Red-Team

**Continuous Adversarial Exposure Validation** (Gartner's 2024 framing) baked into the platform. Picus / SafeBreach / Pentera offer this as a separate product; Artemis treats it as an internal feedback loop for P16 (self-evolving) and a customer-facing assurance product.

## Goals

1. Continuously verify that Artemis's controls actually catch what they claim to catch.
2. Discover detection gaps **before** real attackers do.
3. Generate ATT&CK coverage reports the customer can hand to auditors and insurers.
4. Feed gaps into P16 rule synthesiser for closure.

## Capabilities

### B1 Attack library

- Curated technique implementations spanning the ATT&CK matrix.
- Each technique runs as a **safe** simulation (no real malware, no real exfil — lab-style payloads with side-effects bounded).
- Library updated weekly; new techniques added when observed in the wild.

### B2 Continuous scheduled runs

- Per-tenant schedule (default: nightly low-impact, weekly full).
- Runs against a **canary host** by default — a dedicated endpoint or a sandboxed namespace.
- Optional production-fleet runs with explicit tenant authorisation (rare).

### B3 Mutation engine

- Auto-mutates known techniques (PE byte tweaks, command-line obfuscation, timing variation, LOLBin substitution) to find brittle rules.
- Mutations bounded by ATT&CK technique semantics; no novel-attack synthesis.

### B4 Result reporting

- Per-run dashboard: pass / fail per technique, per pillar.
- ATT&CK coverage heatmap (P13).
- Drift detection: techniques that started passing then started failing → high-priority alert (something regressed).

### B5 Gap-to-rule pipeline

- Failed simulation → gap entry → P16 LLM rule synthesiser drafts a rule → human review → ships.
- Cycle time target: < 24h from gap detection to deployed rule.

### B6 Safe constraints

- Never executes any technique that is not in the curated library.
- Never escalates beyond pre-declared canary scope without a fresh, dual-control authorisation.
- Mutation depth bounded; the mutation engine cannot generate novel families.
- Outbound network targets are Artemis-controlled lab endpoints, never third-party hosts.

## Coverage

- Closes the gap between "we have rules" and "our rules actually work."
- Reduces the marketing-vs-reality gap that hurts SMBs the most: the assumption that buying a product means being protected.
- Makes Artemis ATT&CK coverage **provable** to insurers / auditors / boards.

See [ADR-0010](../09-adr/0010-autonomic-safety.md) for the safety contract that constrains BAS execution.
