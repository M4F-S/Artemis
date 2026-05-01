# ADR-0003 — `aya` for Linux eBPF

## Status
Accepted (Phase 0).

## Context
Linux sensor needs eBPF + LSM hooks. Library options:
- `libbpf` (C) — most mature; FFI required from Rust.
- `libbpf-rs` — Rust bindings on top of libbpf.
- `aya` — pure-Rust eBPF loader and runtime, supports CO-RE.
- BCC — older, runtime-compiled, heavy footprint.

## Decision
Use **`aya`** for Linux eBPF programs and loaders.

## Rationale
- Pure Rust on both sides simplifies the build, packaging, and supply chain (no clang in customer images).
- CO-RE support handles kernel-version drift cleanly.
- Active maintenance and a healthy community.
- Smaller agent binary than libbpf-rs.

## Consequences
- We accept some lag behind cutting-edge libbpf features; not a problem for v1 use cases.
- We need a CI matrix across LTS kernels (5.10, 5.15, 6.1, 6.6, 6.12) to catch CO-RE regressions.
- For LSM hooks, we require kernel ≥ 5.7 with CONFIG_BPF_LSM=y; we degrade gracefully on older kernels.
