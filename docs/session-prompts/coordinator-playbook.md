# Session prompt — Coordinator (the human owner)

This is the prompt you (the project owner) keep in front of you while running parallel Claude Code sessions. It is not pasted into a session; it is your daily playbook.

---

## Daily / per-block coordinator playbook

### Start of working block
1. Open `docs/14-session-handoff.md`. Read the most recent entries from each active workstream. Note any "what I need from other streams" asks.
2. Open the GitHub PR queue. Merge any with green CI + approving reviews + landed dependencies.
3. For each active workstream, decide: continue this session, switch ticket, pause.
4. For new sessions starting today, pick the right session prompt from `docs/session-prompts/`, create the working branch, paste the prompt.

### During the block
- You are the coordination point. Sessions don't talk to each other directly; everything flows through you and the handoff log.
- If a session needs something from another stream that hasn't shipped, redirect that session to an independent ticket rather than letting it wait > 4 hours.
- Watch for cross-stream stomping (two sessions touching the same file). The file-ownership rules in `docs/23-parallel-sessions.md` should make this rare; when it happens, sequence rather than parallelise.

### End of working block
1. Make sure each active session has appended its handoff entry.
2. Append your own coordinator entry: what merged, what's blocked, what tomorrow's priority is.
3. Push everything; don't leave half-pushed branches.

## Choosing the next session to start

Run this checklist to decide what session to start next:

1. Is `tl/bootstrap-...` merged? If no, run only WS-A.
2. If yes, pick from this priority order:
   - WS-B sensor (always; sensor work is the long pole).
   - WS-D control plane (always; ingest is the next long pole).
   - WS-F detection (any time after WS-A; rules can be authored independently).
   - WS-C daemon (after WS-B has emitted at least one event type).
   - WS-E console (after WS-D has at least a stub alert endpoint).
   - WS-G LLM heuristic (after WS-C has the event bus).
   - WS-H hardening (after enough exists to harden).

You typically have 2–4 active sessions at once. Anything more than 4 is hard to coordinate even with the protocol.

## When to pause everything

- A privileged-path PR is in review that affects multiple workstreams.
- A safety-contract change (ADR-0010 / 0011 / 0013) is being drafted.
- A schema change is in flight (event schema, rule schema, alert schema).
- Legal review on ADR-0009 / 0012 returns with material changes.
- You haven't slept; tired coordination is worse than no coordination.

## Recovery protocols

- **Session producing bad code**: pause it; review what it produced; either redirect with a corrected prompt or close the branch.
- **Two sessions touched the same file**: rebase the second on top of the first; resolve conflicts as the human; do not let either session merge in a conflict state.
- **CI broken on `main`**: stop merges immediately; whoever last merged owns the fix; revert if not fixed within 30 minutes.
- **A workstream falls 2+ tickets behind schedule**: re-balance; spin up a second session in that stream or pull priority forward.

## Quality gate

Before merging any PR ask:
- Did the relevant CODEOWNERS approve?
- Did CI pass on every required check?
- Did the session record its handoff entry?
- Does the change respect the hard rules in `CLAUDE.md`?
- For privileged paths: did a second human reviewer approve?

If any answer is no, do not merge.

## Phase-1 exit (run this as the final coordinator action)

Walk through `docs/20-definition-of-done.md` Phase-1 checklist with the team. Sign off only if every item is green. Then:

1. Tag the release: `v0.1.0-phase1`.
2. Append a "Phase 1 closed" entry to `docs/14-session-handoff.md`.
3. Open the Phase-2 backlog tickets.
4. Announce to design partner(s).
