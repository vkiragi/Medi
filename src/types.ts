import { NavigatorScreenParams } from '@react-navigation/native';

// ======================================
// Navigation Param Lists
// ======================================

// --- Root Stack (Handles Auth vs App flows) ---
export type RootStackParamList = {
  Auth: NavigatorScreenParams<AuthStackParamList>;
  App: NavigatorScreenParams<AppStackParamList>;
  ProfileSetup: undefined;
};

// --- Authentication Stack (Login, Sign Up, Forgot Password) ---
export type AuthStackParamList = {
  Login: undefined;
  SignUp: undefined;
  ForgotPassword: undefined;
};

// --- Main App Stack (Contains Tabs and Fullscreen Modals/Screens) ---
export type AppStackParamList = {
  Main: NavigatorScreenParams<TabParamList>; // The Bottom Tab Navigator
  MeditationDetail: { meditation: MeditationSession }; // Pass the whole object for now
  MeditationPlayer: { meditation: MeditationSession }; // Pass the whole object for now
  Attribution: undefined;
};

// --- Bottom Tab Navigator ---
export type TabParamList = {
  HomeTab: NavigatorScreenParams<HomeStackParamList>; // Nested Home Stack
  ProfileTab: undefined;
  StatsTab: undefined;
  SettingsTab: undefined;
};

// --- Home Tab's Stack ---
export type HomeStackParamList = {
  Home: undefined;
  // Detail/Player are navigated via AppStack
};

// ======================================
// Data Models
// ======================================

// Keep existing MeditationSession, Sound, MeditationStats interfaces
export interface MeditationSession {
  id: string;
  name: string;
  duration: number; // in minutes
  description?: string;
  backgroundImage?: string;
  soundPath?: any; // Keep `any` for require() or update based on final implementation
  soundName?: string;
  // Allow string for categories fetched from DB, keep specific types for local data if needed
  category: string | 'guided' | 'unguided' | 'breathing' | 'breath' | 'body' | 'sleep' | 'compassion' | 'relaxation' | 'meditate' | 'affirmate';
  audioUrl?: string;
  attribution?: string;
  imageUrl?: any; // Keep `any` for require() or update
  created_at?: string; // Optional for local data
  updated_at?: string; // Optional for local data
  public?: boolean; // Optional for local data
  creator_id?: string; // Optional for local data
  popular?: boolean; // Optional for local data
  play_count?: number; // Optional for local data
}

export interface Sound {
  id: string;
  name: string;
  path: string;
}

export interface MeditationStats {
  totalSessions: number;
  totalMinutes: number;
  currentStreak: number;
  longestStreak: number;
  lastSessionDate?: Date;
}

// Update UserProfile based on dbSchema
export interface UserProfile {
  id: string; // Matches Supabase auth.users.id
  username: string | null;
  full_name: string | null;
  avatar_url: string | null;
  email?: string; // Email is usually part of the Auth user, maybe not needed here unless denormalized
  created_at?: string;
  updated_at?: string;
  streak_days?: number;
  longest_streak?: number;
  total_minutes_meditated?: number;
  level?: number;
  preferred_categories?: string[];
}

// Update MeditationHistoryItem based on dbSchema
export interface MeditationHistoryItem {
  id: string;
  user_id: string;
  meditation_id: string;
  completed_at: string;
  duration_seconds: number;
  completed: boolean;
  notes?: string | null;
  meditation_sessions?: MeditationSession; // Populated from join
}

// Specific screen parameters if needed (example)
export type MeditationDetailParams = {
  meditationId: string;
};

export type MeditationPlayerParams = {
  meditationId: string;
};

// You can expand these types as your app grows