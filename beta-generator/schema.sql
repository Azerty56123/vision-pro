-- VISION PRO V4 - Cloudflare D1 database.
CREATE TABLE IF NOT EXISTS beta_keys (
  id TEXT PRIMARY KEY,
  key_hash TEXT UNIQUE NOT NULL,
  label TEXT NOT NULL DEFAULT 'Beta V4',
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL DEFAULT 0,
  max_activations INTEGER NOT NULL DEFAULT 0,
  uses INTEGER NOT NULL DEFAULT 0,
  disabled INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_beta_keys_created_at ON beta_keys(created_at DESC);
CREATE TABLE IF NOT EXISTS beta_attempts (
  ip_hash TEXT PRIMARY KEY,
  attempts INTEGER NOT NULL DEFAULT 0,
  window_start INTEGER NOT NULL
);