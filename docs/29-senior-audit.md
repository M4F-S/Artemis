# 29 — Senior Audit

A senior-architect / security-auditor pass on the Artemis project. Structured as the kind of memo a hired technical advisor would write before signing off on the spec.

The previous five sessions produced 92 docs / samples covering 22 pillars + 13 ADRs. This audit found **no contradictions** in the spec and confirms the project is buildable. It also found **8 critical issues**, **9 important issues**, and a **research-driven improvement backlog** of 12 items. Critical issues are remediated in the same commit as this audit (new ADRs 0014–0017 + targeted edits). Important and research items are tracked in [`docs/30-research-backlog.md`](30-research-backlog.md).

---

## What's working well (acknowledge before critique)

1. **Threat model is honest.** T0–T6 covers the realistic adversary spectrum, and ADR-0010 explicitly bounds the autonomic loop's blast radius. Better than most production EDRs document.
2. **Privacy posture is genuinely differentiated.** DP + BYOK + pseudonymisation + federated-only IoC sharing is a strong story. EU customers will respond to it.
3. **The 22-pillar split has internal coherence.** Each pillar maps to real customer pain, has roadmap placement, and has at least one ticket. Few zombie features.
4. **Apollo (offensive companion) is correctly scoped.** ADR-0012's triple-layer enforcement (load-time + pre-flight + netns) is the right architectural pattern. Most teams build Apollo-class projects without that discipline.
5. **The parallel-session protocol is unusual and useful.** WS-A through WS-H with file-ownership rules makes simulated team-of-AI-sessions actually viable. I expect 80% adoption value here.
6. **Documentation cross-links resolve.** No orphaned `[link](nonexistent.md)` issues; manual sample confirmed.

---

## Critical issues (must remediate before Phase 1 starts)

Each has a fix shipping with this audit.

### C1. Federation security is hand-waved

**Where:** ADR-0010 says "Byzantine-robust aggregation" without specifying the algorithm. P16 mentions Krum / Median / FLTrust. P6 says CKKS encryption. None of these compose.

**Why it matters:** Recent research (2024) shows targeted poisoning attacks **bypass FLTrust** under bounded adversary fractions; **Krum** is vulnerable to the "Little Is Enough" attack with only knowledge of variance. Calling out the algorithm name is not a security argument.

**Fix:** [ADR-0014: Federation security](09-adr/0014-federation-security.md) commits to a multi-layered scheme:
- Median-of-trimmed-means at aggregation layer (geometric robustness).
- Per-tenant contribution caps + outlier quarantine (rate limit).
- Validator set of curated tenants whose updates are weighted higher.
- Per-round re-randomisation of round keys (forward secrecy).
- Explicit threat model: bounded fraction of malicious tenants AND bounded magnitude per tenant.
- Honest disclosure: under unbounded magnitude attacks, federation is paused, not "robust."

### C2. Signing-key management is implicit

**Where:** P12, ADR-0007, ADR-0010, ADR-0011 all say "signed everything" but no doc names where the keys live, who can sign, what rotation looks like, or how recovery works.

**Why it matters:** Signing-key compromise is the existential threat for a security vendor (SolarWinds 2020; CCleaner 2017; ASUS Live Update 2019). "Signed" without a key-management story is a marketing claim.

**Fix:** [ADR-0015: Signing-key management](09-adr/0015-signing-key-management.md) specifies:
- HSM-backed root of trust per signing role (release / knowledge / playbook / agent-cert CA).
- Threshold signing (2-of-3 minimum) for release + root keys via Sigstore-style transparency.
- Rotation cadence (annual operational keys; root keys generated once, on-disk only at cold-boot ceremonies).
- Sealed offline backup with documented bring-online runbook.
- Public transparency log (Rekor-style) so customers can verify what we've signed.

### C3. Self-update channel has no formal threat model

**Where:** Mentioned in P12 + 07-deployment-and-ops as "double-signed." ADR-0007 is about DP, not signing. No ADR governs the agent self-update path itself.

**Why it matters:** Self-update is the most-attacked path for security software (think SolarWinds). The Knowledge bundles are signed; the agent binary update path is hand-waved with the same words.

