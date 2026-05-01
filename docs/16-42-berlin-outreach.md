# 16 — 42 Berlin Outreach Plan

A working document. Adapt freely; commit revisions as you iterate.

## Who to approach

- **Primary contact:** the Director / Operations Lead at 42 Berlin. (The named individual changes; check the `42berlin.de` site or LinkedIn before sending.)
- **Secondary contact:** the IT / Sysadmin lead at 42 Berlin.
- **Tertiary:** an active student or alumnus connector (someone who can warm-intro you internally).
- **Across the network:** 42 Paris (Le Wagon HQ) for federation across campuses if the Berlin pilot succeeds.

## Path of least friction

1. Warm intro from a 42 alumnus or staff if you can find one. LinkedIn + the 42 Berlin Discord / public Slack channels are the place to start.
2. Failing that, a personal email from you (the project owner) explaining who you are, what you're building, and what you're proposing. Plain text, short, no marketing language.
3. Bring a working demo before the meeting — even a 30-second screen recording of Artemis catching a simulated incident on a 42-style Linux box is worth more than 10 slides.

## The pitch (one page)

```
Subject: Free security platform for 42 Berlin — design partner offer

Hi [Name],

I'm [your name], building Artemis, a new security platform for orgs
that don't have a dedicated SOC. It's cross-platform (Linux, macOS,
Windows, browser), AI-native, privacy-preserving, and self-healing.

I'd like to offer 42 Berlin a free design-partner deployment.

What you'd get:
- Modern endpoint + identity protection for staff machines and
  willing students' BYOD laptops.
- EU data residency, differential privacy, GDPR-friendly defaults.
- Plain-language alerts so your IT lead doesn't drown.
- Custom support for 42-cursus projects (so we don't generate false
  positives on minishell, ft_irc, pwn challenges, kernel exploration).
- Ransomware self-healing for school servers.
- Direct line to me; your feedback shapes the roadmap.

What I'd ask of you:
- A trial deployment on staff machines + opt-in students (start with
  10–20, scale only if it's working).
- A 60-min review every two weeks.
- Honest feedback.
- Permission to mention 42 in a case study (with your approval, redacted as you wish).

Bonus: an annual "Break Artemis" CTF for students. Modest bug bounties
for evasion findings. Contributions go into the product.

Would you have 30 minutes for a call in the next two weeks? I'm happy
to demo what we have and walk through the architecture.

Thanks,
[your name]
[website / LinkedIn]
```

## Demo plan (for first meeting)

A live (or recorded) walk-through showing:

1. **Day-in-the-life of a 42 Linux box.** Student starts a Docker session, compiles a `minishell`, runs it. Artemis says nothing (correctly). Then a colleague PRs a backdoored `Makefile`. Artemis catches the egress to a suspicious host, narrates the alert in plain English, proposes containment.
2. **Ransomware self-healing.** A simulated cryptor kicks off; Artemis flags the encryption pattern + canary trip + provenance chain; rolls back the host from a 5-minute-old snapshot; reports done in under 60 seconds.
3. **Privacy posture.** Open the dashboard; show the data inventory: what's collected, what's not, what's pseudonymised, where it lives.
4. **Student CTF angle.** Mention the bug-bounty / break-Artemis event idea; show how a student-found evasion turns into a deployed rule the same day via the rule synthesiser (P16).

## What you might be asked / objections to prepare for

- **"GDPR — what exactly do you collect?"** Walk them through P6 + the data-collection checklist below.
- **"Our students do exotic things. False positives will kill us."** Walk through the 42 intent-template pack (P4 + `docs/15-42-berlin-adaptation.md`).
- **"What if Artemis itself is compromised?"** Walk through ADR-0010 + ADR-0011 safety contracts.
- **"What's the cost when this stops being free?"** Roughly $5–8 per managed endpoint per month at GA; free forever for individual students.
- **"We don't want vendor lock-in."** Open formats (OTLP, OCSF), data export at any time, no contractual lock-in during the design-partner phase.

## Data-collection checklist (be ready to recite)

- ✗ Document content
- ✗ Clipboard
- ✗ Keystrokes
- ✗ Browser history
- ✗ Email body
- ✓ Process metadata (name, hash, parent)
- ✓ Network metadata (destination, port, SNI; not payloads)
- ✓ File metadata + hashes (only on-write to sensitive paths or on suspicious patterns)
- ✓ Identity events (logins, OAuth grants — on the customer's identity provider)
- All identifiers pseudonymised at egress; tenant-held re-identification key.

## Likely failure modes for the deal

- 42 doesn't want any third-party agent on student machines, ever. Mitigation: stage 1 = staff machines + servers only; students opt in only if they want to.
- 42 wants EU-only, self-hosted control plane. Mitigation: support a thin "tenant-on-prem" deployment for 42 (small extra effort; great reference architecture).
- The campus IT lead doesn't want the operational responsibility. Mitigation: include managed-detection as part of the free tier — Artemis on-call instead of campus IT.

## After the first meeting

Follow up within 24 hours with a written summary, updated demo / docs, and a clear next step (second meeting, pilot scope, paperwork). Track the deal in `docs/14-session-handoff.md` so future sessions know the state.
