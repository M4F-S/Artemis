-- Sample (illustrative) initial ClickHouse schema for the Artemis event store.
-- Real migrations live in crates/artemis-detection/migrations-clickhouse/
-- once Phase 1 lands.
--
-- Per ADR-0006 — DB-per-tenant for ClickHouse. This is the schema template;
-- each tenant gets its own DB.

CREATE DATABASE IF NOT EXISTS artemis_${TENANT_ID};

-- Raw events (hot tier).
CREATE TABLE artemis_${TENANT_ID}.events
(
  ts                 DateTime64(3, 'UTC'),
  event_id           FixedString(26),                   -- ULID
  parent_event_id    Nullable(FixedString(26)),
  device_id          LowCardinality(String),
  user_pseudonym     LowCardinality(String),
  category           LowCardinality(String),
  subtype            LowCardinality(String),
  severity           Enum8('UNSPECIFIED'=0,'INFO'=1,'LOW'=2,'MEDIUM'=3,'HIGH'=4,'CRITICAL'=5),
  tags               Array(LowCardinality(String)),
  data               String,                            -- JSON, validated at ingest
  sig                String,                            -- hash-chain link
  ingest_ts          DateTime64(3, 'UTC') DEFAULT now64(3),
  ingest_batch_id    FixedString(26),

  -- Common projected fields (extracted at ingest for fast filtering).
  proc_pid           Nullable(UInt32) MATERIALIZED toUInt32OrNull(JSONExtractString(data,'pid')),
  proc_exe           LowCardinality(String) MATERIALIZED JSONExtractString(data,'exe'),
  proc_exe_sha256    String MATERIALIZED JSONExtractString(data,'exe_sha256'),
  net_dst_ip         Nullable(IPv6) MATERIALIZED toIPv6OrNull(JSONExtractString(data,'dst_ip')),
  attck_techniques   Array(LowCardinality(String)) MATERIALIZED arrayFilter(t -> startsWith(t,'T'), tags)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(ts)
ORDER BY (device_id, category, ts, event_id)
TTL toDateTime(ts) + INTERVAL 30 DAY DELETE,
    toDateTime(ts) + INTERVAL 90 DAY TO VOLUME 'cold',
    toDateTime(ts) + INTERVAL 365 DAY DELETE
SETTINGS index_granularity = 8192;

-- Materialised view: per-minute counts by category (drives dashboards).
CREATE MATERIALIZED VIEW artemis_${TENANT_ID}.events_per_minute_mv
ENGINE = AggregatingMergeTree
PARTITION BY toYYYYMM(minute)
ORDER BY (device_id, category, minute)
AS
SELECT
  toStartOfMinute(ts) AS minute,
  device_id,
  category,
  countState() AS events
FROM artemis_${TENANT_ID}.events
GROUP BY minute, device_id, category;

-- Alerts.
CREATE TABLE artemis_${TENANT_ID}.alerts
(
  alert_id        FixedString(26),
  tenant_id       LowCardinality(String),
  opened_at       DateTime64(3,'UTC'),
  closed_at       Nullable(DateTime64(3,'UTC')),
  severity        Enum8('UNSPECIFIED'=0,'INFO'=1,'LOW'=2,'MEDIUM'=3,'HIGH'=4,'CRITICAL'=5),
  status          Enum8('OPEN'=0,'TRIAGED'=1,'CONTAINED'=2,'CLOSED'=3),
  verdict         Enum8('CLEAN'=0,'SUSPICIOUS'=1,'MALICIOUS'=2),
  title           String,
  narrative       String,                                -- LLM-generated, validated
  attck_techniques Array(LowCardinality(String)),
  rule_ids        Array(LowCardinality(String)),
  device_ids      Array(LowCardinality(String)),
  event_ids       Array(FixedString(26)),
  cert_radius     Nullable(Float64),                     -- P8 certified-robustness radius if applicable
  cert_radius_norm String,                                -- 'l2' | 'linf' | null
  suggested_tier  UInt8,                                  -- ADR-0013 hint
  payload         String                                  -- JSON, full alert detail
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(opened_at)
ORDER BY (opened_at, alert_id);

-- BAS (P17) run results.
CREATE TABLE artemis_${TENANT_ID}.bas_runs
(
  run_id          FixedString(26),
  scenario_id     LowCardinality(String),
  scenario_ver    LowCardinality(String),
  started_at      DateTime64(3,'UTC'),
  finished_at     Nullable(DateTime64(3,'UTC')),
  status          Enum8('RUNNING'=0,'PASS'=1,'FAIL'=2,'ERROR'=3),
  detected_depth  Enum8('NONE'=0,'EARLY'=1,'MID'=2,'LATE'=3),
  contained_tier  Nullable(UInt8),
  evidence        String                                  -- JSON, run report
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(started_at)
ORDER BY (started_at, run_id);

-- Federation contributions ledger (P6 / P16).
CREATE TABLE artemis_${TENANT_ID}.federation_ledger
(
  ts            DateTime64(3,'UTC'),
  round_id      FixedString(26),
  bundle_kind   LowCardinality(String),
  contribution_size_bytes UInt32,
  outlier_score Nullable(Float32),                        -- if quarantined
  status        Enum8('SUBMITTED'=0,'AGGREGATED'=1,'QUARANTINED'=2)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(ts)
ORDER BY (ts, round_id);

-- Migration tracking.
CREATE TABLE artemis_${TENANT_ID}._migrations
(
  version    String,
  applied_at DateTime64(3,'UTC') DEFAULT now64(3),
  checksum   String
)
ENGINE = MergeTree ORDER BY version;
INSERT INTO artemis_${TENANT_ID}._migrations (version, checksum) VALUES ('001_init', 'TBD');
