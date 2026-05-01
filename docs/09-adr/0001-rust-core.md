# ADR-0001 — Rust as the core sensor + daemon language

## Status
Accepted (Phase 0).

## Context
The endpoint daemon and per-OS sensors need: (1) memory safety in privileged code, (2) low overhead, (3) good FFI to OS APIs (syscalls, ETW, ES, eBPF), (4) a hiring pool that exists.

Candidate languages: C, C++, Rust, Go, Zig.

## Decision
Use **Rust** for `artemis-core`, all sensor adapters, and the userland daemon.

## Rationale
- Memory safety eliminates a class of exploitable bugs in privileged code.
- Mature eBPF tooling (`aya`, `libbpf-rs`).
- Excellent Win32 / macOS bindings (`windows-rs`, `objc2`).
- Zero-cost abstractions and tight binary footprint.
- Strong concurrency story (Tokio) for the daemon's event loop.

## Consequences
- Hiring is harder than Go but the candidate quality bar is high.
- C++ / C linkage still required at the kernel boundary (eBPF C, minifilter C); Rust hosts these with minimal glue.
- Some macOS Endpoint Security headers ship as Objective-C; we use `objc2` and accept some unsafe blocks behind reviewed wrappers.
