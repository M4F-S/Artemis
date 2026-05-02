# P8 — Certified-Robust ML

**Gap closed:** Tier 2 #7. Adversarial ML attacks on malware classifiers are well-established (gradient-based feature manipulation, byte-level perturbations on PE files, etc.). Defences with **provable** guarantees exist in research (DRSM-style randomised / de-randomised smoothing) but no shipping AV exposes a "certified" verdict.

## Honest framing (non-negotiable for marketing)

The "certified" guarantee is **bounded** and must be communicated as such. Specifically:

- Certification holds **only** within the chosen perturbation norm (typically ℓ₂ on dynamic features, byte-window for static byte-level classifiers).
- The certified radius is typically small — often a few bytes or a small ε — for malware classifiers.
- A certified verdict means: "no adversarial perturbation within this bounded norm + radius can flip the prediction." It does **not** mean "this verdict is universally correct."
- An attacker working *outside* the chosen norm (e.g. structural rewrite of the malware) can still evade.

Therefore:
- The product UI distinguishes verdicts as `certified-clean`, `certified-malicious`, `uncertain — escalate`. The certified radius (numerical) is shown alongside.
- Marketing must not abbreviate "certified-robust within bounded perturbation" to "certified." Per ADR-0017 / ADR-0018 and the senior audit (`docs/29-senior-audit.md`, issue C5).

## Goals

- For a chosen feature space, classifier output is robust to adversarial perturbations of bounded size — and we can **prove it** for each prediction.
- "Certified clean" / "certified malicious" verdicts when applicable; "uncertain — escalate" when not.
- Operator UI distinguishes certified vs. uncertified verdicts so analysts know what to trust.
- The certified radius is reported per prediction; a tiny radius means "barely certified," not "certified."

## Approach

- **De-Randomised Smoothing on Malware (DRSM)** style: for static binary classification, ablate windows of bytes and aggregate over many ablated views. Provides certified robustness against bounded byte modifications.
- **Randomised smoothing** on dynamic feature vectors (syscall n-grams, network metadata): Gaussian noise on input + majority vote → certified ℓ₂-radius around the prediction.
- **Ensemble** of static + dynamic classifiers; output is certified only when all components agree at a chosen confidence.

## Pipeline

```
[Sample] ─► [Feature extraction] ─► [Smoothed predictor (N noisy passes)]
                                          │
                                          ▼
                       [Aggregated label + certified radius r]
                                          │
                            ┌─────────────┴─────────────┐
                            ▼                           ▼
              [r ≥ threshold → verdict]   [r < threshold → escalate to cloud]
```

Cloud-tier may run a heavier, more expensive smoothed model, plus the provenance/ITDR signals.

## Model lifecycle

- Models trained from labelled corpora (EMBER for PE, in-house corpora for ELF / Mach-O / scripts / wasm).
- Adversarial training on the smoothed objective (continuous-attack approximation for tractability).
- Monthly retrain with held-out red-team set.
- Models signed (ML-DSA + Ed25519 hybrid per P12 + ADR-0015) and shipped through the update channel (ADR-0016).

## Drift handling

- Concept-drift detection (KS-test on feature distributions per OS / role).
- When drift detected → escalate uncertain calls; human-in-the-loop label requests.

## Limitations (honest)

- "Certified" applies only to the chosen feature space and perturbation norm. A clever attacker working *outside* that norm (e.g. structurally rewriting the malware) can still evade.
- The certified radius is usually small for malware. A small radius is honest, not impressive.
- Adversaries who control the training pipeline (federation poisoning) need separate defences (P16 + ADR-0014).
- Therefore P8 is one layer in defence-in-depth, **not** a replacement for behavioural detection (P1, P3, P4, P7).

## Coverage

- Strengthens any rule that consumes ML scores. Particularly helpful against:
  - Polymorphic / obfuscated samples (T1027).
  - Mass-produced LLM-generated variants (vibeware).
- A certified radius is an audit-time exhibit (the model gave this prediction with this provable robustness); useful in P13 compliance reports.
