# Database Schema & Mapping

This document is the single source of truth for the comeback.in database architecture. 
Any agent or developer should read this before writing data-fetching logic.

## Entity Relationship Mapping

- **Profile** `1:N` **User Sessions** (A user has many app launches)
- **Profile** `1:N` **Matches** (A user plays many games)
- **User Session** `1:N` **Events** (A session generates many analytics events)
- **User Session** `1:N` **Matches** (A session can include many games)

## Tables

### 1. `profiles`
- `id` (UUID, PK, References auth.users)
- `username` (Text)
- `email` (Text)
- `status` (Text: 'active', 'blocked')
- `created_at` (Timestamptz)

### 2. `user_sessions`
- `id` (UUID, PK) - Generated on device cold start.
- `user_id` (UUID, FK -> profiles)
- `started_at` (Timestamptz)
- `platform` (Text: 'ios', 'android')
- *Note: No ended_at. Duration is calculated by the delta between the first and last event.*

### 3. `events`
- `id` (UUID, PK)
- `session_id` (UUID, FK -> user_sessions)
- `user_id` (UUID, FK -> profiles)
- `event_name` (Text: e.g., 'app_opened', 'game_started', 'game_completed', 'logout')
- `properties` (JSONB: e.g., {"game_id": "add_burst", "score": 100})
- `created_at` (Timestamptz)

### 4. `matches`
- `id` (UUID, PK) - Generated on device.
- `user_id` (UUID, FK -> profiles)
- `session_id` (UUID, FK -> user_sessions)
- `game_id` (Text: 'add_burst', 'mad_burst', 'bodmas_burst', 'saitan_add', 'saitan_mul', 'small_burst')
- `status` (Text: 'in_progress', 'completed', 'abandoned')
- `score` (Integer)
- `accuracy` (Numeric)
- `duration_seconds` (Integer)
- `started_at` (Timestamptz)
- `ended_at` (Timestamptz)

## Views

### `user_stats`
Aggregates data for the Stats Screen (S-06).
- `user_id`
- `total_games` (Count of completed matches)
- `total_time_seconds` (Sum of duration_seconds)
- `add_burst_pb`, `mad_burst_pb`, `bodmas_burst_pb`, `saitan_add_pb`, `saitan_mul_pb`, `small_burst_pb` (Max score per game)

## Security (RLS)
- All tables have Row Level Security enabled.
- Users can only SELECT, INSERT, and UPDATE rows where `auth.uid() = user_id` (or `id` for profiles).
- If a user is blocked in `profiles`, RLS will reject their inserts (handled via App error trapping).

### Future Schema Updates (Parked)
- `user_sessions`: Add `is_rooted`, `is_jailbroken`, `is_emulator`, `is_debugger_attached`, `is_hooked`, `is_installed_from_store` (See GitHub Issue #[Your Issue Number]).
- `profiles`: Add `username_last_updated` (TIMESTAMPTZ) for the 24-hour username change cooldown.