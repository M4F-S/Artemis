# P20 — Cloud Workload Protection (CWPP)

Cloud workloads live outside the typical EDR's view. P20 adds runtime + posture + image protection across the customer's cloud footprint.

## Scope

- Containers (Docker, containerd, CRI-O).
- Kubernetes clusters (managed and self-hosted).
- Serverless (AWS Lambda, GCP Cloud Functions, Azure Functions).
- Cloud-native compute (EC2, GCE, Azure VM) — the existing Linux/Windows sensor covers these; P20 adds cloud-context.
- Cloud configuration posture (CSPM-lite via APIs).

## Capabilities

### C1 Container runtime protection

- Linux sensor + container-aware annotation: every event tagged with container ID, image hash, namespace, pod, K8s labels.
- Per-image baseline of expected syscall set (Falco-style); deviations alerted.
- Image-signing verification on container start (Sigstore / Notary v2).

### C2 Kubernetes admission control

- ValidatingWebhookConfiguration: refuses pods that violate tenant policy (image not signed, runs as root, hostNetwork=true without exception, etc.).
- MutatingWebhookConfiguration: injects the Artemis sensor sidecar into protected workloads.

### C3 Image scanning (build + registry)

- Pre-deploy: scan images in registry (Trivy / Grype integration, or native scanner).
- Vulnerability + secret-detection + malware in image layers.
- Block deploy on critical findings (configurable).

### C4 Serverless audit

- AWS Lambda: ingest CloudTrail + Lambda-Insights; flag privilege escalations, unusual invokers, suspicious env-var patterns (embedded creds, LLM API keys).
- GCP / Azure equivalents.

### C5 Cloud configuration posture

- Periodic API sweep of IAM, S3 / GCS / Blob ACLs, security groups, KMS, secrets-manager.
- Drift from policy = MEDIUM alert.
- Built-in benchmarks: CIS, NIST 800-53 mappings.

### C6 Cloud audit log ingestion

- CloudTrail (AWS), Cloud Audit Logs (GCP), Activity Log (Azure) into the central event pipeline.
- Joins with endpoint and identity events at the provenance graph (P7) — full-stack causal chains.

## Adversarial considerations

- Container escape attempts: the underlying kernel sensor (P2) catches these regardless of the container annotation; P20 just ensures attribution to the right workload.
- Misconfigured admission webhook = control-plane DoS: webhook fail-mode is `Ignore` for non-critical policies, `Fail` only for explicit deny-list items.

## Coverage

- ATT&CK: T1611 (Escape to Host), T1610 (Deploy Container), T1613 (Container and Resource Discovery), T1525 (Implant Internal Image), T1496 (Resource Hijacking), TA0006 cloud-side.
