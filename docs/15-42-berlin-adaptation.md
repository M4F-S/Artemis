# 15 — 42 Berlin Adaptation

42 Berlin is a strategically valuable design partner. This doc captures what's different about that environment and what Artemis must change to fit.

## What 42 is

42 is a tuition-free, peer-to-peer coding school (originally Paris; Berlin campus opened 2022). Roughly 600–1,000 active students at any time. No teachers in the traditional sense — students learn by working through a curriculum of projects in C, C++, Unix systems, networking, web, AI, etc., reviewed by peers. Campus runs on Apple iMacs (managed) plus students' own laptops on the school network.

## Why 42 is a strong design partner

- They feel modern security pain (BYOD, EU GDPR, large transient population, social engineering via peer-review channels).
- They have no traditional SOC and a very small IT team — the SMB-with-extreme-constraints profile we're already targeting.
- The campus is a self-contained playground: real users, real attacks, real stakes, but no enterprise change-management molasses.
- Their alumni network is a hiring funnel.
- A successful 42-Berlin reference unlocks the whole 42 network (~50 campuses) and an enormous marketing halo.

## What's unusual at 42 (and how Artemis adapts)

### A. Intentionally suspicious code is normal coursework

Students write:
- Buffer-overflow exploits (`Born2BeRoot`, several pwn / CTF-style projects).
- Custom shells (`minishell`, `ft_irc`).
- Network servers and clients on raw sockets.
- Kernel-adjacent code, custom allocators, syscall wrappers.
- Compilers, debuggers, packet sniffers.

A vanilla EDR would fire constant false positives. **Artemis adaptation:**
- Ship a **42 intent-template pack** (P4) covering the common 42 cursus projects:
  - `42:born2beroot` — allows VM tooling, sudo policy edits.
  - `42:minishell` — allows `fork`/`exec`/`pipe` exploration.
  - `42:ft_irc` — allows raw-socket server binding on chosen ports.
  - `42:webserv` — allows HTTP server binding + arbitrary CGI exec.
  - `42:inception` — allows Docker, custom Dockerfiles.
  - `42:nm`, `42:ft_nm`, `42:ft_otool` — allows ELF/Mach-O parsing, /proc/self/maps reads.
  - `42:cpp` modules — broad memory-write + casts allowed.
  - `42:netpractice`, `42:ft_traceroute`, `42:ft_ping` — allows raw sockets, ICMP.
  - `42:ctf` / `42:pwn` — broad debugging + ptrace + gdb usage allowed; *still alerts on outbound network and credential-store access.*
- Templates live in a community-maintained repo (`artemis-rules-42`) so students themselves can PR new templates.

### B. BYOD is the norm

Students must be able to install Artemis on their own laptop, opt-in, with informed consent — not via central MDM.

**Adaptation:**
- Per-user enrolment (instead of per-tenant device-cert provisioned by an admin).
- Plain-language consent screen at install.
- One-click uninstall that removes everything, including telemetry.
- Two profiles: `school` (active when on the 42 network) and `personal` (lighter, opt-out of certain sensors when off-campus).

### C. EU privacy is non-negotiable

GDPR + German federal data-protection law + a young (often <25) population.

**Adaptation:**
- EU-only data residency for the 42 tenant (ADR-0006 already supports per-tenant region pinning).
- Differential privacy (P6) on by default.
- Documented DPIA (Data Protection Impact Assessment) template for 42 to file.
- Right-to-erasure honoured per individual student account, not tenant-wide.
- Consent flow shows what is collected, in plain German + English.

### D. Heavy macOS + Linux, sparse Windows

Aligns with our Phase 1 priorities (lucky).

### E. Peer-review code submission

Risk: malicious student PRs / submitted code that runs on a peer's machine during grading.

