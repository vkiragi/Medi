# 🔄 Supabase Cloud Sync Integration

This document explains how the medi app integrates with Supabase for cloud synchronization.

## 📋 Features

- **Profile Sync**: User profiles are synced with Supabase
- **Session History**: Meditation sessions sync across devices
- **Apple Sign-In Integration**: Seamless auth flow with Apple ID
- **Automatic & Manual Sync**: Background and on-demand sync options
- **Anonymous Mode**: Local-only usage without cloud sync

## 🚀 Getting Started

### 1. Configure Supabase Credentials

Run the provided script with your Supabase URL and anon key:

```bash
./update_supabase_config.sh "YOUR_SUPABASE_URL" "YOUR_SUPABASE_ANON_KEY"
```

### 2. Build and Run the App

Open the app and sign in with Apple (or use anonymous mode).

### 3. Use Cloud Sync

Navigate to the Profile tab to access sync settings.

## 🔧 Technical Implementation

### Supabase Tables

The app uses the following tables:

1. **profiles**
   - `id` (primary key, string): Apple user ID
   - `email` (string, nullable): User email
   - `name` (string, nullable): User name
   - `created_at` (timestamp): Profile creation time
   - `last_sign_in` (timestamp): Last sign-in time

2. **meditation_sessions**
   - `session_id` (primary key, string): UUID of session
   - `user_id` (string): Foreign key to profiles.id
   - `date` (timestamp): Session date/time
   - `duration` (integer): Duration in seconds
   - `completed` (boolean): Whether session was completed

### 📂 Files Structure

- **SupabaseManager.swift**: Singleton for Supabase client operations
- **MeditationManager.swift**: Includes cloud sync methods for sessions
- **AuthManager.swift**: Integrates Apple Sign-In with Supabase
- **SyncSettingsView.swift**: UI for sync operations

## 🔄 Sync Flow

1. **Sign-In**: When user signs in with Apple ID
   - Create/update profile in Supabase
   - Associate user with their Supabase profile

2. **Session Creation**: After completing a meditation
   - Save locally first (works offline)
   - Queue for sync when online

3. **Manual Sync**: Via Sync Now button
   - Upload local sessions to cloud
   - Download any sessions from other devices
   - Merge with local data

4. **Background Sync**: Occurs at app launch (if signed in)
   - Same process as manual sync

## 🛡️ Privacy & Security

- **Apple Sign-In**: Uses secure Apple authentication
- **Minimal Data**: Only essential meditation data is stored
- **Anonymous Option**: Users can choose not to use cloud sync
- **Data Control**: Users can delete their data

## 🚫 Troubleshooting

**Sync Not Working?**

1. Verify you're signed in with Apple (not anonymous)
2. Check your internet connection
3. Ensure Supabase credentials are correct
4. Try manual sync from Profile tab
5. Check console logs for detailed errors

## 📱 Testing on Multiple Devices

To fully test cloud sync:

1. Sign in with the same Apple ID on multiple devices
2. Complete meditation sessions on each device
3. Use the "Sync Now" button
4. Verify sessions appear on all devices 