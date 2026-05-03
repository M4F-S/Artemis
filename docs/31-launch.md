# 31 — Launch

This is the single page the project owner opens to begin Phase 1. Everything else is reference.

## Pre-flight

Before pasting any session prompt, confirm:

- [ ] Kickoff checklist (`docs/21-kickoff-checklist.md`) green.
- [ ] You have at least one tech-lead candidate (R1 in `docs/18-team-and-headcount.md`) lined up — Claude Code can play that role for the bootstrap PR if no human is yet onboarded.
- [ ] You have a Linux machine (or Linux VM / devcontainer) available for testing.
- [ ] Branch protection on `main` is configured (1 review minimum, CI required).
- [ ] You have ~2 hours to supervise the first session through the bootstrap PR.

## The launch sequence

### Step 1 — Create the bootstrap branch

```bash
cd ~/Artemis
git checkout -b tl/bootstrap-P1-T00-T01-T02-T03
git push -u origin tl/bootstrap-P1-T00-T01-T02-T03
```

### Step 2 — Open a Claude Code session in the repo and paste the WS-A prompt

The prompt is in `docs/session-prompts/ws-a-tech-lead.md`. Copy its full contents and paste into the new session. The session will:

1. Read the docs in the prescribed order.
2. Confirm understanding before writing code.
3. Produce the bootstrap PR per `docs/24-first-pr.md`.

Expected: ~2–4 hours of supervised session time. The session may pause to ask questions; answer them; resume.

### Step 3 — Review and merge the bootstrap PR

When the session signals "ready to merge":
- Review the diff yourself.
- Verify CI green.
- Ensure CODEOWNERS placeholders are updated to real handles (your handle plus the tech-lead handle, if different).
- Merge. Tag baseline: `git tag -a v0.0.0-bootstrap -m "Phase 1 bootstrap"`.

### Step 4 — Open three parallel sessions

Once the bootstrap PR is on `main`, open three new Claude Code sessions in parallel. Create one branch per session before pasting:

```bash
git checkout main && git pull
git checkout -b sensor/lsm-bpf-skel-P1-T11
git push -u origin sensor/lsm-bpf-skel-P1-T11
# (and similar for cp/ingest-skel-P1-T60 and det/rule-pack-v0-seed-P1-T22)
```

Then paste:
- Session 1 (sensor): `docs/session-prompts/ws-b-sensor-linux.md`
- Session 2 (control plane): `docs/session-prompts/ws-d-control-plane.md`
- Session 3 (detection): `docs/session-prompts/ws-f-detection.md`

### Step 5 — Coordinator playbook (your daily routine)

Read `docs/session-prompts/coordinator-playbook.md`. Use it as your daily playbook to:

- Scan handoff log; merge ready PRs.
- Decide which sessions continue, switch, or pause.
- Open new sessions per dependency graph (ws-c, ws-e, ws-g, ws-h).

### Step 6 — Phase-1 exit gate

When the team believes Phase 1 is done:

1. Walk through `docs/20-definition-of-done.md` Phase-1 checklist together.
2. Sign off only when every item is green.
3. Tag: `git tag -a v0.1.0-phase1 -m "Phase 1: Linux MVP"`.
4. Announce to your design partner.

## Status snapshot

- **18 ADRs** locked, including the 5 new ones from the senior audit (federation security, signing keys, update channel, hard-rules enforcement, PMF gate).
- **22 capability pillars** spec'd.
- **8 workstream prompts** + 1 coordinator playbook.
- **8 sample artefacts** (proto, OpenAPI, YAML, SQL, TOML, MD).
- **97 docs and samples** total.
- **Two-party update + threshold signing + transparency log** scaffolds in the bootstrap PR scope.
- **PMF gate** at end of Phase 4; pause-and-replan if it fails.

## What you cannot start without

- Legal review of ADR-0009 / ADR-0012 / ADR-0013 returns. Phase 1 ships P14 disabled, so you can begin Phase 1 without it; **but** you cannot ship the first design-partner-paid release until counsel signs off.
- A real design partner (criteria in `docs/13-design-partner-program.md`). The 42 Berlin track runs in parallel.

## When something goes wrong

- A session produces bad code → pause it, review, redirect or close branch. Do not merge tired work.
- CI broken on `main` → halt all merges; whoever last merged owns the fix; revert in 30 min if not resolved.
- ADR change in flight → pause sessions touching the affected paths until merged.
- You're tired → stop. Coordinator fatigue causes the worst outcomes.

## When to come back to docs

- Customer wants to know what we collect → `docs/06-control-plane.md` privacy section + `docs/04-detection-pillars/p6-privacy.md`.
- Lawyer wants to review legal posture → ADR-0009 + ADR-0012 + ADR-0013 + `docs/27-internal-incident-response.md`.
- Design partner asks "why should we trust you?" → `docs/29-senior-audit.md` is the honest framing.
- New hire needs to ramp → `docs/11-onboarding.md`.

That's it. Go.
