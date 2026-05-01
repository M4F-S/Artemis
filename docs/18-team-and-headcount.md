# 18 — Team & Headcount

Concrete answer to "how many people do I need from the school?" plus per-role profiles so colleagues can self-select.

## Headline numbers

| Phase | Calendar | Comfortable team | Minimum team | Roles added |
|---|---|---|---|---|
| 1 — Linux MVP | 10–14 wk | 4–5 colleagues + you | 2 colleagues + you | sensor, backend, console, rules |
| 2 — Windows + copilot | +8 wk | 5–6 + you | 3 + you | + Windows specialist |
| 3 — macOS + browser + privacy | +8 wk | 6–7 + you | 4 + you | + macOS / browser specialist |
| 4 — Hardening + robust ML | +8 wk | 7–8 + you | 5 + you | + ML engineer; detection author full-time |
| 5 — Active Defense + autonomic foundation | +8 wk | 8–9 + you | 6 + you | + control-plane safety specialist |
| 6 — Autonomic loop GA + Apollo Phase 1 | +10 wk | 10–11 + you | 7 + you | + Apollo red-team engineer; ML-RL specialist |
| 7 — Domain expansion (P18–P22) | +16 wk | 13–15 + you (5 parallel tracks) | 8 + you (sequenced) | + 5 domain leads |
| 8 — 42 Berlin pilot (parallel from Phase 1) | ongoing | +1 (42 liaison; can be one of the existing detection authors) | 0 (rolled into others) | n/a |

**Year 1 (Phases 1–4):** ~9 months, **7–8 colleagues** at peak.
**Year 2 (Phases 5–7):** **13–15 colleagues** at peak; some can rotate as previous-phase work matures.

## Recommended hiring sequence

Order matters: each later hire is more productive once the earlier one is in place.

1. **Co-founding tech lead** (Rust, eBPF, end-to-end thinking). Even if from school, this person should be among the strongest. Sets coding norms, owns ADRs, mentors juniors.
2. **Sensor / backend colleague #1** (Rust, comfortable with kernel-userland boundary).
3. **Sensor / backend colleague #2** (paired with #1; junior is fine).
4. **Console colleague** (TypeScript / Next.js).
5. **Detection-author / red-team colleague** (CTF-savvy student is ideal). Quarter-time initially, full-time by Phase 4.
6. *(Phase 2)* Windows-platform specialist.
7. *(Phase 3)* macOS / browser specialist.
8. *(Phase 4)* ML engineer.
9. *(Phase 6)* Apollo red-team engineer.
10. *(Phase 7)* Five domain leads (email, NDR, CWPP, LLM-FW, hunting).

## Role profiles (use these as job descriptions)

### R1 — Tech lead

- Strong Rust; comfortable with `unsafe` boundaries and lifetimes; comfortable reading C kernel code.
- Has shipped at least one substantial system before (open-source contribution counts).
- Owns the workspace skeleton, the build, the CI, and code-review norms.
- Spends time on people, not just code. Pairs with juniors regularly.

### R2 — Sensor engineer

- Rust + Linux fundamentals. eBPF curiosity essential; prior eBPF experience a bonus, not required.
- Comfortable with `aya`, `bpftool`, `bcc` examples, kernel docs.
- Reads `man 2 bpf` for fun.
- Will own one OS sensor end-to-end over a phase.

### R3 — Backend engineer

- Async Rust; tonic/gRPC; Postgres; one of (ClickHouse, Kafka, Redpanda).
- Multi-tenant thinking — has at least heard the term "row-level security" and understands why it matters.
- Will own ingest + storage + part of detection engine.

### R4 — Console / UI engineer

- TypeScript + React (Next.js).
- Cares about UX for non-experts (the SMB owner is the user).
- Will own the alert UI, the dashboard, and the operator workflow.

### R5 — Detection author / red-team

- Comfortable with ATT&CK, Falco-style YAML rules, real-world incident reports.
- Curiosity about evasion. Has done at least a couple of CTFs.
- Will own the rule pack, BAS scenarios, and Apollo content.

### R6 — Windows platform specialist

- Windows internals: ETW, minifilters, AMSI, WFP, services.
- C / C++ for kernel-side; Rust for user-mode glue.
- Has some Windows kernel debugging experience or willing to learn quickly.

### R7 — macOS / browser specialist

- Endpoint Security framework, Network Extension, codesigning + notarisation pipeline.
- Browser MV3 extension development.
- Comfortable working with Apple's Developer Program friction.

### R8 — ML engineer

- PyTorch or JAX; ONNX export; production ML.
- Has read recent adversarial-robustness papers (DRSM, smoothed classifiers).
- Will own P8 + P16 model lifecycle, federation aggregation, RL response policy (with safety constraints).

### R9 — Apollo red-team engineer

- Offensive-security background: Caldera / Atomic Red Team / Sliver / Metasploit.
- Disciplined about scope and authorisation (this is non-negotiable).
- Will own the Apollo repo and the BAS technique pipeline.

### R10 — Domain leads (Phase 7)

- One per: email, NDR, CWPP, LLM-firewall, hunting+DFIR. Each owns a track end-to-end. Strong generalists with the ability to dive into the domain.

## How to recruit at 42 Berlin (or any similar school)

1. Post in the campus Discord / Slack a 1-page brief describing **one phase-1 ticket** (e.g. P1-T11: implement an LSM hook that captures `bpf` syscalls). Concrete is better than abstract.
2. First contributor coffee — 30 minutes, no commitment. Ask what they want to work on; show the spec.
3. Trial PR — let them pick a small ticket. Pair-review the PR, learn how they think.
4. Decide — does this person make the team better? If yes, formalise (paid role / unpaid contributor + CLA / equity, depending on your decision in ADR-0008).

## Compensation patterns to consider (ADR-0008 still pending)

- **Paid hourly** — simplest; competitive with internship rates locally.
- **Equity for early hires** — possible if you incorporate; lock cliff/vest.
- **Unpaid open-source contributor** — only ethical if the project is OSS; if Artemis core stays closed-source, paying contributors is morally required.
- **Hybrid** — small stipend + equity; common for student-heavy teams.

This decision interacts with ADR-0008 (licensing). Owner signs off on both at the same time.

## Risks specific to a student-heavy team

- **Velocity is bursty.** Exam weeks happen. Plan for it; don't expect linear output.
- **Knowledge transfer.** A graduating student leaving with the only memory of a subsystem is a real risk. Counter with **paired ownership** on every crate — at least two people understand each major piece.
- **Variance in code quality.** Compensate with strict CI gates and pair review, not by adding process meetings.
- **Legal naivety.** Students may agree to things they shouldn't. CLA + tech lead reviews any contributor commitment.

## What "from school" means in practice

You don't need to recruit only from 42 Berlin. The team can be a mix:
- 42 Berlin students for the alumni-network and design-partner alignment.
- Other German / EU CS students for diversity.
- Any other community contributor who shows up and ships.

The headcount numbers above are the **total** team — it doesn't matter where individuals come from as long as the role is filled.