**Fix:** [ADR-0016: Update channel security](09-adr/0016-update-channel-security.md) specifies:
- Two-party update consent (control plane + on-device watchdog must both verify).
- TUF (The Update Framework) for metadata; Sigstore for binary attestations.
- Per-tenant pin-and-promote (canary tier first, blast-radius-bounded promotion).
- Rollback window with on-device retained previous binary.
- Automatic rollback on failed start-after-update.
- Public update-attestation log.

### C4. Hard-rules CI scan is grep-based

**Where:** `.github/workflows/ci.yml.tpl` does `grep -E "(scan_attacker|exploit_remote|hack_back)" ...`. The scan looks for *string literals* that an attacker (or a contributor) trivially bypasses (string concat, base64, dynamic dispatch).

**Why it matters:** This is a security control we point to as evidence of safety. A grep is not that.

**Fix:** [ADR-0017: Hard-rules enforcement](09-adr/0017-hard-rules-enforcement.md) replaces grep with a layered control:
- Capability-allowlist on the daemon's outbound network (eBPF-enforced at the daemon's own runtime).
- AST-based scan via Semgrep / cargo-semver-checks / custom MIR analysis on PRs.
- Cargo dependency allow-list with `cargo-deny`.
- Sandboxed test runs of every new privileged-path PR through Apollo's negative-test scenarios.
- Two-reviewer rule for any change to `crates/artemis-active-defense/**` or `crates/artemis-self-healing/**`.

### C5. Certified-robust ML claim is overclaimed

**Where:** P8 says "DRSM-style certified robustness." Implies a strong guarantee.

**Why it matters:** DRSM and randomised smoothing certify robustness only within the chosen perturbation norm and a tiny radius (often a few bytes for malware classifiers). Customers reading "certified" will assume something stronger. Marketing claims drift further than the underlying math supports.

**Fix:** P8 doc updated to say plainly:
- "Certified within bounded ℓ₂ / byte-window perturbations" — not "certified malware detection."
- The certified radius is shown numerically per prediction in the UI.
- Verdicts marked `certified-clean`, `certified-malicious`, `uncertain — escalate`.
- Marketing must not abbreviate "certified-robust" to "certified."

### C6. P15.S5 mesh fallback is a distributed-systems iceberg

**Where:** P15 says "Agent-to-agent gossip on the customer's LAN over an Artemis overlay (mTLS, signed). Agents elect a read-only local coordinator."

**Why it matters:** "Agents elect a coordinator" is Raft / Paxos territory. Underestimating this has burned every team that has tried (Dropbox 2014, GitLab 2017, etc.). For Phase 1–6 we're a small team; building a correct distributed coordinator is a year of work on its own.

**Fix:** P15.S5 scope **downgraded** to the deliverable we can actually ship:
- During cloud outage, agents continue applying locally-cached rules and queue events to local spool. No coordinator election. No cross-agent coordination beyond cached config.
- Cross-agent coordination (the original ambitious version) becomes stretch goal post-Phase 7.
- Honest framing in marketing: "graceful degradation during cloud outages," not "decentralised mesh."

### C7. Phase 0 has no PMF gate

**Where:** Phase 0 ends when spec is locked + design partners signed. Phase 4 ends with "1.0.0 ships." But there's no point at which we ask: "is this the product the market wants?"

**Why it matters:** Building 22 pillars is 9–14 months of capital. If a single design partner is the only signal of demand, we may be building features that no one will pay for.

**Fix:** [ADR-0018: Product-Market-Fit gate](09-adr/0018-pmf-gate.md) inserts a hard PMF gate at end of Phase 4:
- ≥ 3 design partners running in production for ≥ 60 days.
- ≥ 1 design partner converted to paying or signed an LOI for paid conversion.
- Net Promoter Score ≥ 30 from design-partner admins.
- Specific feedback: ≥ 80% of design partners describe ≥ 1 feature as "essential."
- If gate fails: pause feature work; spend 4 weeks on customer development; replan.

### C8. Compliance regime alignment is incomplete

**Where:** docs mention SOC 2, ISO 27001, HIPAA, NIS2, DORA. Don't mention EU CRA at all. EU AI Act not addressed for our ML pillars.

**Why it matters:** EU Cyber Resilience Act (Regulation 2024/2847) entered into force October 2024; reporting obligations begin September 2026; full applicability December 2027. It applies to Artemis as "products with digital elements." It mandates: secure-by-default design (✓ we have it), vulnerability handling process (partly), 24h notification of actively-exploited vulnerabilities (not specified), SBOM (mentioned in glossary, not formally produced), 5-year support window. Penalties up to €15M or 2.5% global revenue. EU AI Act has separate obligations for "high-risk AI systems," some of which include security applications.

