# 05 — Data Model

## Wire format

All endpoint→cloud telemetry uses **OpenTelemetry OTLP** over gRPC + mTLS. Events are encoded as structured logs in protobuf; alerts are OCSF-aligned.

Why OTLP: existing SIEM ecosystems ingest it natively; we don't reinvent a wire format; we get tracing semantics for free.

## Event taxonomy (top-level)

| Category | Examples | Source |
|---|---|---|
| `process` | exec, fork, exit, mmap | Sensor |
| `file` | open, read, write, unlink, canary-touch | Sensor |
| `net` | dns, connect, tls-handshake, http-meta | Sensor |
| `auth` | local-login, sudo, runas, oauth-grant | Sensor + ITDR |
| `kernel` | bpf-load, driver-load, kext-load | Sensor |
| `browser` | nav, dom-prompt-injection-pattern, agent-tool-call | WebExtension |
| `agent` | health, heartbeat, error, version | Daemon |
| `incident` | alert-emitted, playbook-run, p14-action | Control plane |

Each event carries:

```proto
message ArtemisEvent {
  string tenant_id = 1;          // pseudonymous
  string device_id = 2;          // device-cert subject
  string user_pseudonym = 3;     // tenant-side reversible
  google.protobuf.Timestamp ts = 4;
  string category = 5;           // see taxonomy
  string subtype = 6;
  google.protobuf.Struct data = 7; // category-specific payload
  string parent_event_id = 8;    // for chaining
  string event_id = 9;           // ULID
  Severity severity = 10;
  repeated string tags = 11;
  string sig = 12;               // local hash-chain signature
}
```

## Process exec example payload

```json
{
  "category": "process",
  "subtype": "exec",
  "data": {
    "pid": 18324,
    "ppid": 18301,
    "exe": "/usr/bin/curl",
    "exe_sha256": "a1b2…",
    "cmdline_redacted": "curl -sSL <url>",
    "uid": 1000,
    "container_id": null,
    "cfi": {"cet": false, "pac": false, "fortify": true},
    "intent": {"current": "code:repo=acme/api", "in_scope": true}
  }
}
```

`cmdline_redacted`: secrets / tokens / file paths matching sensitive patterns are replaced with `<redacted>` before egress.

## Alert schema (OCSF-aligned)

```proto
message ArtemisAlert {
  string alert_id = 1;
  string tenant_id = 2;
  Severity severity = 3;       // INFO | LOW | MEDIUM | HIGH | CRITICAL
  string title = 4;            // short, deterministic
  string narrative = 5;        // LLM-generated, validated
  repeated string event_ids = 6;
  repeated string attck_techniques = 7;  // e.g. ["T1055", "T1059.001"]
  Verdict verdict = 8;         // CLEAN | SUSPICIOUS | MALICIOUS
  CertifiedRobustness cert = 9; // null if model not certified
  repeated PlaybookSuggestion suggestions = 10;
  string status = 11;          // OPEN | TRIAGED | CONTAINED | CLOSED
  google.protobuf.Timestamp opened_at = 12;
  google.protobuf.Timestamp closed_at = 13;
}
```

## Provenance graph schema

Memgraph (Cypher):

```cypher
(:Process {pid, exe, hash, started_at})-[:EXEC_BY {at}]->(:Process)
(:Process)-[:OPENED {mode, at}]->(:File {path, hash})
(:Process)-[:WROTE {bytes, at}]->(:File)
(:Process)-[:CONNECTED {dst_ip, port, sni, at}]->(:Socket)
(:User)-[:AUTHED_AS {factor, at}]->(:Token {sha, kind})
(:Token)-[:USED_FROM {ip, asn, at}]->(:Host)
(:Process)-[:LOADED {module_hash, at}]->(:Module)
(:Process)-[:LOADED_BPF {prog_type, helpers, at}]->(:BpfProg)
```

Indexes on `(:Process).hash`, `(:File).path`, `(:Token).sha`, `(:Host).id`.

## Identifiers

- `tenant_id`: ULID, control-plane-issued.
- `device_id`: subject CN of device cert; rotates yearly.
- `user_pseudonym`: HKDF(tenant_secret, real_user_id); reversible only by the tenant.
- `event_id`: ULID, monotonic, deduplicates across retries.

## Retention

| Tier | Hot (queryable) | Warm (sampled) | Cold (compliance) |
|---|---|---|---|
| Raw events | 30 days | 90 days | 1 year |
| Alerts | 1 year | 3 years | 7 years (admin opt) |
| Provenance subgraph (incident) | 1 year | 3 years | 7 years |
| Reports / evidence bundles | indefinite (tenant-owned blob store) | — | — |

Retention is per-tenant configurable down to the legal floor for their compliance set.

## Pseudonymisation & re-identification

- All identifiers and free-text fields containing identifiers (paths with usernames, emails) are tokenised at egress.
- Tenant admins hold the re-identification key in a tenant-owned KMS; Artemis cannot re-identify without a customer-issued grant.
- This is enforced cryptographically (BYOK), not just by policy.
