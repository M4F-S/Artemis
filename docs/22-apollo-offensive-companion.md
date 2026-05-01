# 22 — Apollo: Offensive Testing Companion

**Apollo** is Artemis's twin: an offensive testing platform whose only purpose is to make Artemis better. It runs canned + custom red-team scenarios from a Kali-Linux base against an Artemis-protected lab fleet. It is a **separate sister project** in a separate repository (`m4f-s/apollo`) under separate access control.

> Naming note: Apollo is Artemis's twin in Greek myth, the archer. The name signals "same family, opposite role." Other names considered (Hephaestus, Atlas, Hermes) — Apollo wins on memorability and accuracy.

## What Apollo is

- A controlled offensive-testing platform.
- Built on Kali Linux base image; pulls a curated, signed manifest of tools (Metasploit, Caldera, Atomic Red Team, Sliver, custom payloads).
- Runs scenarios in YAML format borrowed from MITRE Caldera.
- Scores Artemis's response and feeds gaps back to the Artemis Knowledge store (P16) and BAS technique library (P17).
- Will eventually become a paid SKU for advanced customers needing continuous adversarial-exposure validation.

## What Apollo is NOT

- Not a "hack-back" tool. Apollo cannot, and will not, target systems outside its authorised target list.
- Not bundled with the Artemis defensive product. Customers running Artemis never get Apollo binaries on their endpoints.
- Not for use against any system the operator does not own or have explicit, written authorisation to test.

## Hard scope ([ADR-0012](09-adr/0012-apollo-scope.md))

Apollo enforces, in code:

1. A target allowlist file (signed, per-engagement) declaring exactly which hosts / networks may be touched.
2. A pre-flight check: every target the run plans to interact with must be in the allowlist. Anything else aborts the run.
3. An "engagement window" timestamp range. Outside the window, Apollo refuses to start.
4. Authorisation evidence: every engagement carries a copy of the customer-signed authorisation document (PDF + hash); Apollo refuses to start if the hash check fails.
5. Outbound-only-to-allowlist enforcement at the network namespace level (Apollo runs in a netns with default-DROP egress except to the allowlist).

These are enforced at multiple layers: at scenario-load, at runtime, and at network-egress. Bypassing one would still be caught by another.

## Apollo capabilities

### A1 Scenario library

Curated implementations of ATT&CK techniques, expressed as YAML scenarios:
- Initial access: phishing chain into a lab inbox; supply-chain compromise via a deliberately-poisoned npm package.
- Execution: LOLBin chains, vibeware-style LLM-fed loader, classic Metasploit shells.
- Persistence: scheduled tasks, services, systemd timers, browser-extension persistence.
- Privilege escalation: known CVE exploitation against patched-down lab VMs (CVE specified in scenario).
- Defense evasion: script obfuscation, parent-PID spoofing, process hollowing.
- Credential access: LSASS dump, browser cookie exfiltration, Kerberos abuse.
- Discovery: AD enumeration, cloud-API enumeration.
- Lateral movement: PtH, PtT, RDP, SSH key abuse.
- C2: HTTPS beacon, DNS tunnel, legit-host C2 (GitHub / Discord / Cloudflare Workers).
- Impact: ransomware-style mass-encrypt (sandboxed; never escapes lab volume).

### A2 Bounded mutation engine

Auto-generates variations of known techniques to find brittle Artemis rules. Mutation depth is **bounded**; the engine cannot synthesise novel attack families. Every mutation is grounded in a parent technique with a stable identifier.

### A3 Run controller

Schedules runs, captures Artemis's full response (alerts, containment actions, narrative), and produces a structured report:
- Did Artemis detect the technique? At what depth (early / mid / late kill chain)?
- Did Artemis contain it? With what severity tier?
- What was the operator-visible time-to-detect, time-to-contain?

### A4 Coverage feedback