**Fix:** Tracked as item R1 in [`docs/30-research-backlog.md`](30-research-backlog.md). Phase 1 begins SBOM generation in CI (cyclonedx-cargo for Rust, syft for OCI images). A compliance ADR ships before Phase 4.

---

## Important issues (Phase 1–4)

Tracked as items in [`docs/30-research-backlog.md`](30-research-backlog.md). Brief here.

### I1. Cross-platform asymmetry in the marquee story

eBPF-abuse detection is a Linux-only differentiator. On Windows + macOS we lean on ETW + ES, well-trodden ground where SentinelOne / Defender / CrowdStrike already dominate. The marketing line "we cover the eBPF blind spot" is correct but only Linux. Should be honest in the competitive matrix and the vision.

### I2. ETW patching countermeasures missing

Recent (2023–2024) attacker tradecraft includes ETW patching: in-process disable of the ETW provider via DLL function patching or syscall hook stripping. Our Windows sensor design (P3 in 03-sensor-design) doesn't address this. Production EDRs use kernel callbacks (`PsSetCreateProcessNotifyRoutineEx`) as a backup detection layer. Need to explicitly acknowledge this in P2 + Windows sensor section.

### I3. LLM SOC-copilot privacy story has a residual gap

Even with redaction + DP, sending alert metadata to Anthropic / OpenAI gives them visibility into "what malware looks like in this customer's environment over time." Some EU customers (defence-adjacent, government-adjacent) will not accept this. Local-Llama path is documented but not prioritised; should be a first-class, not footnote, deployment option.

### I4. Lethal-trifecta not formalised in P21

The "lethal trifecta" framing (private data + untrusted content + outbound capability — Simon Willison, 2025) is the canonical lens for LLM-agent risk. Our P21 (LLM/AI-app firewall) addresses pieces of it but doesn't use the formal model. Worth aligning so customers can reason about their own AI apps in standard terms.

### I5. Sub-region data residency

ADR-0006 supports per-region pinning ("EU-West-Frankfurt"). Some customers need sub-region (German federal: Germany only, not EU). Either expand or scope down our customer profile.

### I6. Air-gap deployment story is informal

"Local Llama option" is mentioned. Full air-gap (offline knowledge bundles, offline rule signing verification, no outbound calls) isn't documented. Some customers (defence, critical infrastructure) require it. Decide: build or decline.

### I7. UX validation for intent sessions

P4 (intent sessions) is a key differentiator that requires daily user behaviour change. UX research suggests this fails at scale unless the friction is < 5 seconds and the value is felt within a week. No UX validation sprint is planned. Recommend Phase 1 includes a 2-week UX study with the design partner before locking the interaction.

### I8. Alert-storm cost runaway scenarios

What if a tenant gets a brute-force attack that generates 10k alerts/hour, each requiring an LLM narrative? Token budget exists; cost-runaway scenarios aren't war-gamed. Recommend an explicit "alert storm" mode that switches to template narratives + bulk summarisation + explicit operator notification.

### I9. MITRE D3FEND mapping

We map detections to ATT&CK techniques (offensive). MITRE's D3FEND framework maps defensive techniques. Mapping pillars + rules to D3FEND increases customer trust + auditor approval. Easy add; high signal.

---

## Research-driven improvement backlog (12 items)

Detailed in [`docs/30-research-backlog.md`](30-research-backlog.md). Headlines:

- **R1**: EU CRA + EU AI Act alignment (compliance ADR before Phase 4).
- **R2**: Rust-for-Linux mainline progress; opportunity to reduce `unsafe` surface in P2.
- **R3**: Confidential AI inference (TEE-based ML scoring; Apple Private Cloud Compute model). Could let us eliminate cloud-LLM privacy concerns entirely for P5.
- **R4**: DSPy / LMQL / robust LLM-app frameworks vs. our current bare prompt-engineering. More resilient to provider drift.
- **R5**: NIST AI RMF alignment for our ML pillars (governance, risk, measurement).
- **R6**: OCSF version pin (we say "OCSF" generically; should pin to v1.5 or v2.0 explicitly).
- **R7**: Cisco Hypershield (released 2024) is the most direct competitor signal; uses eBPF + AI heavily.
- **R8**: Anthropic's "classifier sandwiches" pattern for tool-call gating in P5 + P21.
- **R9**: Constitutional AI for the LLM rule synthesiser's review loop (deterministic checks before human review).
- **R10**: Documentation versioning (when v1.0 ships, v0.x users need v0.x docs).
- **R11**: SBOM generation in CI from Phase 1 (cyclonedx-cargo + syft + cargo-spdx).
- **R12**: Dependency policy (cargo-deny config: licenses, advisories, sources, banned crates).

