export interface MeditationSession {
  id: string;
  name: string;
  duration: number; // in minutes
  description?: string;
  backgroundImage?: string;
  soundPath?: any;
  soundName?: string;
  category: 'guided' | 'unguided' | 'breathing' | 'body' | 'sleep' | 'compassion' | 'relaxation';
  audioUrl?: string;
  attribution?: string;
  imageUrl?: any;
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

export type RootStackParamList = {
  Home: undefined;
  MeditationDetail: { meditation: MeditationSession };
  MeditationPlayer: { meditation: MeditationSession };
  Attribution: undefined;
  Main: undefined;
  Stats: undefined;
  Profile: undefined;
  Settings: undefined;
  // Auth screens
  Login: undefined;
  SignUp: undefined;
  ForgotPassword: undefined;
  // Root navigation
  App: undefined;
  Auth: undefined;
};

export type TabParamList = {
  HomeTab: undefined | { screen: keyof RootStackParamList };
  ProfileTab: undefined;
  StatsTab: undefined;
  SettingsTab: undefined;
}; 