# P18 — Email & Phishing Protection

**The #1 initial-access vector deserves a dedicated pillar.** Identity (P10) catches credential abuse *after* the click; P18 catches the click itself.

## Integration mode

- **API-mode** (default for SMB): connect to Microsoft 365 / Google Workspace via Graph / Gmail API; scan inbound mail post-delivery, claw back malicious mail.
- **Inline / SEG-mode** (advanced): MX redirect through an Artemis edge for prevention before delivery.
- Both modes share the same detection backend.

## Detection

### M1 Identity-coupled phishing

- Cross-reference sender vs. P10 known-good identity graph; lookalike-domain detection (homoglyph, typosquat).
- Reply-chain hijack detection: existing thread continuation from a slightly different sender → HIGH.
- Sender-impersonation of executives / vendors → CRITICAL (Business Email Compromise pattern).

### M2 URL detonation

- Real-time URL fetch in an isolated sandbox before delivery.
- DOM-pattern matching for credential-harvest and prompt-injection landing pages.
- Branded-page detection (looks like Microsoft/Google login, not on official domain).

### M3 Attachment analysis

- Static + dynamic detonation in a microVM.
- LLM-fed-malware patterns (P1) triggered on attachment payloads.
- Macro / DDE / OLE active-content extraction.
- Password-protected archive heuristics (very common phish technique).

### M4 LLM-generated phish detection

- Stylometric + structural features of LLM-generated copy.
- Cross-tenant prevalence: a near-identical lure observed at multiple tenants in the federation = CRITICAL signal.

### M5 Honeytoken inboxes

- Per-tenant decoy mailboxes (P3 extension): published in directories, never legitimately used. Any inbound = HIGH ground-truth signal of a discovery probe.

## Response

- Quarantine; claw-back across the organisation; user warning.
- Auto-train: confirmed-malicious lures feed the phishing-classifier.
- Identity-side: if a user clicked, hand off to P10 / P14 for session/MFA actions.

## Privacy

- Email body content is processed locally / in-tenant where possible; only feature vectors and verdicts egress.
- Body is **never** sent to the LLM provider raw; structured extracts only.
- Customer can disable individual sub-detectors (e.g. attachment detonation) for compliance reasons.

## Coverage

- ATT&CK: T1566 (Phishing), T1566.001/.002/.003 (sub-techniques), T1534 (Internal Spearphishing).
- Closes the most common entry vector for SMB intrusions.
