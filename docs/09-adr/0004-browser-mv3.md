# ADR-0004 — Browser extension scope: MV3 only

## Status
Accepted (Phase 0).

## Context
Chrome has deprecated MV2; Firefox supports both. We have to pick a manifest target for the browser sensor.

## Decision
Ship **Manifest V3 only**, on Chrome, Edge, and Firefox.

## Rationale
- MV2 is sunset on Chrome/Edge in 2025.
- MV3 is sufficient for our needs (DOM observation, native messaging, declarative net request, web_accessible_resources control).
- Maintaining two manifests doubles the test surface for marginal benefit.

## Consequences
- We accept MV3 limitations: service-worker lifecycle, declarative net request quotas. We architect around them with `chrome.alarms` + native messaging to the daemon for state continuity.
- Some advanced phishing-detection heuristics that needed MV2's `webRequest` blocking phase are moved to the local daemon (which sees the same flows via OS-level network telemetry).
