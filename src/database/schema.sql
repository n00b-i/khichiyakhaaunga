-- 1. Profiles Table
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  username TEXT,
  email TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'blocked')),
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 2. User Sessions Table
CREATE TABLE public.user_sessions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  started_at TIMESTAMPTZ NOT NULL,
  platform TEXT
);

-- 3. Events Table (Analytics)
CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES public.user_sessions(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  event_name TEXT NOT NULL,
  properties JSONB,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 4. Matches Table
CREATE TABLE public.matches (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  session_id UUID REFERENCES public.user_sessions(id) ON DELETE SET NULL,
  game_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('in_progress', 'completed', 'abandoned')),
  score INTEGER DEFAULT 0,
  accuracy NUMERIC DEFAULT 0,
  duration_seconds INTEGER DEFAULT 60,
  started_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  ended_at TIMESTAMPTZ
);

-- 5. Stats View
CREATE OR REPLACE VIEW public.user_stats AS
SELECT 
  user_id,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as total_games,
  COALESCE(SUM(CASE WHEN status = 'completed' THEN duration_seconds ELSE 0 END), 0) as total_time_seconds,
  MAX(CASE WHEN game_id = 'add_burst' AND status = 'completed' THEN score END) as add_burst_pb,
  MAX(CASE WHEN game_id = 'mad_burst' AND status = 'completed' THEN score END) as mad_burst_pb,
  MAX(CASE WHEN game_id = 'bodmas_burst' AND status = 'completed' THEN score END) as bodmas_burst_pb,
  MAX(CASE WHEN game_id = 'saitan_add' AND status = 'completed' THEN score END) as saitan_add_pb,
  MAX(CASE WHEN game_id = 'saitan_mul' AND status = 'completed' THEN score END) as saitan_mul_pb,
  MAX(CASE WHEN game_id = 'small_burst' AND status = 'completed' THEN score END) as small_burst_pb
FROM public.matches
GROUP BY user_id;
