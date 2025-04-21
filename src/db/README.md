# Supabase Setup for Meditation App

This guide explains how to set up the Supabase backend for the meditation app.

## Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com/) and sign up or log in
2. Create a new project by clicking "New Project"
3. Give your project a name and set a secure database password
4. Choose a region close to your target audience
5. Wait for your database to be provisioned

## Step 2: Configure Authentication

1. In the Supabase dashboard, go to Authentication > Settings
2. Under Email Auth, ensure "Enable Email Signup" is enabled
3. Optionally, configure additional authentication providers as needed (Google, Apple, etc.)
4. Configure email templates if desired

## Step 3: Set Up Database Schema

1. In the Supabase dashboard, go to SQL Editor
2. Create a new query
3. Copy the contents of `schema.sql` into the SQL editor
4. Run the query to create all tables, functions, and policies

## Step 4: Configure Your App

1. In the Supabase dashboard, go to Settings > API
2. Copy your "Project URL" and "anon" key
3. Update these values in `src/lib/supabase.ts`:

```typescript
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## Step 5: Seed Initial Data (Optional)

If you want to populate your database with initial meditation data:

1. Import the seed data from the SQL editor using the `seed.sql` file
2. Or create meditation sessions manually through the Table Editor

## Database Structure

The database consists of the following tables:

- **profiles**: Extended user information and meditation stats
- **meditation_sessions**: Meditation content metadata
- **meditation_history**: Record of user meditation sessions
- **favorites**: User's saved/favorited meditations

## Row Level Security (RLS)

RLS policies are set up to ensure:

- Users can only access their own profile data
- Users can only see their own meditation history and favorites
- Public meditations are visible to all users
- Users can only modify their own data

## Functions

- **increment_play_count**: Increments the play count for a meditation session
- **update_updated_at_column**: Automatically updates the `updated_at` timestamp 