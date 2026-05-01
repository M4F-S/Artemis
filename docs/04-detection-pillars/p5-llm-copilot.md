# P5 — LLM SOC-Copilot

**Gap closed:** Tier 3 #13 — enterprise has Charlotte AI / Microsoft Copilot for Security. SMBs do not. Most existing tooling speaks "alert syntax" — Artemis must speak English.

## Capabilities

1. **Plain-English alert explanations.** Each alert ships with a one-paragraph "what happened, why we flagged it, what to do next."
2. **Why-was-this-blocked Q&A.** End users can ask, "I tried to install X and it was blocked — why?" and get a verifiable answer with links to the rule + observed events.
3. **Triage suggestions.** Severity calibration, suggested next steps, related historical alerts.
4. **Containment proposals.** "Recommend isolating host X, killing process Y, revoking session Z." Each proposal mapped to a specific Active-Defense playbook (P14) — never free-form action.
5. **Executive summary.** Weekly / monthly narrative reports for owners and boards (P13).
6. **Compliance evidence.** "Generate the SOC 2 access-monitoring evidence for Q2" — synthesises from telemetry + alerts.

## Architecture

```
[Alert + Provenance + Telemetry slice]
        │
        ▼
[Redactor / DP filter] ── only minimised, structured, schema-validated input goes to LLM
        │
        ▼
[Prompt assembly]
   • system prompt (cached) — long, stable, schema-locked output
   • user prompt — alert in JSON
   • tool definitions — strictly typed
        │
        ▼
[Anthropic Claude API (primary) | OpenAI (fallback) | local Llama-3 (offline)]
        │
        ▼
[Output validation]
   • JSON schema check
   • policy gate: no free-form shell / actions
   • citation check: every claim must reference an event ID
        │
        ▼
[Console UI / report generator]
```

- **Prompt caching** is mandatory (system prompt + tenant context = stable; per-call delta tiny).
- **No tool execution by the LLM** — all containment actions pass through a deterministic policy engine. The LLM proposes, humans (or pre-approved playbooks) dispose.
- **Hallucination guard:** output must cite specific event IDs; if the cite doesn't exist in the input bundle, response is rejected and we degrade to template explanation.

## Privacy

- LLM provider sees: redacted alert JSON + minimal context (process name, hash, parent chain — no document bodies, no clipboard, no keystrokes).
- Customer can pin LLM region (US/EU).
- Customer can opt for the local-Llama path; in that mode no data leaves the tenant cloud.

## Adversarial considerations

- The LLM input is partly attacker-controlled (e.g., process command-line arguments). Treat all input as untrusted.
- Use Anthropic's tool-result-parsing defence pattern + structured schemas; don't let raw alert content escape into instruction-position.
- Periodic red-team prompt-injection tests in CI.

## Cost

- Estimated $0.30–$0.80 / endpoint / month at SMB alert volumes with prompt caching. Built into pricing.
