# P22 — Threat Hunting + DFIR + Backup Integration

The "do something with what you've got" pillar. P7 builds the provenance graph; P5 narrates alerts; P22 turns those into a hunter's notebook, an IR runbook engine, and a backup/restore integration that makes self-healing (P15) actually safe.

## H1 Hunter's notebook

- Web UI on top of the provenance graph + event store (Cypher + ClickHouse SQL).
- Saved queries, parameterised, sharable across the tenant.
- Hypothesis-driven hunting templates (e.g. "find PowerShell descendants of Office processes that wrote to startup folders").
- Notebook entries are versioned; analysts cite specific event IDs (the same citation discipline as P5).

## H2 IR runbook engine

- Library of structured runbooks per scenario (ransomware, BEC, insider, supply-chain, compromised dev).
- Each runbook is a sequence of decision nodes + actions + evidence captures.
- Runs as a guided experience for the analyst; auto-fills evidence; offers next-best-action.
- Outcomes (what worked, what didn't) feed the RL agent in P16.

## H3 Forensic timeline

- For each incident, an automatically-built timeline:
  - Initial vector (per provenance root).
  - Lateral steps with timestamps + identities.
  - Persistence mechanisms.
  - Exfiltration attempts.
  - Containment / remediation steps.
- Exportable as a signed PDF (P13).

## H4 Backup integration

Native connectors to:
- **Veeam** (B&R API).
- **Rubrik** (REST).
- **AWS Backup** + EBS snapshots.
- **GCP Backup-DR**, Azure Backup.
- **restic** (open-source agent-side).
- **Local snapshots**: Btrfs / ZFS / APFS / VSS (P15 S2).

Capabilities:
- Verify backups exist + are recent + are immutable.
- Periodic restore test on a sandbox (catches "the backup that doesn't actually restore" failure mode).
- On confirmed-ransomware, drive the restore plan: pick last clean snapshot via provenance (find the encryption start time, restore from before).
- Customer-held keys (BYOK).

## H5 Threat-hunt subscription

- Curated weekly hunts pushed by Artemis: "this technique was observed in the wild this week — run this query against your environment."
- Equivalent to a managed threat-hunt service for tenants without a SOC.

## Coverage

- The "what do I do now?" gap that's the #1 SMB pain after detection.
- Makes self-healing P15 *trustworthy* (you only auto-restore from a snapshot you've verified).
- Closes the loop with P16 — every IR runbook outcome becomes training data.
