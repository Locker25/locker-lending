-- Locker Lending production database foundation (PostgreSQL)
-- Sensitive documents, SSNs, credit reports and bank statements are intentionally excluded.

create extension if not exists pgcrypto;

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  display_name text,
  role text not null default 'admin' check (role in ('admin','servicing','read_only')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists borrowers (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references users(id) on delete cascade,
  legal_name text not null,
  entity_type text,
  email text,
  phone text,
  mailing_address text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists loans (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references users(id) on delete cascade,
  borrower_id uuid references borrowers(id) on delete set null,
  borrower_name text not null,
  collateral text,
  deal_type text not null check (deal_type in ('Direct','Brokered','Syndicated')),
  loan_type text not null,
  original_principal numeric(16,2) not null default 0,
  current_balance numeric(16,2) not null default 0,
  annual_rate numeric(10,5),
  monthly_payment numeric(16,2),
  origination_points numeric(8,4),
  per_diem_interest numeric(16,2),
  funded_date date,
  next_payment_due date,
  maturity_date date,
  status text not null default 'Current' check (status in ('Current','Past Due','Extension','Paid Off','Brokered','Default')),
  notes text,
  version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references users(id) on delete cascade,
  loan_id uuid not null references loans(id) on delete cascade,
  payment_date date not null,
  amount numeric(16,2) not null,
  principal_applied numeric(16,2) not null default 0,
  interest_fees numeric(16,2) not null default 0,
  payment_reference text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists loan_events (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references users(id) on delete cascade,
  loan_id uuid not null references loans(id) on delete cascade,
  event_type text not null,
  event_date date not null,
  amount numeric(16,2),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists audit_log (
  id bigserial primary key,
  user_id uuid references users(id) on delete set null,
  entity_type text not null,
  entity_id uuid,
  action text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_loans_owner_status on loans(owner_user_id,status);
create index if not exists idx_loans_maturity on loans(maturity_date);
create index if not exists idx_payments_loan_date on payments(loan_id,payment_date desc);
create index if not exists idx_events_loan_date on loan_events(loan_id,event_date desc);

-- Application requirement:
-- Every API query must be scoped by the authenticated user's owner_user_id.
-- A production deployment should enforce the same tenant boundary with database row-level security
-- or a trusted server-side API before any cloud synchronization is enabled.
