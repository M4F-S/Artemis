# 01 — Threat Model

## Scope

This threat model covers the Artemis product itself **and** the customer's endpoint estate that Artemis is meant to protect. Out-of-scope: physical attacks, side-channel attacks on the customer's CPU, and nation-state supply-chain compromise of the underlying OS vendor.

## Adversary tiers

| Tier | Profile | Capabilities | Example TTPs |
|---|---|---|---|
| **T0** | Opportunistic / commodity | Off-the-shelf RAT, phishing kits, infostealers | Email phishing → Lumma stealer → cookie theft |
| **T1** | Commodity ransomware affiliate | LOLBins, off-the-shelf droppers, RMM abuse | RDP brute → Cobalt Strike → Akira ransomware |
| **T2** | Targeted criminal | Custom loaders, EDR bypass, AD attacks | Bring-your-own-vulnerable-driver → DCSync |
| **T3** | APT / state-aligned | 0-days, kernel rootkits, eBPF abuse | LightSpy, BPFDoor, custom UEFI implant |
| **T4** | AI-augmented attacker (new) | LLM-generated polymorphic loaders, prompt-injection of agents, vibeware | MalTerminal-class, "Imprompter"-style indirect injection |
| **T5** | Malicious insider | Legitimate creds, knowledge of layout | Data exfil via personal cloud, sabotage |
| **T6** | Autonomic-loop abuser | Targets Artemis's own learning / response loop | Federation poisoning, RL-policy gaming, BAS-engine subversion, false-flag triggering of auto-rollback |

Artemis must demonstrably handle **T0–T2 + T4 + T6** at v1. T3 and T5 are stretch (T3 needs hardware partnerships; T5 needs deeper UEBA). T6 is mitigated by the autonomic-safety contract in [ADR-0010](09-adr/0010-autonomic-safety.md) and the rollback-safety contract in [ADR-0011](09-adr/0011-self-healing-rollback.md).

## Assets

1. Customer endpoints (OS, kernel, userland processes).
2. User identity tokens (OAuth, Kerberos, JWTs in browser storage).
3. Local secrets (SSH keys, AWS creds, kubeconfigs, browser cookies, password vaults).
4. Source code & build pipelines (developer endpoints).
5. Email mailbox content + auth (P18 protection scope).
6. Network traffic on the customer LAN / VPC (P19).
7. Cloud workloads + cloud control plane (P20).
8. Customer's own AI applications + their LLM-API quotas / models (P21).
9. Backups + immutable snapshots (P22 / P15).
10. The Artemis agent itself (its config, its keys, its detection logic).
11. The Artemis control plane (multi-tenant SaaS, customer telemetry).
12. **The Artemis Knowledge store** (rules, models, RL policies, attack-graph cache) — *new in v1, primary target of T6*.
13. The federated IoC exchange.

## Trust boundaries

```
[Untrusted Internet]
        │
        │  (DNS, HTTP, package registries, OAuth providers, LLM APIs)
        ▼
[Customer Endpoint Userland]      ← T0–T2, T4, T5 operate here
        │  syscall / LSM / minifilter / ES boundary
        ▼
[Customer Endpoint Kernel]        ← T3 operates here; eBPF/rootkits live here
        │  hardware boundary
        ▼
[CPU / TPM / Secure Enclave]      ← root of trust for P9
        ─────────────────────────
[Artemis Agent ⇄ Control Plane]   ← mTLS, device certs
        │
        ▼
[Artemis Control Plane]           ← per-tenant isolation; staff access
        │
        ▼
[Federated IoC Exchange]          ← HE-encrypted; cross-tenant
```

Any data crossing a `─` line must be authenticated, integrity-checked, and minimised.

## STRIDE — top components

### Endpoint sensor
| Threat | Vector | Mitigation |
|---|---|---|
| Spoofing | Malware impersonates Artemis service | Code-sign agent; agent name in tamper-protected list |
| Tampering | Attacker disables/modifies agent | Self-protection (kernel-level on Win/Linux), watchdog, control-plane heartbeat alarm |
| Repudiation | Insider deletes local logs | Logs streamed off-host; signed event chain (hash-linked) |
| Information disclosure | Telemetry leaks PII | Local DP + field-level redaction before egress |
| Denial of service | Agent killed → blind sensor | Watchdog auto-restart; missing-heartbeat alert |
| Elevation of privilege | Sensor bug grants kernel exec | Rust core, fuzzed; minimal kernel-mode footprint |

