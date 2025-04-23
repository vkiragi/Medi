import { supabase } from '../lib/supabase';
import { Database } from '../models/dbSchema';
import { User } from '@supabase/supabase-js';

// ==================== Auth Operations ==================== //

// Create or update user profile after registration
export const createUserProfile = async (user: User) => {
  const { data, error } = await supabase
    .from('profiles')
    .insert([
      {
        id: user.id,
        email: user.email || '',
        username: null,
        full_name: null,
        avatar_url: null,
        streak_days: 0,
        longest_streak: 0,
        total_minutes_meditated: 0,
        level: 1,
      },
    ])
    .select();

  if (error) {
    throw error;
  }
  
  return data[0];
};

// Get the current user's profile
export const getCurrentProfile = async () => {
  console.log('[getCurrentProfile] Attempting to get user session...');
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  
  if (authError) {
    console.error('[getCurrentProfile] Error getting user session:', authError);
    throw new Error('Failed to get user session');
  }
  if (!user) {
    console.log('[getCurrentProfile] No authenticated user found.');
    throw new Error('Not authenticated');
  }
  console.log('[getCurrentProfile] User found, attempting to fetch profile for id:', user.id);

  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  // Log the result or error from the profile fetch
  if (error) {
    console.error('[getCurrentProfile] Error fetching profile data:', error);
    // Don't throw PGRST116 error, just return null as profile doesn't exist yet
    if (error.code === 'PGRST116') { 
      console.log('[getCurrentProfile] Profile not found (PGRST116), returning null.');
      return null; 
    }
    throw error; // Throw other errors
  }

  console.log('[getCurrentProfile] Profile data fetched successfully:', data);
  return data;
};

// Update user profile
export const updateProfile = async (updates: Partial<Database['public']['Tables']['profiles']['Update']>) => {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Not authenticated');
  }

  const { data, error } = await supabase
    .from('profiles')
    .update(updates)
    .eq('id', user.id)
    .select('*');

  // Log the raw response from Supabase
  console.log('[updateProfile] Supabase returned data:', JSON.stringify(data));
  console.log('[updateProfile] Supabase returned error:', JSON.stringify(error));

  if (error) {
    // Log the error before throwing
    console.error('[updateProfile] Throwing error:', error);
    throw error;
  }

  // Log the value we are about to return
  console.log('[updateProfile] Returning data[0]:', JSON.stringify(data?.[0]));

  return data?.[0]; // Use optional chaining just in case data is null
};

// ==================== Meditation Operations ==================== //

// Get all meditation sessions
export const getMeditationSessions = async () => {
  const { data, error } = await supabase
    .from('meditation_sessions')
    .select('*')
    .order('name');

  if (error) {
    throw error;
  }

  return data;
};

// Get popular meditation sessions
export const getPopularMeditations = async (limit = 5) => {
  const { data, error } = await supabase
    .from('meditation_sessions')
    .select('*')
    .eq('popular', true)
    .order('play_count', { ascending: false })
    .limit(limit);

  if (error) {
    throw error;
  }

  return data;
};

// Get meditation sessions by category
export const getMeditationsByCategory = async (category: string) => {
  const { data, error } = await supabase
    .from('meditation_sessions')
    .select('*')
    .eq('category', category)
    .order('name');

  if (error) {
    throw error;
  }

  return data;
};

// Get a single meditation session by ID
export const getMeditationById = async (id: string) => {
  const { data, error } = await supabase
    .from('meditation_sessions')
    .select('*')
    .eq('id', id)
    .single();

  if (error) {
    throw error;
  }

  return data;
};

// Increment play count for a meditation
export const incrementPlayCount = async (id: string) => {
  const { data, error } = await supabase.rpc('increment_play_count', {
    meditation_id: id
  });

  if (error) {
    throw error;
  }

  return data;
};

// ==================== User Meditation History ==================== //

