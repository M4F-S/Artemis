# 03 — Sensor Design

One sensor binary per OS, sharing a Rust core. Each sensor adapts the OS-specific telemetry primitives into a common event schema (see `05-data-model.md`).

## Linux sensor

**Substrate:** eBPF via `aya` (Rust). CO-RE for kernel-version portability.

**Hooks:**
- LSM hooks: `bpf` (catch eBPF program loads — P2), `bprm_check_security` (exec), `file_open`, `inode_permission`, `socket_connect`, `ptrace_access_check`, `task_kill`.
- kprobes/tracepoints: `sched_process_exec`, `sched_process_exit`, `tcp_connect`, `do_unlinkat`.
- uprobes: libssl `SSL_write` (TLS metadata), libc `execve` family.

**Why eBPF + LSM:** lower overhead than auditd, proper context for `bpf()` syscalls, and gives us the eBPF-abuse visibility (P2) that no mainstream Linux AV provides.

**Userland:** Rust daemon (`artemis-agentd`), systemd unit, runs as root with `CAP_BPF + CAP_PERFMON + CAP_SYS_PTRACE` (no full root after init).

## Windows sensor

**Substrate:**
- ETW providers (Microsoft-Windows-Threat-Intelligence, Kernel-Process, Kernel-Network, DNS-Client, RPC).
- Filesystem **minifilter driver** for file canary tripwires (P3) and on-write scan hooks.
- AMSI provider for PowerShell / VBA / JScript / .NET in-memory content (P1).
- WFP callout for network filtering and per-process socket events.
- Defender coexistence: register as a 3rd-party AV via WSC; honour Defender exclusions to avoid duplicate work; keep MAPS off in privacy mode.

**Self-protection:** PPL (Protected Process Light) for the agent service; tamper protection via WDAC policy.

**Why:** ETW is the Windows-native low-overhead telemetry; minifilter is required for file-event tripwires; AMSI is the only correct way to see deobfuscated script content.

## macOS sensor

**Substrate:**
- Endpoint Security framework (`es_client_t`) — exec, fork, open, mmap, signal, mount.
- Network Extension (Content Filter Provider) — per-flow metadata.
- Sysdiagnose hooks for kernel telemetry where ES gaps exist.
- TCC (Transparency, Consent, Control) awareness — observe TCC prompt outcomes for sensitive APIs.

**Distribution:** notarised, with Endpoint Security entitlement (`com.apple.developer.endpoint-security.client`). Requires Apple to approve the entitlement.

**Limitation:** Apple Silicon's hardened kernel = no kernel extensions. Everything via user-space ES. Performance is generally good, but some telemetry (e.g., kernel-mode rootkits) is harder to see than on Linux/Windows.

## Browser sensor

**Substrate:** Manifest V3 WebExtension (Chrome + Edge first, Firefox later). Native messaging to the local daemon.

**Capabilities:**
- DOM observer to catch hidden / off-screen / Base64-decoded prompt-injection patterns (P1).
- Tool-call interceptor for sibling AI extensions (audit before-and-after content for sensitive verbs targeting credential / file / shell APIs).
- Cookie / IndexedDB monitor — flag access from unexpected origins.
- Phishing classifier (local ONNX) — runs on landed pages, not browse history.

**Constraints:** MV3 service-worker lifecycle; we cannot rely on long-lived background pages. Use `chrome.alarms` + native messaging for state.

## Shared core (`artemis-core`)

Reused across all four sensors:

- **Event schema** (OTLP-shaped, see `05-data-model.md`).
- **Rule engine** — Falco-style YAML compiled to a Wasm sandbox at load time (so detection authors can ship rules without recompiling the daemon).
- **Local ML scorer** — ONNX Runtime; models loaded from signed bundles (P12).
- **Provenance builder** — rolling 1 h in-memory graph; flushed on alert.
- **DP egress filter** — randomised response on enumerated event categories.
- **mTLS client** — device cert, certificate transparency-pinned to Artemis CA.

## Sensor-to-daemon IPC

- Linux/macOS: shared-memory ring buffer (perf-event-array on Linux, Mach IPC on macOS).
- Windows: ETW real-time consumer + filter driver port.
- Browser: native messaging over stdio.

## Performance budget

- < 2% sustained CPU on a 4-core 8-GB machine.
- < 150 MB RAM (sensor + daemon).
- Event drop rate < 0.1% under stress (kernel build, video render, npm install).

Measured continuously in CI against a fixed workload corpus.
