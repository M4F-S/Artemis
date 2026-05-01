# P3 — Endpoint Deception

**Gap closed:** Tier 1 #4 — endpoint-level deception is mostly an enterprise-only product category; SMB has nothing comparable.

## Principle

Deception flips the asymmetry: an attacker only has to be right once to succeed; with deception, they only have to be wrong once to be caught. Network-level deception is well-understood; **per-endpoint** deception is rare.

## Deception assets

Generated per-host, per-tenant (uniquely watermarked, central registry):

| Asset | Location (Linux example) | Tripwire mechanism |
|---|---|---|
| Decoy AWS creds | `~/.aws/credentials` (decoy profile) | eBPF `file_open` + AWS API honeytoken (CloudTrail webhook) |
| Decoy SSH key | `~/.ssh/id_rsa.bak` | `file_open` + key-fingerprint detection if used anywhere we observe |
| Decoy kubeconfig | `~/.kube/config-staging-old` | `file_open` |
| Decoy session cookies | Browser profile (sentinel rows in `Cookies` SQLite) | Browser extension watch + outbound use detection |
| Decoy `.env` | repo root canaries | `file_open` |
| Decoy database creds | `~/.pgpass.old` | `file_open` |
| Decoy "passwords" file | `~/Documents/passwords.txt` (consumer-facing) | `file_open` |
| Decoy registry keys (Win) | bait HKCU paths | minifilter / ETW reg events |
| Decoy network shares | bait SMB share with telemetry on access | WFP / ES network event |

## Honeytoken integration

- Decoy AWS keys are real-but-quarantined creds in an Artemis-owned AWS sub-account; any STS call → CloudTrail → tenant alert with attacker IP.
- Decoy GitHub tokens via GitHub's [Secret Scanning Partner Program](https://docs.github.com/en/code-security/secret-scanning).
- Decoy Slack bot tokens via Slack's verification webhook.

## Placement policy

- Per-host fingerprint determines exact filenames so the same decoy doesn't appear on every endpoint (would otherwise fingerprint Artemis itself).
- Density tuned per role: `developer` host gets dev-flavoured decoys; `finance-laptop` gets ERP-/banking-flavoured decoys.
- Operator can freeze placement (audit / compliance environments).

## Tripwire severity

- Read-only access to a canary → **HIGH** (curiosity, possibly automated scan).
- Write/exfil-style access → **CRITICAL** (active intrusion).
- Decoy credential *used* against the honeytoken endpoint → **CRITICAL** (this is unambiguous).

## Anti-detection

- Decoys must withstand attacker fingerprinting:
  - File mtimes randomised within a plausible window.
  - File contents structured like real ones (passing `aws sts get-caller-identity`-style validation in honeytoken sub-account).
  - Decoy paths drawn from observed legit patterns, not a fixed list.
- Periodic rotation (every 30–90 days) so leaked layouts go stale.

## Coverage

- ATT&CK: T1552 (Unsecured Credentials), T1083 (File and Directory Discovery), T1555 (Credentials from Password Stores), T1538 (Cloud Service Dashboard).
- Catches T0–T3 reliably during the discovery phase (which is the earliest reliable detection point in many intrusion chains).
