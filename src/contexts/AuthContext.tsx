import React, { createContext, useState, useEffect, useContext, useCallback } from 'react';
import { Alert } from 'react-native';
import { supabase } from '../lib/supabase';
import { Session, User } from '@supabase/supabase-js';
import { getCurrentProfile, createUserProfile } from '../services/api';
import { UserProfile } from '../types';

type AuthContextType = {
  user: User | null;
  session: Session | null;
  profile: UserProfile | null;
  loading: boolean;
  loadingProfile: boolean;
  signUp: (email: string, password: string) => Promise<void>;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  refetchUserProfile: () => Promise<void>;
  setProfileData: (profileData: UserProfile | null) => void;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{children: React.ReactNode}> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [authLoading, setAuthLoading] = useState(true);
  const [loadingProfile, setLoadingProfile] = useState(false);

  const fetchUserProfile = useCallback(async (currentUser: User | null) => {
    if (currentUser) {
      setLoadingProfile(true);
      try {
        const userProfile = await getCurrentProfile();
        console.log('[AuthContext] Fetched profile:', userProfile);
        setProfile(userProfile);
      } catch (error: any) {
        if (error?.code !== 'PGRST116') {
          console.error("[AuthContext] Failed to fetch profile:", error);
        }
        console.log('[AuthContext] Setting profile to null due to fetch error or no profile.');
        setProfile(null);
      } finally {
        setLoadingProfile(false);
      }
    } else {
      console.log('[AuthContext] No current user, setting profile to null.');
      setProfile(null);
      setLoadingProfile(false);
    }
  }, []);

  useEffect(() => {
    // Check initial session
    const checkSession = async () => {
      setAuthLoading(true);
      try {
        // Only get session here, don't fetch profile yet
        const { data, error } = await supabase.auth.getSession();
        if (error) throw error;
        
        // Set initial session and user based on getSession result
        setSession(data.session);
        setUser(data.session?.user ?? null);
        // NOTE: We removed the initial fetchUserProfile call from here

      } catch (err: any) {
        console.error("Failed to get session:", err.message);
        // Ensure user/session are null if session check fails
        setSession(null);
        setUser(null);
      } finally {
        setAuthLoading(false); // Auth loading is done once session is checked
      }
    };
    
    checkSession();

    // Listen for auth changes and fetch profile accordingly
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, newSession) => {
      console.log("[AuthContext] Auth state changed, Event:", _event, "Session:", !!newSession);
      const currentUser = newSession?.user ?? null;
      setSession(newSession);
      setUser(currentUser);
      // Fetch profile whenever auth state changes (login/logout/initial)
      await fetchUserProfile(currentUser);
    });

    return () => {
      subscription.unsubscribe();
    };
  }, [fetchUserProfile]); // fetchUserProfile dependency is correct here

  const refetchUserProfile = useCallback(async () => {
    await fetchUserProfile(user);
  }, [user, fetchUserProfile]);

  const setProfileData = useCallback((profileData: UserProfile | null) => {
    console.log('[AuthContext] Directly setting profile data:', profileData);
    setProfile(profileData);
    if (loadingProfile) setLoadingProfile(false);
  }, [loadingProfile]);

  const signUp = async (email: string, password: string) => {
    let newUser: User | null = null;
    try {
      setAuthLoading(true);
      console.log('Attempting sign up for:', email);
      // Use data destructuring to get the user object on success
      const { data: signUpData, error } = await supabase.auth.signUp({ email, password });

      if (error) {
        console.error('Supabase signUp error:', error.message, error);
        throw error;
      }
      
      // Check if user object exists in the response
      if (signUpData?.user) {
        newUser = signUpData.user;
        console.log('[AuthContext] SignUp successful, creating profile for user:', newUser.id);
        // Create the initial profile row
        await createUserProfile(newUser); 
        // Alert the user (if email confirmation is OFF)
        // If email confirmation is ON, this alert might be premature
        Alert.alert('Success', 'Account created! Please complete your profile.');
        // No need to manually set user/session state here, 
        // onAuthStateChange listener will handle it after signup
      } else {
        // Handle case where signup might succeed but user object is missing (shouldn't typically happen)
        console.error('Supabase signUp succeeded but no user data returned.');
        throw new Error('Sign up failed to return user data.');
      }

    } catch (error: any) {
      console.error('Sign up exception:', error);
      Alert.alert('Error', error.message);
    } finally {
      setAuthLoading(false);
    }
  };

  const signIn = async (email: string, password: string) => {
    try {
      setAuthLoading(true);
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;
    } catch (error: any) {
      console.error('Sign in exception:', error);
      Alert.alert('Error', error.message);
    } finally {
      setAuthLoading(false);
    }
  };

  const signOut = async () => {
    try {
      setAuthLoading(true);
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
    } catch (error: any) {
      Alert.alert('Error', error.message);
    } finally {
      setAuthLoading(false);
    }
  };

  const resetPassword = async (email: string) => {
    try {
      setAuthLoading(true);
      const { error } = await supabase.auth.resetPasswordForEmail(email);
      if (error) throw error;
      Alert.alert('Success', 'Check your email for the reset link');
    } catch (error: any) {
      Alert.alert('Error', error.message);
    } finally {
      setAuthLoading(false);
    }
  };

  return (
    <AuthContext.Provider value={{
      user,
      session,
      profile,
      loading: authLoading,
      loadingProfile,
      signUp,
      signIn,
      signOut,
      resetPassword,
      refetchUserProfile,
      setProfileData,
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}; 