### Control plane
| Threat | Vector | Mitigation |
|---|---|---|
| Spoofing | Rogue agent enrolment | Per-device enrolment cert + pre-shared customer secret |
| Tampering | Cross-tenant data leak | Per-tenant DB schema + row-level + audit |
| Repudiation | Admin denies action | Append-only audit log; admin SSO + MFA enforced |
| Information disclosure | Insider snoops customer data | Customer-held encryption keys (BYOK) for raw blobs |
| Denial of service | Volumetric ingest flood | Per-tenant rate limits, circuit breakers, backpressure |
| Elevation of privilege | Tenant A → Tenant B | Strict tenant ID propagation, fuzzed in CI |

### LLM copilot
| Threat | Mitigation |
|---|---|
| Prompt injection from telemetry | All telemetry treated as untrusted input; structured tool-result parsing; LLM cannot auto-execute containment without human approval |
| Data exfiltration via LLM | LLM provider only sees redacted, DP'd extracts; raw data never sent |
| Hallucinated remediation | Containment actions gated by deterministic policy engine, not LLM output |

### Active Defense Agent (P14)
| Threat | Mitigation |
|---|---|
| Misconfigured action attacks innocent third party | All P14 actions are perimeter-internal by default; outbound actions (abuse-report, takedown) gated by per-jurisdiction policy + human approval |
| Legal exposure | Disabled by default; requires legal-clearance flag + signed acknowledgement; tenant-admin-only |
| Used as offensive weapon | Hard refusal of any action targeting attacker infrastructure (no ports scanned, no payloads sent); enforced in code, not just policy |
| **Tier-4 NAC abuse as DoS** (mass deauth) | Multi-signal gate (ADR-0011) + per-tenant rate limit (≤3 devices/5min) + 60-second cancel + admin notification + reversible DenyToken |
| **Compromised NAC connector deauths arbitrary devices** | Connector instance scoped per tenant; audit log per call; rotation of connector creds; periodic dry-run (ADR-0013) |
| **Tier-5 escalation report leaks PII** | Default-pseudonymous; explicit re-identification action audited; templates reviewed (ADR-0013) |

### NAC connector layer (P14 capability G)
| Threat | Mitigation |
|---|---|
| Connector cred theft | Stored in tenant-controlled KMS; rotated periodically; least-privilege per backend |
| Connector backend (FreeRADIUS / pfSense / UniFi / Cisco / Aruba / Meraki) compromised | Connector treats backend as untrusted post-compromise; rate-limit + audit |
| Cross-tenant connector misuse | NacConnector instance bound to tenant; tenant ID propagated; CI invariant |

### Apollo (offensive companion, separate repo)
| Threat | Mitigation |
|---|---|
| Apollo binaries / scenarios leak into Artemis customer agents | Independent build, independent signing keys, CI invariant in Artemis pipeline (ADR-0012) |
| Apollo used against unauthorised target | Triple-layer enforcement (load-time + pre-flight + netns); signed authorisation hash (ADR-0012) |
| Mutation engine synthesises novel malware | Bounded mutation depth; parent-technique grounding; library is closed set (ADR-0012) |
| Apollo IP leaks | Closed source; access tightly controlled; binaries never on customer endpoints |

### Autonomic loop (T6 surface)
| Threat | Mitigation |
|---|---|
| Federation training-data poisoning | Byzantine-robust aggregation; per-tenant contribution caps; outlier quarantine (ADR-0010) |
| Targeted local model poisoning | Local model is one signal; ensemble + rule + provenance vote |
| RL agent driven into bad-action region | Hard policy gate; RL ranks from fixed allowlist (ADR-0010) |
| Operator-feedback gaming | FPR tuning bounded; promotion requires true-positive (ADR-0010) |
| LLM rule-synthesiser injection | Schema validation + human review queue (ADR-0010) |
| Knowledge-store tampering | Sign + hash-chain + append-only audit (ADR-0010) |
| Triggering auto-rollback as destructive primitive | Multi-signal confirmation + tenant pre-authorisation + cancel window (ADR-0011) |

## Anti-goals (we will NOT do)

- Hack-back into attacker systems (CFAA, EU/UK CMA equivalents).
- Surveil end-user content (we monitor metadata + behaviours, not document contents).
- Backdoor encryption or undermine local password managers.
- Sell raw customer telemetry, even anonymised.
