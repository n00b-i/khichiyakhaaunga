# Technical Architecture

## The Stack
*   **Frontend:** Flutter (Dart) - iOS & Android.
*   **Backend:** Supabase (BaaS).
*   **Database:** PostgreSQL (managed by Supabase).

## Directory Structure
*   `/agent_docs`: Project context, architecture, and AI prompts.
*   `/src`: Supabase SQL schemas, RLS policies, and Edge Functions (TypeScript).
*   `/Development`: The root of the Flutter application.

## Database Schema (Draft)
### `profiles`
*   `id` (UUID, references auth.users)
*   `username` (String)
*   `created_at` (Timestamp)

### `scores`
*   `id` (UUID)
*   `user_id` (UUID, references profiles.id)
*   `game_id` (String) - e.g., 'number_hunt', 'rebus'
*   `score` (Integer)
*   `time_taken` (Integer)
*   `accuracy` (Float)
*   `created_at` (Timestamp)

## Security
We use Supabase Row Level Security (RLS) so users can only read/update their own profile and scores. Edge Functions handle secure push notifications and anti-cheat validation.
