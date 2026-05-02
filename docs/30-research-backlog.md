# 30 — Research-Driven Improvement Backlog

Items the senior audit ([`docs/29-senior-audit.md`](29-senior-audit.md)) flagged as research-driven improvements: things the latest research suggests we should track but that are not blocking Phase 1.

Each item: what, why, when, owner.

---

## R1 — EU Cyber Resilience Act + EU AI Act + DORA alignment

**What:** Formal compliance ADR mapping Artemis obligations under EU Regulation 2024/2847 (CRA), EU AI Act (esp. Art. 6 high-risk classification for security AI systems), and DORA for financial-sector tenants.

**Why:** EU CRA in force October 2024; vulnerability-handling reporting from September 2026; full applicability December 2027. Penalties up to €15M / 2.5% global revenue. Mandates: secure-by-default (we have it), vulnerability handling process, 24h notification of actively-exploited vulnerabilities, SBOM generation, 5-year support window. Some Artemis ML pillars likely classify as high-risk under EU AI Act.

**When:** Compliance ADR before Phase 4 start; SBOM generation in CI from Phase 1.

**Owner:** Project owner + counsel + tech lead.

---

## R2 — Rust-for-Linux mainline migration opportunity

**What:** Track Rust-for-Linux mainline progress. As more kernel APIs gain Rust bindings, opportunities open to reduce `unsafe` surface in P2 and to write LSM hooks in safe Rust where currently we use eBPF C.

**Why:** Smaller `unsafe` surface = fewer privileged-path bugs. Real but slow benefit.

**When:** Quarterly review; act when a relevant API ships in mainline.

**Owner:** Sensor engineer (R2).

---

## R3 — Confidential AI inference for the LLM copilot

**What:** Investigate TEE-based inference (Intel TDX / AMD SEV-SNP / Apple Private Cloud Compute model) for P5 LLM copilot.

**Why:** Removes the residual privacy concern (issue I3 in audit) of customer alert metadata leaving the tenant boundary even in redacted form. Apple shipped Private Cloud Compute in 2024; the architecture pattern is well-documented.

**When:** Phase 5+; depends on Anthropic / OpenAI offering TEE-attested inference (currently informal at most providers).

**Owner:** ML engineer (R8) + control-plane engineer (R3).

---

## R4 — Robust LLM-app frameworks (DSPy / LMQL / structured generation)

**What:** Replace bare prompt-engineering in P5 + P21 with a structured framework (DSPy, LMQL, Anthropic tool-use, or similar) that compiles prompts and validates outputs.

**Why:** Bare prompts drift across model versions; recompilation discipline is fragile; structured frameworks make the system robust to provider changes and reduce prompt-injection surface.

**When:** Phase 5; refactor opportunity once P5 has stable production usage.

**Owner:** ML engineer (R8).

---

## R5 — NIST AI RMF alignment

**What:** Map Artemis ML pillars (P8, P16) to NIST AI Risk Management Framework's Govern / Map / Measure / Manage functions.

**Why:** Increases customer trust (especially US federal-adjacent and regulated); meets growing customer due-diligence questionnaire requirements.

**When:** Phase 4.

**Owner:** ML engineer (R8) + project owner.

---

## R6 — OCSF version pin

**What:** We say "OCSF" generically. Pin to a specific version (currently v1.5; v2.0 in development).

**Why:** Schema drift between versions affects integrations. Pinning + planned-upgrade path is the right hygiene.

**When:** Before Phase 1 first PR. Pinned version goes into ADR-0002 as a minor amendment.

**Owner:** Backend engineer (R3).

---

## R7 — Cisco Hypershield as competitor signal

**What:** Track Cisco Hypershield (released 2024) as a direct competitor signal. They use eBPF + AI heavily; their approach informs our roadmap positioning.

**Why:** Cisco's distribution + brand + integration with their own networking gear could leapfrog us in the SMB market we target. Knowing what they ship guides our differentiation.

**When:** Quarterly competitive review; specific milestones tracked.

**Owner:** Project owner.

---

## R8 — Anthropic classifier-sandwich pattern for tool-call gating

**What:** Adopt the "classifier sandwich" pattern (input-classifier → LLM → output-classifier) for P5 SOC-copilot tool-calls and P21 LLM/AI-app firewall.

**Why:** Strong defence against prompt-injection-induced tool misuse, recommended by Anthropic for production agent systems.

**When:** Phase 5 (P5) and Phase 7 (P21).

**Owner:** ML engineer (R8) + LLM-malware-heuristic engineer (paired).

---

## R9 — Constitutional AI for the rule synthesiser

**What:** Apply Constitutional-AI-style critique passes to LLM-proposed rules in P16 before they enter the human review queue.

