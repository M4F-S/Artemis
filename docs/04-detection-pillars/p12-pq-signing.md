# P12 — Post-Quantum Code Signing

**Gap closed:** Tier 3 #14. NIST has standardised ML-DSA (FIPS 204) and SLH-DSA (FIPS 205); CA/Browser Forum is moving towards them. No mainstream AV verifies PQ signatures yet because the ecosystem hasn't required it. Artemis ships PQ-aware verification from day 1 so we age well.

## Scope

PQ verification applies to:
- Artemis's own agent + rule + model updates (canonical, mandatory).
- Customer binaries (optional, per-policy).
- Driver / kernel module loads (P9 integration).

## Algorithms

- **ML-DSA-65** (Dilithium-3) for general signing — good performance / size trade-off.
- **SLH-DSA-128s** (SPHINCS+) for highest-assurance signing of Artemis root keys (stateless hash-based, conservative).
- **Hybrid** signatures: ML-DSA + Ed25519 during transition. Code refuses to verify if either component fails.

Implementation: `liboqs` for ML-DSA / SLH-DSA; standard `ed25519-dalek` for the classical part.

## Update channel

- All Artemis updates are double-signed (ML-DSA + Ed25519).
- Update verifier embedded in the agent; refuses any update missing either signature.
- Public keys distributed with the agent; rotation via prior-signed manifest.

## Customer-binary policy

Tenant admins can require:
- Block unsigned binaries.
- Block classically-signed-only binaries (post-2030 default).
- Allow hybrid; allow PQ-only.
- Per-OS overrides (e.g. Linux distro packages remain classical for now).

## Limitations

- Performance: ML-DSA verify is fast (~150 µs); SLH-DSA verify is slow (>10 ms) — acceptable for boot-time / install-time checks, not per-syscall.
- Ecosystem support: not all OS loaders honour PQ signatures yet. We complement, not replace, OS code-signing.

## Roadmap

- v1: Artemis-internal PQ signing only.
- v2: customer binary policy.
- v3: integration with code-signing CAs as they roll out PQ certs.
