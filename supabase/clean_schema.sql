-- Clean schema that handles existing policies
-- Run this instead of the original schema.sql

-- Drop existing policies first (ignore errors if they don't exist)
DROP POLICY IF EXISTS "profile_self" ON public.profiles;
DROP POLICY IF EXISTS "profile_self_write" ON public.profiles;
DROP POLICY IF EXISTS "profile_insert" ON public.profiles;
DROP POLICY IF EXISTS "org_read_all" ON public.organisations;
DROP POLICY IF EXISTS "org_owner_write" ON public.organisations;
DROP POLICY IF EXISTS "chat_rw" ON public.chats;
DROP POLICY IF EXISTS "msg_rw" ON public.messages;

-- Disable RLS temporarily
ALTER TABLE IF EXISTS public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.organisations DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.chats DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.messages DISABLE ROW LEVEL SECURITY;

-- Create tables if they don't exist
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role text CHECK (role IN ('user','org')) NOT NULL,
  name text NOT NULL,
  phone text,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.organisations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  category text,
  city text,
  address text,
  phone text,
  upi_id text,
  description text,
  lat double precision,
  lng double precision,
  geohash text,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.chats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  org_id uuid REFERENCES public.organisations(id) ON DELETE CASCADE,
  is_payment_confirmed boolean DEFAULT false,
  last_message_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id uuid REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_role text CHECK (sender_role IN ('user','org')) NOT NULL,
  text text NOT NULL,
  is_confirmation boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organisations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "profile_self"
  ON public.profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profile_self_write"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "profile_insert"
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "org_read_all" 
  ON public.organisations FOR SELECT USING (true);

CREATE POLICY "org_owner_write" 
  ON public.organisations FOR ALL USING (auth.uid() = owner_id) 
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "chat_rw"
  ON public.chats FOR ALL
  USING (
    auth.uid() = user_id OR auth.uid() = (SELECT owner_id FROM public.organisations o WHERE o.id = chats.org_id)
  ) WITH CHECK (
    auth.uid() = user_id OR auth.uid() = (SELECT owner_id FROM public.organisations o WHERE o.id = chats.org_id)
  );

CREATE POLICY "msg_rw"
  ON public.messages FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.chats c WHERE c.id = messages.chat_id AND (auth.uid() = c.user_id OR auth.uid() = (SELECT owner_id FROM public.organisations o WHERE o.id = c.org_id)))
  ) WITH CHECK (
    EXISTS (SELECT 1 FROM public.chats c WHERE c.id = messages.chat_id AND (auth.uid() = c.user_id OR auth.uid() = (SELECT owner_id FROM public.organisations o WHERE o.id = c.org_id)))
  );