Runs feed Artemis's coverage dashboard (P13). Gaps generate tickets for the rule synthesiser (P16). Closed gaps are re-tested on the next run cycle.

### A5 Continuous mode (Phase 6+)

Runs a small set of scenarios nightly against a tenant's canary scope (with consent). Full library weekly. Gartner calls this Adversarial Exposure Validation; we treat it as the same concept.

## Relationship to Artemis BAS (P17)

Confusion to avoid: Artemis ships a built-in BAS engine (P17) that runs **inside the customer tenant** against canary scope. P17 is **strictly safe** and small. Apollo is a **richer, riskier** offensive platform that runs **outside the customer tenant** in a controlled lab. The two interact only via a curated, sandboxed pipeline:

```
[Apollo] → run new scenario → result → P16 rule synthesiser → human review → 
    → P17 in-customer BAS technique library (sandbox-wrapped, deterministic) → 
    → tenants
```

Apollo content cannot reach customers directly. Only post-review, sandbox-wrapped versions land in P17.

## Repo layout (`m4f-s/apollo`)

```
apollo/
├── README.md                        ← scope, "READ THIS FIRST" warnings
├── ADR/
│   └── 0001-scope.md                ← copy of artemis ADR-0012
├── scenarios/
│   ├── initial-access/
│   ├── execution/
│   ├── persistence/
│   └── ...                          ← per-tactic
├── crates/
│   ├── apollo-core/                 ← scenario runtime + target allowlist enforcement
│   ├── apollo-controller/           ← run scheduler + reporting
│   ├── apollo-mutation/             ← bounded mutation engine
│   └── apollo-tools/                ← Kali tool wrappers
├── images/
│   └── kali-base/                   ← signed base image build
└── docs/
    ├── 00-scope.md
    ├── 01-engagement-checklist.md   ← per-engagement gate
    └── 02-author-a-scenario.md
```

## Headcount

- Phase 6 onwards: 1 dedicated red-team engineer (R9 in `docs/18-team-and-headcount.md`).
- Phase 4–5: a part-time detection author can seed the scenario catalog before Phase 6.
- Apollo PR review requires both the red-team engineer AND the Artemis tech lead, given the dual-use sensitivity.

## Compensation / commercial path

- Lab-only at first (Phase 6).
- Post-Phase-7: optional opt-in service for paying Artemis customers (signed MSA + per-engagement SoW).
- Long-term (Phase 8+): standalone Apollo Pro SKU (~$25k+ per engagement; pricing TBD; legal counsel sign-off required, mirroring P14's gate).
- Each commercial path requires its own legal review:
  - US: ECCN classification check; possible export controls.
  - EU: Dual-Use Regulation 2021/821 awareness; Wassenaar "intrusion software" categorisation.
  - Customer-side: pen-testing licence in Germany / Austria; corresponding licences in other jurisdictions.

## Risks (Apollo-specific)

| Risk | Mitigation |
|---|---|
| Tools or scenarios escape the lab netns | netns + iptables + cgroup network controllers; CI tests assert egress is restricted |
| Apollo binaries leak via shared CI / package cache | Separate CI org; separate package registry; no shared cache |
| A scenario is misused against an unauthorised target | Allowlist + signed authorisation hash check at every run-start |
| Future commercial path conflated with hack-back | Legal review on every SKU launch; ADR-0012 cited in all customer-facing materials |
| A scenario causes real damage to a lab system | Lab is fully reproducible from images; explicit "destructive" tag on scenarios that perform irreversible actions; manual confirmation required |
| Apollo IP leaks to attackers | Closed source; access tightly controlled; Apollo binaries never on customer endpoints |

## When to start

Apollo work begins in earnest in Phase 6 (per the roadmap). Until then:
- Phase 4–5: a part-time detection author can stand up the scenario YAML schema and a few seed scenarios.
- Don't pull Apollo dependencies into Artemis crates, ever.
- Don't open the Apollo repo to general contributors until the access model is defined.