**Why:** Reduces human-reviewer load; catches obvious bad rules deterministically; aligns with the safety-contract spirit of ADR-0010.

**When:** Phase 6.

**Owner:** ML engineer (R8) + detection author (R5).

---

## R10 — Documentation versioning

**What:** When v1.0 ships, customers running v0.x need v0.x docs. Version the docs site alongside the product.

**Why:** "Did this work in your version?" is otherwise unanswerable. Common B2B problem.

**When:** Concurrent with first release tag.

**Owner:** Tech lead + tech writer (when hired).

---

## R11 — SBOM generation in CI from Phase 1

**What:** Generate CycloneDX SBOMs for every release artefact (Rust crates via `cargo-cyclonedx`; OCI images via `syft`).

**Why:** Required by EU CRA. Required by US Executive Order 14028. Customer-trust signal.

**When:** Phase 1.

**Owner:** Tech lead (R1) — wire into CI in WS-A.

---

## R12 — Cargo-deny dependency policy

**What:** Comprehensive `deny.toml`: license allow-list, vulnerability gate, banned crates, source allow-list, `dupes` policy.

**Why:** Specific concrete scaffolding for ADR-0017 layer 2; needed for first PR.

**When:** Phase 1, in WS-A bootstrap PR.

**Owner:** Tech lead (R1).

---

## I1 — Cross-platform asymmetry honesty

**What:** Update vision + competitive matrix to acknowledge that the eBPF-abuse story is Linux-only.

**Why:** Honest marketing wins long term; misaligned expectations destroys trust on first incident.

**When:** Before Phase 2 marketing materials ship.

**Owner:** Project owner.

---

## I2 — ETW patching countermeasures

**What:** P2 + 03-sensor-design Windows section needs to cover ETW patching (recent attacker tradecraft) with kernel-callback fallbacks (`PsSetCreateProcessNotifyRoutineEx`).

**Why:** ETW alone is bypassable in 2024+ adversary toolkits.

**When:** Phase 2 (Windows sensor development).

**Owner:** Windows specialist (R6).

---

## I3 — Local-Llama as first-class deployment path

**What:** Promote local-Llama / on-prem-LLM to a first-class deployment option (currently a footnote in ADR-0005 and P5).

**Why:** Some EU customers will not accept any third-party LLM provider. Air-gap stories require this anyway. Ranks higher than current spec.

**When:** Phase 4 latest.

**Owner:** ML engineer (R8) + tech lead (R1).

---

## I4 — Lethal-trifecta formalisation in P21

**What:** Restructure P21 (LLM/AI-app firewall) explicitly around the "lethal trifecta": private-data access × untrusted-content exposure × outbound capability.

**Why:** Standard lens in LLM-agent security. Customer-facing reasoning becomes simpler.

**When:** Phase 7.

**Owner:** LLM-firewall track lead.

---

## I5 — Sub-region data residency

**What:** Decide: do we support Germany-only, France-only, etc. residency, or remain at "EU"?

**Why:** Some customers (German federal, French OIV) require sub-region.

**When:** Phase 3.

**Owner:** Project owner + control-plane engineer (R3).

---

## I6 — Air-gap deployment story

**What:** Formal air-gap deployment doc + tests covering: offline knowledge bundle delivery (USB sneaker-net), offline rule signing verification, no-outbound-call agent profile.

**Why:** Some customers (defence-adjacent, critical infrastructure) require it.

**When:** Phase 5.

**Owner:** Tech lead (R1) + control-plane engineer (R3).

---

## I7 — Intent-session UX validation sprint

**What:** 2-week UX research sprint with the design partner before locking the intent-session interaction model.

**Why:** Daily user behaviour change is a known UX failure point. Validate before scaling.

**When:** Phase 1.

**Owner:** Console engineer (R4) + design-partner liaison.

---

## I8 — Alert-storm cost runaway scenarios

**What:** Explicit mode for handling alert storms (10k+ alerts/hour): template narratives + bulk summarisation + operator notification.

**Why:** LLM token budget is per-month; a single attack can blow a year's budget.

**When:** Phase 5.

**Owner:** Backend engineer (R3) + console engineer (R4).

---

## I9 — MITRE D3FEND mapping

**What:** Map pillars + rules to MITRE D3FEND (defensive techniques).

**Why:** Customer trust + auditor approval. Easy add; high signal.

**When:** Phase 4.

**Owner:** Detection author (R5).

---

## Tracking

This file is the current backlog. As items are picked up, they move into `docs/12-task-backlog.md` with concrete tickets. Items that are completed get a `[done in <phase>]` annotation here, then archived after a release.

This file is reviewed quarterly by the project owner + tech lead. New research findings get appended.
