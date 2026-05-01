# P9 — Hardware-Rooted Attestation

**Gap closed:** Tier 2 #8. TPM, Intel CET, ARM PAC, and remote attestation each exist in isolation, but no SMB-friendly product unifies them into a coherent "trust the hardware, not just the software" policy.

## Goals

1. Establish a hardware root of trust for every Artemis-protected endpoint.
2. Use that root to enforce policies like "only run binaries with CET shadow stack + IBT enabled" and "only enrol agents whose firmware integrity matches the gold measurement."
3. Detect and report degradation (Secure Boot off, TPM cleared, CFI compiled out).

## Components

- **TPM 2.0** (or Microsoft Pluton, Apple Secure Enclave, Android StrongBox).
- **Intel CET** — shadow stack + Indirect Branch Tracking.
- **ARM PAC** — Pointer Authentication.
- **AMD SEV-SNP / Intel TDX** — for server workloads needing memory encryption.
- **UEFI / Secure Boot** measurements.
- **DRTM** (Dynamic Root of Trust for Measurement) where available — Intel TXT, AMD SKINIT.

## Capabilities

### Enrolment-time attestation
- Agent presents TPM quote + EK certificate to control plane.
- Control plane verifies against vendor CAs (Microsoft, Intel, AMD, Apple).
- PCR values must match a tenant-defined gold set (built at first enrolment, change-controlled).

### Continuous attestation
- Periodic re-quote (default hourly).
- Significant PCR drift → MEDIUM alert; deviation from policy baseline → HIGH.

### CFI policy enforcement
- Per-binary, on `bprm_check_security` / process-create:
  - Static check for CET hints (PE / ELF feature bits).
  - Static check for PAC instructions on ARM.
  - Optional **block** of binaries without CFI when policy = `enforcing` and the binary is not on the legacy-allowlist.

### BYOVD blocker (Windows)
- Combines DSE state with the LOLDrivers list and PCR-attested driver hashes.
- Drivers signed by revoked certs blocked even if Microsoft hasn't pushed the revocation yet.

### Confidential-VM workloads
- For server tenants running on AMD SEV-SNP or Intel TDX, Artemis verifies the attestation report on each agent boot.

## Limitations

- Some legacy software does not ship CFI. Hard-blocking would break workflows; default is *flag* with an upgrade-path recommendation in the report.
- Apple Silicon's attestation surface for third parties is limited. We use what the OS exposes (Secure Enclave-backed device identity, system integrity status).
- Remote attestation in mixed-cloud is operationally fragile; the control plane uses a verifier service abstraction (so vendor changes are absorbed).

## Coverage

- ATT&CK: T1542 (Pre-OS Boot), T1014 (Rootkit), T1068 (Privilege Escalation Exploit).
- Reduces blast radius of T3 / T4 adversaries who would otherwise persist below the OS.
