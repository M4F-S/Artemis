# P6 — Privacy-Respecting Telemetry

**Gap closed:** Tier 2 #9 (federated/HE-encrypted IoC sharing) and Tier 2 #10 (differential privacy on-device).

Modern EDR slurps raw event streams. That is a privacy and compliance problem in the EU and increasingly in the US. Artemis treats privacy as a feature.

## P6.1 Differential privacy on egress

- Each event class has a privacy budget (ε per day per user).
- High-risk classes (process exec, network connect, file write to sensitive paths) — ε ≈ 1.0; modest noise.
- Low-risk classes (counters, aggregate health) — ε ≈ 0.1.
- Identifiers (usernames, hostnames) are tokenised at egress; the control plane sees pseudonyms only.
- Document content, clipboard, keystrokes — **never collected**, full stop.

Mechanism: local randomised response on enumerated categorical fields; Laplace noise on counters.

Trade-off: detection sensitivity drops slightly. We compensate by keeping high-fidelity events local and only egressing summarised features unless a `tenant_admin_consent_full_capture = true` flag is set during incident investigation.

## P6.2 Federated IoC sharing

Cross-tenant intelligence is hugely valuable but normally requires sharing telemetry. Artemis avoids that:

- Each tenant computes local feature vectors (e.g. behavioural ML embeddings of suspicious processes).
- Vectors encrypted under CKKS (homomorphic) using OpenFHE / Microsoft SEAL.
- Aggregation server sums encrypted vectors and produces an updated community model — sees only ciphertext.
- The aggregated, decrypted model is signed and pushed back to tenants.

This gives the herd-immunity benefits of XDR without the data-pooling risk. Performance cost ~120–200 ms per round; updates are nightly, not real-time.

## P6.3 BYOK for raw blobs

Some tenants need to retain raw event blobs (forensics, incident response). Those go to a tenant-controlled object store (S3/R2) encrypted with a customer-held KMS key. Artemis can request decryption with audit, but cannot read at rest by default.

## P6.4 Right-to-erasure

- Per-user pseudonym → real identifier mapping kept in a tenant-controlled vault, not Artemis-controlled.
- A tenant admin can issue a deletion request that clears the mapping → all egressed data becomes permanently un-linkable.

## Compliance posture

- GDPR Art. 25 (privacy by design) — DP, BYOK, pseudonymisation.
- HIPAA — BAA available; PHI never collected by default.
- SOC 2 Type II — control objectives mapped to P6 mechanisms.
- NIS2 / DORA — telemetry scope documented for regulator audits.

## Adversarial considerations

- DP can be poisoned by an attacker on the endpoint trying to flood specific event categories. We mitigate with per-category rate caps and a non-DP'd "agent health" stream that the control plane uses to detect the flood itself.
