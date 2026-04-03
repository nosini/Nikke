-- NIKKE OCR audit log
-- Run once: npx wrangler d1 execute ocr-logs --remote --file=./schema.sql

CREATE TABLE IF NOT EXISTS audit_logs (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp    TEXT    NOT NULL,         -- ISO 8601 UTC
  ip           TEXT,                     -- cf-connecting-ip (real client IP)
  country      TEXT,                     -- 2-letter country code from Cloudflare
  cf_ray       TEXT,                     -- Cloudflare Ray ID — give this to CF support for any incident
  user_agent   TEXT,
  role         TEXT,                     -- 'admin' | 'union' | null (unauthenticated attempt)
  status_code  INTEGER,                  -- HTTP status returned to client
  ai_ok        INTEGER,                  -- 1 = AI succeeded, 0 = AI errored, NULL = never reached AI
  error_msg    TEXT,                     -- error detail if something went wrong
  image_bytes  INTEGER,                  -- decoded image size in bytes
  duration_ms  INTEGER                   -- total request duration in milliseconds
);

-- Index for the queries you'll actually run
CREATE INDEX IF NOT EXISTS idx_timestamp ON audit_logs (timestamp);
CREATE INDEX IF NOT EXISTS idx_role      ON audit_logs (role);
CREATE INDEX IF NOT EXISTS idx_ip        ON audit_logs (ip);
