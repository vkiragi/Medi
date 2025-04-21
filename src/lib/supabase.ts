import 'react-native-url-polyfill/auto';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';

// 1. Go to your Supabase project dashboard
// 2. Navigate to Project Settings → API
// 3. Copy your "Project URL" and paste it below
const supabaseUrl = 'https://ynrrhthrjpztqluhbhfj.supabase.co'; 


const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucnJodGhyanB6dHFsdWhiaGZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMTUwNTMsImV4cCI6MjA2MDc5MTA1M30.GvZNoCDvjY6rLCHy4-Twi5iWtqk8T7ZR7XqaLnaOsgE'; 

// Add debug console logs to troubleshoot
console.log('Initializing Supabase with URL:', supabaseUrl);
console.log('Network status check...');

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

// Function to test Supabase connectivity
export const testSupabaseConnection = async () => {
  try {
    console.log('Testing Supabase connectivity...');
    // Try a simple query to check connectivity
    const { data, error } = await supabase.from('profiles').select('count').limit(1);
    
    if (error) {
      console.error('Supabase connection test failed:', error.message);
      return false;
    }
    
    console.log('Supabase connection successful', data);
    return true;
  } catch (error) {
    console.error('Supabase connection exception:', error);
    return false;
  }
}; 