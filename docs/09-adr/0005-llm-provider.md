# ADR-0005 — LLM provider strategy

## Status
Accepted (Phase 0).

## Context
P5 (SOC copilot) and P7 (provenance narratives) and P13 (executive reports) all need an LLM. Options: Anthropic, OpenAI, Google, AWS Bedrock, Azure OpenAI, local Llama 3.x / Mistral.

Considerations: privacy posture, instruction-following quality, prompt-injection resistance (relevant since input is partially attacker-controlled), pricing, region pinning, BAA / DPA availability.

## Decision
- **Primary:** Anthropic Claude (Sonnet for routine, Opus for executive reports). Prompt caching mandatory.
- **Fallback:** OpenAI GPT family (region-pinned).
- **Air-gapped / offline:** local Llama 3.x quantised via `llama.cpp`.
- Provider abstracted behind an internal interface; per-tenant config picks the path.

## Rationale
- Claude's documented superior resistance to indirect prompt injection (relevant since alerts contain attacker-controlled strings).
- BAA available; multi-region.
- Prompt caching meaningfully reduces per-alert cost.
- Multi-provider abstraction keeps us off any single-vendor track.

## Consequences
- All prompts must be designed for the abstraction's lowest-common-denominator capabilities; provider-specific tricks are isolated.
- Output must always be schema-validated; we don't rely on a particular provider's tool-use guarantees.
- Cost is acceptable at SMB volumes (~$0.30–0.80 / endpoint / month) thanks to caching.
