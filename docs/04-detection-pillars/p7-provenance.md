# P7 — Causal Provenance Graphs

**Gap closed:** Tier 2 #6. Provenance-IDS is a strong academic line (ORTHRUS, ProvSyn, Memgraph-based PIDS) hitting the open challenges of scalability, threshold tuning, and semantic understanding. Mainstream EDR has *partial* provenance views; few do causal root-cause well, and none combine graph reasoning with LLM semantics.

## Goals

- Reconstruct attack chains end-to-end: from initial entry → lateral movement → impact.
- Reduce alert fatigue by clustering related events into one *incident* node, not 200 alerts.
- Expose explainable root cause: "the breach started here, because this happened."

## Graph model

Nodes:
- `Process` (PID + start time + binary hash + cmdline)
- `File` (path + hash)
- `Socket` (5-tuple + TLS SNI)
- `User` / `Service Account` (resolved identity)
- `Token` (OAuth/Kerberos/JWT fingerprint)
- `Host`
- `Module` / `Library`
- `eBPF Program` / `Kernel Driver`

Edges:
- `EXEC_BY`, `OPENED`, `WROTE`, `READ`, `CONNECTED`, `LOADED`, `AUTHED_AS`, `HOLDS_TOKEN`, `LATERAL_TO`.

Attributes carry severity, alert references, and confidence.

## Storage

- **Per-tenant** Memgraph cluster (sized by event rate).
- 30 days hot, longer in compressed cold (see `05-data-model.md`).
- Sub-graph queries < 200 ms p95 for typical investigation depth (3 hops).

## Enrichment

- ATT&CK technique tagging at edge level (rule-driven).
- Reputation scores on hashes / SNIs (cached, federated).
- Identity context joined from P10 (ITDR).

## Detection through graph patterns

Examples (Cypher-flavoured):

- *Hands-on-keyboard ransomware loop*:
  ```
  MATCH (p:Process)-[:WROTE]->(f:File)
  WHERE size(f.path) matches encrypted-extension-pattern AND count > 200 in 5m
  ```
- *Token replay*:
  ```
  MATCH (t:Token)-[:USED_FROM]->(h1:Host), (t)-[:USED_FROM]->(h2:Host)
  WHERE h1 <> h2 AND impossible_travel(h1, h2, dt)
  ```
- *Eligible-LOLBin chain*:
  ```
  MATCH (p1:Process {name:"mshta.exe"})-[:EXEC_BY]->(p2:Process)
  WHERE p2.cmdline contains "powershell" AND ancestor(p1) in office-suite-set
  ```

Rules are versioned, reviewable, run incrementally on the streaming graph.

## LLM-assisted root-cause analysis

For each *incident* node:

1. Construct a sub-graph (relevant nodes + edges + alerts).
2. Feed into the LLM copilot with a structured "explain the chain" prompt.
3. The LLM produces a narrative ("user clicked link → spawned mshta → fetched payload from X → executed Y → wrote canary → contained") with each claim linked back to a node ID.
4. Validation step: every claim must reference an existing node; otherwise rejected.

This addresses the academic gap on "limited semantic understanding" by combining graph topology (what happened) with LLM semantics (why it matters).

## Performance

- Streaming ingest at 50k events/sec/tenant (target) using batched MERGE.
- Periodic compaction collapses identical sub-trees (graph summarisation).
- Compaction respects a "preserve forensic detail" flag for hot incidents.

## Coverage

- ATT&CK: nearly all tactics covered, since provenance is generic.
- Specific strengths: lateral movement (TA0008), exfiltration (TA0010), command-and-control (TA0011).
