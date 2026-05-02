-- Sample (illustrative) initial Postgres schema for the Artemis control plane.
-- Real migrations live in crates/artemis-detection/migrations/ once Phase 1
-- lands. This file exists so contributors can reason about the shape.
--
-- Per ADR-0006 — schema-per-tenant for Postgres. This file shows the schema
-- structure of one tenant. The control-plane "meta" DB has parallel tables
-- listing tenants and their schemas.

CREATE SCHEMA IF NOT EXISTS tenant_${TENANT_ID};

SET LOCAL search_path TO tenant_${TENANT_ID};

-- Devices enrolled in this tenant.
CREATE TABLE devices (
  device_id        TEXT PRIMARY KEY,                  -- subject CN of device cert
  hardware_id_hash TEXT NOT NULL UNIQUE,
  agent_version    TEXT NOT NULL,
  profile          TEXT NOT NULL CHECK (profile IN ('dev','school','personal','managed')),
  enrolled_at      TIMESTAMPTZ NOT NULL,
  cert_expires_at  TIMESTAMPTZ NOT NULL,
  last_heartbeat   TIMESTAMPTZ,
  pcr_baseline     JSONB,                              -- gold PCR set per device, P9
  status           TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','quarantined','retired')),
  metadata         JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX devices_last_heartbeat_idx ON devices (last_heartbeat);

-- Tenant admins + RBAC. Authentication is via OIDC (no local accounts).
CREATE TABLE admins (
  admin_id   TEXT PRIMARY KEY,                        -- OIDC subject
  email      TEXT NOT NULL UNIQUE,
  display    TEXT NOT NULL,
  roles      TEXT[] NOT NULL DEFAULT '{viewer}'::TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_login TIMESTAMPTZ
);

-- Authority chains for Tier-5 escalation (per scope).
CREATE TABLE authority_chains (
  scope       TEXT PRIMARY KEY,                       -- e.g. '42-network', 'corp-vpn'
  channels    JSONB NOT NULL,                         -- [{kind:'email', target:'soc@...'}, {kind:'webhook', url:'...'}]
  rules       JSONB NOT NULL DEFAULT '{}'::jsonb      -- routing predicates by severity / case-type
);

-- Per-scope Active-Defense tier policy.
CREATE TABLE active_defense_policy (
  scope               TEXT PRIMARY KEY,
  enabled_tiers       INT[] NOT NULL DEFAULT '{0,1}'::INT[],
  nac_connector       TEXT,                            -- freeradius | pfsense | unifi | cisco-ise | aruba-clearpass | meraki
  legal_clearance     BOOLEAN NOT NULL DEFAULT false,  -- gate per ADR-0009
  cancel_window_secs  INT NOT NULL DEFAULT 60          -- per ADR-0011 / ADR-0013
);

-- Intent sessions (P4) — current per-user/per-host intents.
CREATE TABLE intent_sessions (
  device_id      TEXT NOT NULL REFERENCES devices(device_id),
  user_pseudonym TEXT NOT NULL,
  task           TEXT NOT NULL,                        -- e.g. 'code:repo=acme/api', '42:born2beroot'
  started_at     TIMESTAMPTZ NOT NULL,
  ends_at        TIMESTAMPTZ NOT NULL,
  template_ver   TEXT NOT NULL,
  signature      BYTEA NOT NULL,
  PRIMARY KEY (device_id, user_pseudonym, started_at)
);
CREATE INDEX intent_active_idx ON intent_sessions (device_id, ends_at) WHERE ends_at > now();

-- Identity-fusion (P10) attached identity sources for this tenant.
CREATE TABLE identity_sources (
  source_id   TEXT PRIMARY KEY,
  kind        TEXT NOT NULL CHECK (kind IN ('entra','okta','google-workspace','onprem-ad')),
  config      JSONB NOT NULL,                          -- includes secret-manager refs, never raw secrets
  enabled     BOOLEAN NOT NULL DEFAULT true,
  last_synced TIMESTAMPTZ
);

-- Audit log: append-only, hash-chained.
CREATE TABLE audit_log (
  seq          BIGSERIAL PRIMARY KEY,
  ts           TIMESTAMPTZ NOT NULL DEFAULT now(),
  actor        TEXT NOT NULL,                          -- admin_id, device_id, or 'system:autonomic'
  action       TEXT NOT NULL,                          -- e.g. 'tier4-deny', 'rule-promote', 'rollback-trigger'
  target       TEXT,
  payload      JSONB NOT NULL DEFAULT '{}'::jsonb,
  prev_hash    BYTEA NOT NULL,
  this_hash    BYTEA NOT NULL,
  signature    BYTEA NOT NULL                          -- signed by control-plane signer
);
CREATE INDEX audit_log_ts_idx ON audit_log (ts);
CREATE INDEX audit_log_actor_idx ON audit_log (actor);

-- Knowledge-store version pinning per tenant (rule packs / models / playbooks).
CREATE TABLE knowledge_pins (
  bundle_kind   TEXT NOT NULL,
  pinned_version TEXT NOT NULL,
  pinned_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  pinned_by     TEXT NOT NULL,
  rationale     TEXT,
  PRIMARY KEY (bundle_kind)
);

-- Honeytoken attribution buffer (P3 + P14.B fingerprinting).
CREATE TABLE honeytoken_hits (
  hit_id      TEXT PRIMARY KEY,
  canary_id   TEXT NOT NULL,
  observed_at TIMESTAMPTZ NOT NULL,
  source_ip   INET,
  source_asn  INT,
  ja4         TEXT,
  evidence    JSONB NOT NULL
);

-- Migration tracking (refinery / sqlx / sea-orm — pick during Phase 1).
CREATE TABLE _migrations (
  version    TEXT PRIMARY KEY,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  checksum   TEXT NOT NULL
);
INSERT INTO _migrations (version, checksum) VALUES ('001_init', 'TBD');
