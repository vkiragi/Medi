// This file defines TypeScript interfaces for the database schema

export interface Profile {
  id: string; // Matches Supabase auth.users.id
  username: string | null;
  full_name: string | null;
  avatar_url: string | null;
  email: string;
  created_at: string;
  updated_at: string;
  streak_days: number;
  longest_streak: number;
  total_minutes_meditated: number;
  level: number;
  preferred_categories?: string[];
}

export interface MeditationHistory {
  id: string;
  user_id: string;
  meditation_id: string;
  completed_at: string;
  duration_seconds: number;
  completed: boolean;
  notes?: string;
}

export interface Favorite {
  id: string;
  user_id: string;
  meditation_id: string;
  created_at: string;
}

export interface MeditationSession {
  id: string;
  name: string;
  duration: number; // in minutes
  description?: string;
  category: string;
  attribution?: string;
  audio_url?: string;
  image_url?: string;
  created_at: string;
  updated_at: string;
  public: boolean;
  creator_id?: string;
  popular: boolean;
  play_count: number;
}

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: Profile;
        Insert: Omit<Profile, 'created_at' | 'updated_at'>;
        Update: Partial<Omit<Profile, 'id' | 'created_at' | 'updated_at'>>;
      };
      meditation_history: {
        Row: MeditationHistory;
        Insert: Omit<MeditationHistory, 'id' | 'created_at'>;
        Update: Partial<Omit<MeditationHistory, 'id' | 'user_id' | 'created_at'>>;
      };
      favorites: {
        Row: Favorite;
        Insert: Omit<Favorite, 'id' | 'created_at'>;
        Update: Partial<Omit<Favorite, 'id' | 'user_id' | 'created_at'>>;
      };
      meditation_sessions: {
        Row: MeditationSession;
        Insert: Omit<MeditationSession, 'id' | 'created_at' | 'updated_at' | 'play_count'>;
        Update: Partial<Omit<MeditationSession, 'id' | 'created_at' | 'updated_at'>>;
      };
    };
  };
} 