# Artemis CLI — command surface

The `artemis` CLI is the operator-facing tool. It lives in `crates/artemis-cli` and is a thin wrapper around the daemon's local API + the control-plane HTTP API.

This document is the **command surface contract**: contributors implement subcommands here. Invocation shape is locked; flags within a subcommand are extensible.

## Top-level

```
artemis <command> [options]

Commands:
  status         Show local agent + connectivity status
  enroll         Enrol this device against a tenant
  intent         Manage intent sessions (P4)
  rules          List / show / test detection rules
  alerts         List / show / acknowledge alerts on this device
  decoy          Manage local deception placement (P3)
  ad             Active Defense controls (P14)
  doctor         Diagnose common environment issues
  version        Print version + build info
  help           Show help for any command
```

Every command supports `--json` for machine-readable output and `--verbose` for human-readable diagnostics.

## `artemis status`

```
artemis status
artemis status --json
```

Shows: agent version, uptime, tenant ID + region, last heartbeat, connectivity to ingest, current intent (if any), enabled pillars, performance budget current / cap.

## `artemis enroll`

```
artemis enroll \
    --tenant <ULID> \
    --token <enrolment-token> \
    --profile <dev|school|personal|managed> \
    [--ca-pin <hex>]
```

Performs the EnrollmentService.Enroll RPC. Requires sudo on Linux. Generates the local key pair, exchanges enrolment token + TPM quote (if TPM present), receives device cert.

## `artemis intent`

```
artemis intent start --task <task> [--duration <seconds>] [--strict]
artemis intent stop  [--task <task>]
artemis intent show
artemis intent templates
```

Examples:
- `artemis intent start --task "code:repo=acme/api" --duration 14400`
- `artemis intent start --task "42:minishell" --duration 7200`
- `artemis intent start --task "42:ctf" --duration 3600`
- `artemis intent stop`

State stored locally (signed) at the path in `agent.toml`'s `[intent].state_path`.

## `artemis rules`

```
artemis rules list [--pillar P1..P22] [--severity HIGH..]
artemis rules show <rule-id>
artemis rules test <rule-id> [--event <path-to-json>]
```

Rule packs are read-only on the device — authoring happens in `rules/pack-v0/` in the repo.

## `artemis alerts`

```
artemis alerts list [--since <duration>] [--severity HIGH..]
artemis alerts show <alert-id>
artemis alerts ack <alert-id> [--reason <text>]
```

The local agent caches recent alerts; full historical view lives in the console.

## `artemis decoy`

```
artemis decoy list
artemis decoy show <canary-id>
artemis decoy refresh   # rotate canary placement (admin-restricted)
```

## `artemis ad` (Active Defense)

```
artemis ad status
artemis ad tiers                    # show current tier policy for this device
artemis ad simulate --tier <0..5>   # dry-run a tier (admin only)
artemis ad cancel <action-id>       # cancel a pending Tier 4/5 action within the 60s window
```

Admin-only commands fail unless the local agent has an admin SSO session active.

## `artemis doctor`

```
artemis doctor
```

Runs a battery of self-checks: kernel version + CONFIG_BPF_LSM, eBPF program load, TPM availability, control-plane reachability, mTLS cert validity, performance baseline. Prints a structured report; exits non-zero if any check fails.

## `artemis version`

```
artemis version
artemis version --json
```

Prints version, git commit, build timestamp, supported pillars, supported NAC connectors.

## Error semantics

- Exit 0: success.
- Exit 1: usage error.
- Exit 2: agent not running / not reachable.
- Exit 3: not authorised (cert missing, expired, or not admin).
- Exit 4: control-plane error (network, server, schema).
- Exit 5: integrity error (signature failed, hash mismatch).

JSON output includes `{ "ok": bool, "error": { "code": int, "message": string } }` — humans get coloured pretty-print.

## Hard rules for CLI behaviour

- Never display unredacted PII in default output (use `--unsafe-show-pii` flag, audited).
- Never log secrets or tokens; replace with `<redacted>` in shown commands.
- Destructive commands (`decoy refresh`, `ad simulate`) prompt for confirmation by default; `--yes` for scripting.
- All admin commands generate an audit-log event regardless of outcome.