// Record a completed meditation session
export const recordMeditationSession = async (meditationId: string, durationSeconds: number, completed: boolean, notes?: string) => {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Not authenticated');
  }

  const { data, error } = await supabase
    .from('meditation_history')
    .insert([
      {
        user_id: user.id,
        meditation_id: meditationId,
        completed_at: new Date().toISOString(),
        duration_seconds: durationSeconds,
        completed,
        notes,
      },
    ])
    .select();

  if (error) {
    throw error;
  }

  // Update user total meditation time
  if (completed) {
    await updateProfile({
      total_minutes_meditated: durationSeconds / 60,
    });
  }

  return data[0];
};

// Get user's meditation history
export const getMeditationHistory = async (limit = 10) => {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Not authenticated');
  }

  const { data, error } = await supabase
    .from('meditation_history')
    .select(`
      *,
      meditation_sessions:meditation_id (*)
    `)
    .eq('user_id', user.id)
    .order('completed_at', { ascending: false })
    .limit(limit);

  if (error) {
    throw error;
  }

  return data;
};

// ==================== Favorites Operations ==================== //

// Add a meditation to favorites
export const addToFavorites = async (meditationId: string) => {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Not authenticated');
  }

  const { data, error } = await supabase
    .from('favorites')
    .insert([
      {
        user_id: user.id,
        meditation_id: meditationId,
      },
    ])
    .select();

  if (error) {
    throw error;
  }

  return data[0];
};

// Remove a meditation from favorites
export const removeFromFavorites = async (meditationId: string) => {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Not authenticated');
  }

  const { data, error } = await supabase
    .from('favorites')
    .delete()
    .match({
      user_id: user.id,
      meditation_id: meditationId,
    })
    .select();

  if (error) {
    throw error;
  }

  return data;
};

// Get user's favorite meditations
export const getFavorites = async () => {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Not authenticated');
  }

  const { data, error } = await supabase
    .from('favorites')
    .select(`
      *,
      meditation_sessions:meditation_id (*)
    `)
    .eq('user_id', user.id);

  if (error) {
    throw error;
  }

  return data;
};

// Check if a meditation is in favorites
export const isFavorite = async (meditationId: string) => {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Not authenticated');
  }

  const { data, error } = await supabase
    .from('favorites')
    .select('*')
    .match({
      user_id: user.id,
      meditation_id: meditationId,
    })
    .single();

  if (error && error.code !== 'PGRST116') { // PGRST116 is the error code for no rows returned
    throw error;
  }

  return Boolean(data);
};

// Renamed and corrected function to upsert profile details
export async function upsertUserProfile(profileData: Partial<Omit<Database['public']['Tables']['profiles']['Row'], 'id' | 'created_at' | 'updated_at'>>) {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) throw new Error("User not authenticated");
  
  const upsertData = {
    ...profileData,
    id: user.id, // Ensure ID is always set for upsert
    email: user.email || '', // Include the user's email from auth
    updated_at: new Date().toISOString(), // Manually set updated_at
  };

  // Remove potentially undefined fields if they are null in the input
  if (upsertData.username === null) delete upsertData.username;
  if (upsertData.full_name === null) delete upsertData.full_name;
  
  console.log('[upsertUserProfile] Upserting data:', upsertData);

  const { data, error } = await supabase
    .from('profiles')
    .upsert(upsertData, { 
      onConflict: 'id'
    })
    .select('*') // Select the updated/inserted row
    .single(); // Expect a single row back
    
  // Log the raw response
  console.log('[upsertUserProfile] Supabase returned data:', JSON.stringify(data));
  console.log('[upsertUserProfile] Supabase returned error:', JSON.stringify(error));

  if (error) {
    console.error('[upsertUserProfile] Error upserting profile:', error);
    throw error;
  }
  
  console.log('[upsertUserProfile] Returning upserted profile:', data);
  return data; // Return the single profile object
}

// Function to fetch the profile (kept for completeness, can be merged/refactored)
export async function getUserProfile() {
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) throw new Error("User not authenticated");
  
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();
    
  if (error && error.code !== 'PGRST116') throw error;
  
  return data;
} 