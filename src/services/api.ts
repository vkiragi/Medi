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
  const { data: { user } } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Not authenticated');
  }

  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  if (error) {
    throw error;
  }

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
    .select();

  if (error) {
    throw error;
  }

  return data[0];
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