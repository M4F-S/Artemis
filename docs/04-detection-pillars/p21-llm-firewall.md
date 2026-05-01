# P21 — LLM / AI-App Firewall

P1 protects the **user** of an AI agent. P21 protects the customer's **own AI applications** — i.e., the SaaS or internal product they ship that calls an LLM provider on behalf of their end-users. This is the fastest-growing attack surface of 2025–2026 (Lakera Guard, Protect AI, Prompt Security, Microsoft Entra Prompt-Injection Protection, Thales AI Security Fabric, etc.).

## Deployment

- **Sidecar proxy** in the customer's compute (Rust binary; Docker image; K8s sidecar via P20 admission controller).
- **SDK shim** for Python / TypeScript clients of `anthropic` / `openai` / `google-generativeai` etc. — drop-in `from anthropic import Anthropic` replacement that auto-routes through the proxy.
- **Standalone gateway** mode (cluster-internal `https://artemis-llm-gw/`).

All three modes share the same policy/inspection backend.

## Inbound (prompt) inspection

- **Prompt-injection classifier** (semantic + heuristic) on user-supplied content and on retrieved context (RAG sources).
- Pattern matchers for common jailbreaks (DAN-class, role-override, system-prompt extraction, instruction overrides).
- PII / secret / credential detection in user prompts (block or redact).
- Per-user / per-app rate limits to deter automated probing.

## Outbound (response) inspection

- Sensitive-data egress filter: regex + ML for PII, financial, secrets in model output.
- Tool-call pre-flight: if the customer's app gives the LLM tools, every proposed tool-call is validated against the per-app schema and policy *before* execution.
- Harmful-content classifier (per the customer's policy framework).
- **Citation-reality check**: if the model claims it sourced from a doc, verify the doc actually contains the claim — a cheap defence against hallucinated authority.

## Model-extraction defence

- Volumetric anomaly: per-user query rate, query similarity (suspect: many similar prompts probing decision boundary).
- Watermark detection: distinctive output patterns suggesting the customer's model is being distilled.

## Audit + observability

- Per-call log: prompt summary (DP'd / redacted), tool calls, verdict.
- Customer dashboard: blocked counts by reason, top abusive principals.
- OCSF event types for prompt-injection, data-exfil-attempt, model-extraction-attempt.

## Privacy

- Customer-controlled redaction policy.
- Zero-retention mode: log metadata only, never prompts/responses.
- Local model option for the inspector classifiers (no cloud round-trip).

## Coverage

- ATT&CK extensions for AI systems (MITRE ATLAS): AML.T0051 (LLM Prompt Injection), AML.T0052 (Phishing), AML.T0024 (Exfiltration via Inference API), AML.T0029 (Denial of ML Service).
- Differentiator: most existing players treat this as a separate product; Artemis bundles it with the rest of the platform so the same SOC sees the same alerts in the same console.