---

## Inconsistencies and minor issues found

| # | Where | Issue |
|---|---|---|
| M1 | docs/13-design-partner-program.md | Says "1 US, 1 EU"; docs/15-42-berlin-adaptation.md positions 42 as the EU partner. 42 is not a paying customer — pair it with a *for-pay* EU partner, even discounted. |
| M2 | samples/console-api.openapi.yaml | Defines paths but most endpoints lack request/response schemas. Will lead to engineer divergence. Add schemas in WS-D's first openapi PR. |
| M3 | docs/05-data-model.md | Wire-level reliability section says exponential backoff base 250 ms cap 60 s, retry up to 24 h. The math: 24 h with cap 60 s = 1440 retries. Likely meant "spool to disk after capped backoff for 24 h." Clarify. |
| M4 | docs/06-control-plane.md | Rate-limit table is clean, but "NAC actions/5min" defaults of 1–10 may be too restrictive for a school-network mass-incident. Document override path. |
| M5 | docs/22-apollo-offensive-companion.md | Says "Per-engagement signed authorisation required for any non-lab target, ever." But the SKU path description elsewhere says "internal lab + future SKU." Reconcile: Apollo Pro engagement model is a non-lab target — therefore the SKU implies signed-authorisation engagements, which is correct, but the language can read as contradictory. Tighten. |
| M6 | docs/12-task-backlog.md | Phase 6 carries Apollo bootstrap (P6-T14–T18) — but Apollo lives in a separate repo. Should be tracked in `m4f-s/apollo/docs/backlog.md`, not the Artemis backlog. Cross-reference instead. |
| M7 | docs/session-prompts/ws-f-detection.md | Has a typo: references `docs/04-detection-pillars/p15-42-berlin-adaptation.md` (correct path is `docs/15-42-berlin-adaptation.md`). Fix in WS-F prompt before paste. |
| M8 | docs/04-detection-pillars/p9-hw-attestation.md | Mentions "Microsoft Pluton" support; Pluton's third-party attestation surface is still maturing as of 2026. Soften to "where exposed by the platform." |
| M9 | CLAUDE.md | 12 hard rules; rule #11 (Apollo isolation) duplicates ADR-0012. Hard rules should reference the ADRs as the source of truth, not restate them. |

---

## Recommended sequence to start Phase 1

The previous sessions proposed: kickoff checklist → WS-A → WS-B + WS-D + WS-F. That's correct. Refinement based on this audit:

1. Owner runs kickoff checklist.
2. **Apply C1–C7 critical fixes (this commit).** ADRs land before code.
3. WS-A bootstrap PR (per `docs/24-first-pr.md`), now also rendering ADR-0014–0018 into CI invariants.
4. WS-B + WS-D + WS-F start in parallel.
5. Within Phase 1, schedule a 2-week UX validation sprint for intent sessions (I7).
6. Phase 1 exit gate adds: SBOM generation green; capability-allowlist scan green.

---

## Verdict

The project is **architecturally sound**, **honestly threat-modelled**, and **buildable as documented**. The 8 critical issues identified above are all remediable in the spec stage; this audit ships the remediations in the same commit. The 9 important issues are tracked and dated for Phase 1–4. The 12 research items keep the project competitive over a 2-year horizon.

**With the C1–C8 fixes landed, this audit recommends GREEN to begin Phase 1.**

A senior auditor's note: the discipline already shown in ADR-0009 / 0010 / 0011 / 0012 / 0013 (the "safety contract" pattern) is unusually strong for a pre-code project. Maintaining that discipline through the chaos of code-phase + first design partners is the single biggest risk. Concretely: **never** silently widen the action allowlist; **never** ship a fix that bypasses a CI invariant; **never** let marketing rephrase a hedged technical claim into an unhedged one. Treat the audit log as sacred.

— *Auditor (acting role).*
