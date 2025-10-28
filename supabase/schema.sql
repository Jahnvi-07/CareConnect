-- Enable RLS
alter table if exists public.profiles disable row level security;
alter table if exists public.organisations disable row level security;
alter table if exists public.chats disable row level security;
alter table if exists public.messages disable row level security;

-- Users profile table (linked to auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text check (role in ('user','org')) not null,
  name text not null,
  phone text,
  created_at timestamp with time zone default now()
);

-- Organisations owned by an org profile
create table if not exists public.organisations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.profiles(id) on delete cascade,
  name text not null,
  category text,
  city text,
  address text,
  phone text,
  upi_id text,
  description text,
  lat double precision,
  lng double precision,
  geohash text,
  created_at timestamp with time zone default now()
);

-- Chat between a user and an organisation
create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  org_id uuid references public.organisations(id) on delete cascade,
  is_payment_confirmed boolean default false,
  last_message_at timestamp with time zone default now(),
  created_at timestamp with time zone default now()
);

-- Messages in a chat
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid references public.chats(id) on delete cascade,
  sender_role text check (sender_role in ('user','org')) not null,
  text text not null,
  is_confirmation boolean default false,
  created_at timestamp with time zone default now()
);

-- RLS policies (example: tighten as needed)
alter table public.profiles enable row level security;
create policy "profile_self"
  on public.profiles for select using (auth.uid() = id);
create policy "profile_self_write"
  on public.profiles for update using (auth.uid() = id);
create policy "profile_insert"
  on public.profiles for insert with check (auth.uid() = id);

alter table public.organisations enable row level security;
create policy "org_read_all" on public.organisations for select using (true);
create policy "org_owner_write" on public.organisations for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

alter table public.chats enable row level security;
create policy "chat_rw"
  on public.chats for all
  using (
    auth.uid() = user_id or auth.uid() = (select owner_id from public.organisations o where o.id = chats.org_id)
  ) with check (
    auth.uid() = user_id or auth.uid() = (select owner_id from public.organisations o where o.id = chats.org_id)
  );

alter table public.messages enable row level security;
create policy "msg_rw"
  on public.messages for all
  using (
    exists (select 1 from public.chats c where c.id = messages.chat_id and (auth.uid() = c.user_id or auth.uid() = (select owner_id from public.organisations o where o.id = c.org_id)))
  ) with check (
    exists (select 1 from public.chats c where c.id = messages.chat_id and (auth.uid() = c.user_id or auth.uid() = (select owner_id from public.organisations o where o.id = c.org_id)))
  );


