-- MVP schema for AppEcchio gamification

CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE events (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE bookings (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  event_id UUID NOT NULL REFERENCES events(id),
  status TEXT NOT NULL CHECK (status IN ('pending','confirmed','cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE merchants (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE point_wallets (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES users(id),
  balance INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE point_ledger_entries (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  source_type TEXT NOT NULL CHECK (source_type IN ('booking','event_checkin','admin_adjustment','voucher_redemption','reversal')),
  source_id UUID NOT NULL,
  points INT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending','confirmed','reversed')),
  idempotency_key TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_point_idempotency UNIQUE (idempotency_key)
);

CREATE INDEX idx_point_ledger_user_created_at ON point_ledger_entries(user_id, created_at DESC);

CREATE TABLE reward_tiers (
  id UUID PRIMARY KEY,
  threshold_points INT NOT NULL,
  reward_type TEXT NOT NULL CHECK (reward_type IN ('percentage_discount','fixed_discount')),
  reward_value NUMERIC(10,2) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_reward_threshold UNIQUE (threshold_points, reward_type, reward_value)
);

CREATE TABLE reward_vouchers (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  tier_id UUID NOT NULL REFERENCES reward_tiers(id),
  merchant_id UUID REFERENCES merchants(id),
  code TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('issued','redeemed','expired','revoked')),
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  redeemed_at TIMESTAMPTZ
);

CREATE INDEX idx_reward_vouchers_user_status ON reward_vouchers(user_id, status);

CREATE TABLE event_checkins (
  id UUID PRIMARY KEY,
  event_id UUID NOT NULL REFERENCES events(id),
  user_id UUID NOT NULL REFERENCES users(id),
  staff_user_id UUID NOT NULL REFERENCES users(id),
  scan_result TEXT NOT NULL CHECK (scan_result IN ('valid','already_checked_in','token_invalid','not_registered','not_authorized')),
  checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_event_user_checkin UNIQUE (event_id, user_id)
);

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY,
  actor_user_id UUID REFERENCES users(id),
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id UUID,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- trigger placeholder: in production, wallet balance should be projected from confirmed ledger entries