**Adaptation:**
- P11 (supply-chain runtime guard) extended to local code: the sensor knows when a process is executing inside the standard 42 review/grading tree, sandboxes its first run, and surfaces high-risk behaviours (network egress, secret reads, fork bombs).
- A "review mode" intent that auto-engages when the user runs `42-grade` (or equivalent).

### F. No real SOC

The campus IT team is a handful of people. They cannot triage 200 alerts a day.

**Adaptation:**
- LLM copilot (P5) plain-language alerts are the primary interface.
- Self-healing (P15) covers the obvious cases (malware quarantine, session revoke).
- BAS (P17) keeps coverage honest without requiring a hunter on staff.
- A small "campus dashboard" view ranks tenants/users/projects by current risk.

### F.bis Tiered Active Defense for the school network

P14 ships a 6-tier severity ladder ([ADR-0013](09-adr/0013-active-defense-tiers.md)). For 42 specifically, the configuration is:

```
[Confirmed-malicious activity from a 42-network endpoint]
      │
      ▼
[Tier 3 Hard contain]   — kill process; isolate host locally
      │ + tenant policy = "neutralise on school network"
      ▼
[Tier 4 Network neutralisation]
      • RADIUS deauth + 802.1X cert revoke for the device
      • Wireless AP MAC deny (UniFi connector if applicable)
      • Switch port shutdown if on wired
      • Result: device cannot reach anything on the 42 network
      │ + scope policy = "report to admin"
      ▼
[Tier 5 Escalate to authority]
      • Auto-generated incident report (provenance + LLM narrative + citations)
      • Delivered via 42's chosen channel (email DL + ticketing system)
      • Includes: pseudonymised user identifier (admin can re-link),
        evidence bundle, recommended next steps
      • Tagged: campus iMac vs. student-BYOD (different remediation playbooks)
```

The default 42 configuration:
- Tier 1–3 ON, default thresholds.
- **Tier 4 ON** for scope `42-network`. NAC connector v0: FreeRADIUS (per [ADR-0013](09-adr/0013-active-defense-tiers.md)). UniFi connector added in Phase 7 if 42 uses UniFi APs.
- **Tier 5 ON** for scope `42-network`. Authority chain:
  - Routine cases → 42 IT lead (email + ticketing).
  - Severe student-BYOD cases → 42 IT lead + dean of students.
- Pre-authorisation: signed by 42 admin during onboarding; covered in DPIA.
- 60-second cancel window present before Tier 4/5 actions execute (unless `tier4-no-delay` is explicitly set, which is NOT recommended for 42).

Within ADR-0009 boundaries: nothing leaves 42's perimeter. Tier 4 controls 42's own network gear; Tier 5 sends a notification through 42's own admin channel. CFAA / UK CMA / EU NIS2 are not implicated.

### G. CTF / pwn culture — "evade Artemis" will become a sport

Treat this as a feature, not a bug.

**Adaptation:**
- Public bug bounty for 42 students (Artemis-funded modest rewards: stickers, swag, conference trips for serious findings).
- Annual "Break Artemis" CTF event during 42 hack-day weeks.
- Findings feed P16 self-evolving rules. A student who finds an evasion gets co-credit on the rule that closes it.

## Pricing for 42

- Free for the campus during design-partner phase (Phase 1–4).
- Free for individual students always (alumni eligibility too — building reputation in the community).
- A reasonable per-school commercial rate post-GA if 42 wants centrally-managed tenants.

## What 42 gets

- A free, modern, AI-native security platform.
- Direct line to the founding team for product input.
- Co-branded case study (with their consent).
- Pipeline for Artemis to hire from the 42 graduate pool.
- Interesting problems for students to actually work on.

## What 42 commits

- Permission to deploy on willing-student endpoints + on the school's Linux servers.
- Bi-weekly review with their IT lead.
- Honest feedback.
- Permission to anonymise / publish lessons learned (with redactions of their choice).
- Help running the annual "Break Artemis" CTF.

## Outreach & next steps

See `docs/16-42-berlin-outreach.md` for the pitch and contact plan.
