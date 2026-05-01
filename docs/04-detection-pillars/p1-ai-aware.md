# P1 — AI-Aware Defence

**Gap closed:** Tier 1 #2 (browser-agent / prompt injection) and Tier 1 #3 (LLM-fed runtime malware / "vibeware" / MalTerminal-class).

## Why this matters

- OpenAI publicly stated in late 2025 that indirect prompt injection in AI browsers may never be fully patchable.
- MalTerminal-class malware embeds an LLM API key, retrieves payloads at runtime, and `exec`s the returned content — defeats static signatures by definition.
- "Vibeware" — LLM-mass-produced polymorphic malware — was identified by CSA in March 2026 as a step-change in attacker throughput.

## Detection sub-systems

### P1.1 LLM-fed runtime malware

Heuristic chain (any 3 of 4 → HIGH alert):

1. **Embedded credential pattern** in process memory or recent file reads matching `sk-[A-Za-z0-9]{20,}`, `xai-...`, `claude-...`, etc.
2. **Outbound TLS** to known LLM API endpoints (`api.openai.com`, `api.anthropic.com`, `api.x.ai`, `generativelanguage.googleapis.com`, `api.deepseek.com`, `api.mistral.ai`, public Bedrock/Vertex IPs).
3. **Response body → execve / shell / eval** within N seconds. Captured by combining WFP/eBPF socket events with subsequent `bprm_check_security` / `process.exec`.
4. **Process is not on the LLM-API allowlist** (per-tenant: which apps are *expected* to talk to LLM APIs — IDEs, ChatGPT desktop, etc.).

Implementation notes:
- Allowlist seeded by behavioural learning over the first 7 days, then operator-confirmed.
- We never read the response body content (privacy); we read **size + timing + subsequent exec**.

### P1.2 Browser-agent / prompt-injection guard

In the MV3 extension:

1. DOM scan for high-risk patterns:
   - Hidden text (`display:none`, `visibility:hidden`, `aria-hidden`, white-on-white, off-screen) containing imperative verbs (`ignore previous`, `system:`, `run`, `download`, `send to`, `transfer`, `purchase`, etc.).
   - Base64-encoded blobs > N chars on pages loaded by AI agent extensions.
   - Comment / metadata fields containing instruction-like content.
2. Tool-call audit for sibling AI agent extensions: snapshot the agent's planned tool calls (where the extension exposes them via standard MV3 messaging). Flag if planned calls touch:
   - `chrome.cookies`, password manager APIs.
   - File-download APIs with destinations outside the user's expected folders.
   - Form submissions with credentials to non-current-origin endpoints.
3. Origin-trust scoring: agent tool-calls against new / low-rep origins downgraded automatically.

### P1.3 Vibeware / mass-produced polymorphic malware

- Static fingerprinting is intentionally lightweight (it loses), but we keep YARA for known families.
- Primary defence is the **certified-robust ML** detector (P8) running on dynamic features (syscall n-grams, network metadata, write/exec patterns).
- Bonus: detect "AI-generated code" markers in dropped scripts (LLM idiosyncrasies — over-commenting, identical refactor patterns) as a *weak* signal that combines with others.

## Coverage

- Maps to MITRE ATT&CK T1059 (Command & Scripting Interpreter), T1105 (Ingress Tool Transfer), T1027 (Obfuscated Files), T1566.002 (Spear-phishing Link), T1204 (User Execution).
- Browser-side maps to a new threat surface MITRE has not yet codified; we'll publish telemetry to push for an ATT&CK extension.

## Open questions

- Should we ship a default-deny outbound LLM-API policy on managed servers? Tempting but breaks legitimate use; flagged for design partner survey.
- How aggressively to block vs. log on indirect prompt injection? Default: log + warn the user inline; block only on explicit credential / file actions.
