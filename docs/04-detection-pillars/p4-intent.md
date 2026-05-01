# P4 — Intent Sessions

**Gap closed:** Tier 1 #5 — no shipping AV asks "is this consistent with what the user said they were doing?" Behavioural baselines exist but are passive, statistical, and slow to adapt. Intent is **declarative**: the user states intent and Artemis enforces against it.

## Concept

The user (or an admin policy) declares an "intent session":

```
artemis intent start --task "video-edit" --duration 1h
artemis intent start --task "code:repo=github.com/acme/api" --duration 4h
artemis intent start --task "tax-prep" --duration 2h
```

Each task name maps to a **policy template** that allow-lists expected behaviours and flags / blocks deviations:

- `code:repo=...` allows compilers, language toolchains, package managers; expects writes within the repo and `~/.cache`; flags writes to `~/.ssh`, `~/.aws`, `~/Documents`.
- `video-edit` allows DaVinci/Premiere/FFmpeg + storage; flags outbound network beyond licensing endpoints.
- `tax-prep` allows the named tax app + browser to specific finance domains; flags everything else.

## Why declarative beats statistical

- New users have no baseline (cold start).
- Travelling users, BYOD, contractors break statistical baselines repeatedly.
- Statistical baselines are *learnable* by attackers (slow drift).
- Declarative intent makes attacker "blending in" fundamentally harder: even on a fully-baselined endpoint, anything outside the current intent fails closed.

## Implementation

- Intent state stored locally (signed) and reflected in control plane.
- Default intent `idle` is permissive but logs heavily and forbids high-risk actions (no kernel module load, no eBPF load by user processes, no outbound to LLM APIs).
- Templates are YAML, versioned, ship with the agent, and are extensible by tenant admins.
- Browser extension surfaces a small toolbar widget: current intent + expiry. Clicking opens a "request elevation" dialog that triggers an LLM-copilot-mediated approval (with rationale captured for audit).

## Conflict resolution

- Detection rules carry a `respect_intent: bool`. Most do; a few (e.g. eBPF-abuse, ransomware mass-encrypt) ignore intent and always alert.
- An out-of-intent observation produces a **soft flag** by default, **hard block** when severity ≥ HIGH or when the intent's `strict` flag is set (e.g., `tax-prep` is strict).

## UX failure modes

- Risk: users get annoyed and leave intent on `unrestricted` permanently.
- Mitigation:
  - Default intent has decent permissions; only strict tasks tighten further.
  - "Just-in-time" elevation: a one-click "approve this exception for 5 min".
  - Manager reporting on `unrestricted` time per user; visible in the dashboard.

## Coverage

- ATT&CK: T1005 (Data from Local System), T1041 (Exfil over C2), T1078 (Valid Accounts) when used outside expected context.
