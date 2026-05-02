# 10 — Glossary

| Term | Meaning |
|---|---|
| **ADR** | Architecture Decision Record — a short doc capturing one significant decision and its rationale. |
| **AMSI** | Antimalware Scan Interface — Windows API that lets AV inspect deobfuscated script content (PowerShell, .NET, VBA, JScript). |
| **Apollo** | Artemis's offensive-testing companion sister project (`m4f-s/apollo`); Kali-based; lab-only per [ADR-0012](09-adr/0012-apollo-scope.md); future commercial SKU gated per jurisdiction. |
| **ATLAS** | MITRE ATLAS — the AI-systems analogue of ATT&CK. P21 maps coverage to it. |
| **ATT&CK** | MITRE's adversary tactics & techniques framework. |
| **AYA** | Pure-Rust eBPF loader/runtime. https://aya-rs.dev |
| **BAS** | Breach and Attack Simulation. P17. |
| **BPF / eBPF** | Berkeley Packet Filter / Extended BPF — in-kernel programmable data plane on Linux. |
| **BYOK** | Bring Your Own Key — customer holds the encryption key for their data at rest. |
| **CA/B Forum** | CA/Browser Forum — sets PKI policy that influences PQ migration. |
| **Caldera** | MITRE's open-source adversary emulation framework; Apollo borrows its scenario YAML format. |
| **CET** | Intel Control-flow Enforcement Technology (shadow stack + IBT). |
| **CFAA** | Computer Fraud and Abuse Act (US, 18 U.S.C. § 1030). |
| **CFI** | Control-Flow Integrity. |
| **CKKS** | Cheon-Kim-Kim-Song homomorphic encryption scheme; supports approximate arithmetic on encrypted real numbers. |
| **CMA** | Computer Misuse Act (UK, 1990). |
| **CO-RE** | Compile Once, Run Everywhere — eBPF feature for kernel-version portability. |
| **CWPP** | Cloud Workload Protection Platform. P20. |
| **DFIR** | Digital Forensics and Incident Response. P22. |
| **DP** | Differential Privacy. |
| **DPIA** | Data Protection Impact Assessment (GDPR Art. 35). 42 Berlin requires one. |
| **DRSM** | De-Randomized Smoothing on Malware — certified-robust ML for malware classification. |
| **DRTM** | Dynamic Root of Trust for Measurement — Intel TXT, AMD SKINIT. |
| **DSE** | Driver Signature Enforcement (Windows). |
| **EAP-TLS** | Extensible Authentication Protocol with TLS — common 802.1X auth method; relevant to NAC connector. |
| **EDR** | Endpoint Detection and Response. |
| **EU Dual-Use Regulation 2021/821** | EU rules on export of dual-use items (incl. cyber-surveillance / intrusion software); relevant to Apollo. |
| **ES** | Endpoint Security framework (macOS). |
| **ETW** | Event Tracing for Windows — kernel-level telemetry primitive. |
| **HE** | Homomorphic Encryption. |
| **IBT** | Indirect Branch Tracking (part of Intel CET). |
| **ITDR** | Identity Threat Detection and Response. P10. |
| **JA4 / JA4S / JA4H** | TLS / TLS-server / HTTP fingerprinting suite (FoxIO). |
| **KEXT** | Kernel Extension (macOS, mostly deprecated on Apple Silicon). |
| **LOLBin** | Living-Off-the-Land Binary — pre-installed trusted program abused by attackers (mshta, certutil, etc.). |
| **LSM** | Linux Security Module — hookable kernel framework Artemis uses via eBPF-LSM. |
| **MAPE-K** | Monitor / Analyze / Plan / Execute / Knowledge — IBM's autonomic-computing reference loop. Artemis structure described in [ADR-0010](09-adr/0010-autonomic-safety.md). |
| **MDR** | Managed Detection & Response — Artemis on-call as the customer's SOC. |
| **MITRE ATLAS** | See ATLAS. |
| **ML-DSA** | Module-Lattice-Based Digital Signature Algorithm (FIPS 204). One of two PQ signing algos Artemis ships. |
| **MV3** | Manifest V3 — Chrome browser-extension manifest version. |
| **NAC** | Network Access Control. P14 capability G; the layer that performs Tier-4 network neutralisation via the `NacConnector` trait ([ADR-0013](09-adr/0013-active-defense-tiers.md)). |
| **NacConnector** | The Rust trait that vendor-specific NAC integrations implement (FreeRADIUS, pfSense, UniFi, Cisco ISE, Aruba ClearPass, Meraki). |
| **NGAV** | Next-Generation Antivirus. |
| **NDR** | Network Detection and Response. P19. |
| **NIS2** | EU directive on the security of network and information systems (2022/2555). |
| **OCSF** | Open Cybersecurity Schema Framework — alert taxonomy. |
| **OFHE / OpenFHE** | Open-source homomorphic-encryption library. |
| **OTLP** | OpenTelemetry Protocol. |
| **PAC** | Pointer Authentication Code (ARM). |
| **PIDS** | Provenance-based Intrusion Detection System. |
| **PCR** | Platform Configuration Register (TPM). |
| **PPL** | Protected Process Light (Windows). |
| **PQ** | Post-Quantum (cryptography). |
| **RADIUS** | Remote Authentication Dial-In User Service — AAA protocol used by 802.1X. FreeRADIUS is the Phase-5 NAC v0 reference. |
| **RBAC** | Role-Based Access Control. |
| **RL** | Reinforcement Learning. P16 uses safety-bounded RL to rank response playbooks. |
| **RuleGenie / RulePilot / LLMCloudHunter** | Recent academic pipelines for LLM-driven detection-rule synthesis from incidents / threat-intel. P16. |
| **SBOM** | Software Bill of Materials. |
| **SEV-SNP** | AMD Secure Encrypted Virtualization — Secure Nested Paging. |
| **SLH-DSA** | Stateless Hash-based Digital Signature Algorithm (SPHINCS+ — FIPS 205). |
| **SLSA** | Supply-chain Levels for Software Artefacts — provenance attestations on built artefacts. |
| **T0–T6** | Adversary tiers in the threat model. T6 (autonomic-loop abuser) is new in v1 of Artemis. |
| **TCC** | Transparency, Consent and Control (macOS). |
| **TDX** | Intel Trust Domain Extensions. |
| **TEE** | Trusted Execution Environment. |
| **Tier 0–5** | Active Defense severity ladder per [ADR-0013](09-adr/0013-active-defense-tiers.md). 0=observe; 5=escalate to authority. |
| **TPM** | Trusted Platform Module. |
| **Wassenaar Arrangement** | Multilateral export-control regime; "intrusion software" entries relevant to Apollo. |
| **WFP** | Windows Filtering Platform. |
| **WS-A … WS-H** | Phase-1 parallel implementation workstreams (per [`docs/23-parallel-sessions.md`](23-parallel-sessions.md)). |
| **XDR** | Extended Detection and Response. |
| **802.1X** | Port-based network access control standard; underpins Tier-4 NAC neutralisation. |

