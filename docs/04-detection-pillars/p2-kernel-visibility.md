# P2 — Unified Kernel Visibility

**Gap closed:** Tier 1 #1 — eBPF-abuse blind spot on Linux. Plus parity coverage on Windows (ETW + minifilter) and macOS (Endpoint Security).

## Linux: eBPF-abuse detection

The visibility gap, summarised:
- Linux AVs do not see in-kernel eBPF activity.
- `auditd` and `syslog` do not log eBPF program loads.
- Tools like Tetragon / Falco see `bpf()` syscalls but rarely correlate them with the loader's identity, integrity, and intent.

Artemis approach:

1. **LSM hook on `bpf`** — capture every `BPF_PROG_LOAD`, `BPF_MAP_CREATE`, `BPF_PROG_ATTACH`. Record:
   - Program type (kprobe, tracepoint, XDP, LSM, sched, etc.).
   - Loader binary hash + signer + parent chain.
   - License string of the loaded program (GPL claims tracked).
   - Helper functions referenced (red-flag set: `bpf_probe_write_user`, `bpf_override_return`, `bpf_send_signal`, `bpf_get_current_task` in suspicious chains).
2. **Loader allowlist** — by default, only `/usr/sbin/bpftool`, `/usr/bin/bcc-*`, `/usr/local/bin/cilium-agent`, `/snap/microk8s/...`, etc., are trusted loaders. Anything else loading eBPF → MEDIUM alert.
3. **Out-of-allowlist + red-flag-helper** → HIGH alert + auto-detach if policy = enforcing.
4. **eBPF program inventory** — periodic poll of `/sys/fs/bpf/` and `bpftool prog list` to find pinned programs whose load we did not observe (catches pre-existing rootkits like BPFDoor on initial agent install).
5. **Map content sampling** — for known-malicious patterns (e.g. process-hiding maps), periodically sample.

## Windows: parity coverage

- ETW providers + minifilter give us the equivalent depth.
- BYOVD (bring-your-own-vulnerable-driver) detection — flag driver loads not on the WHQL + tenant allowlist; check against LOLDrivers.io list.
- DSE (Driver Signature Enforcement) policy posture reported.
- Kernel callback hooks (PsSetCreateProcessNotifyRoutineEx) used for process events.

## macOS: parity coverage

- Endpoint Security covers exec/fork/open/mmap.
- KEXT loads (rare on Apple Silicon) flagged.
- DriverKit driver loads recorded.
- SIP (System Integrity Protection) status reported.
- Gatekeeper / XProtect verdicts captured.

## Cross-OS: rootkit / ring-0 indicators

- Hidden process detection: enumerate via two paths (e.g., `/proc` walk vs. `getdents` LSM trace on Linux; ETW vs. NtQuerySystemInformation on Windows). Discrepancy → alert.
- Hidden network connections: `ss`/`netstat` userland vs. eBPF/WFP socket inventory.
- Tampered syscall table / IAT / IDT (Windows) reported as critical.

## Performance

- Linux eBPF program budget: < 5% of one CPU under stress, measured with `stress-ng` + 1k procs/s exec rate.
- Windows ETW session: real-time mode with backpressure-aware consumer; drops reported as a self-health alert.
- macOS ES client: subscriptions kept tight; mute by-process-team-ID for known-good vendors to reduce noise.

## Coverage

- ATT&CK: T1014 (Rootkit), T1547 (Boot/Logon Autostart), T1543 (Create or Modify System Process), T1068 (Privilege Escalation Exploit), T1620 (Reflective Code Loading).
