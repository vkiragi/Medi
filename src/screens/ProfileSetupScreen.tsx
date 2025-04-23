import React, { useState } from 'react';
import {
  SafeAreaView,
  View,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  Text,
  Alert,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { StackNavigationProp } from '@react-navigation/stack';
import { upsertUserProfile } from '../services/api';
import { useAuth } from '../contexts/AuthContext';

// Define colors in one place for easy theming
const COLORS = {
  primary: '#7F5DF0',
  secondary: '#5D6CC6',
  text: '#FFFFFF',
  background: '#121212',
  inputBackground: 'rgba(255, 255, 255, 0.08)',
  error: '#FF5252',
  placeholderText: 'rgba(255, 255, 255, 0.6)',
};

const ProfileSetupScreen = () => {
  const [fullName, setFullName] = useState('');
  const [username, setUsername] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  
  const { user, setProfileData } = useAuth();

  const handleSubmit = async () => {
    if (!fullName.trim()) {
      setError('Please enter your name');
      return;
    }
    if (!user) {
      setError('User session not found. Please log in again.');
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const profileUpdates = {
        full_name: fullName.trim(),
        username: username.trim() || null,
      };
      
      const updatedProfileData = await upsertUserProfile(profileUpdates);
      
      console.log('[ProfileSetupScreen] Profile upserted:', updatedProfileData);

      setProfileData(updatedProfileData);

    } catch (err) {
      console.error('Error updating/creating profile:', err);
      const errorMessage = err instanceof Error ? err.message : 'Please try again.';
      setError(`Failed to set up profile: ${errorMessage}`);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <LinearGradient
      colors={['#121212', '#1E1E1E']}
      style={styles.gradient}
    >
      <SafeAreaView style={styles.container}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={styles.keyboardAvoid}
        >
          <View style={styles.header}>
            <Text style={styles.title}>Complete Your Profile</Text>
            <Text style={styles.subtitle}>
              Tell us a little about yourself to get started
            </Text>
          </View>

          <View style={styles.form}>
            <View style={styles.inputContainer}>
              <Text style={styles.label}>Full Name</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter your name"
                placeholderTextColor={COLORS.placeholderText}
                value={fullName}
                onChangeText={setFullName}
                autoCapitalize="words"
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Username (Optional)</Text>
              <TextInput
                style={styles.input}
                placeholder="Choose a username"
                placeholderTextColor={COLORS.placeholderText}
                value={username}
                onChangeText={setUsername}
                autoCapitalize="none"
              />
            </View>

            {error ? <Text style={styles.errorText}>{error}</Text> : null}

            <TouchableOpacity
              style={styles.button}
              onPress={handleSubmit}
              disabled={isLoading}
            >
              {isLoading ? (
                <ActivityIndicator color={COLORS.text} />
              ) : (
                <Text style={styles.buttonText}>Get Started</Text>
              )}
            </TouchableOpacity>
          </View>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  gradient: {
    flex: 1,
  },
  container: {
    flex: 1,
    padding: 20,
  },
  keyboardAvoid: {
    flex: 1,
    justifyContent: 'center',
  },
  header: {
    marginBottom: 40,
    alignItems: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 16,
    color: COLORS.placeholderText,
    textAlign: 'center',
  },
  form: {
    width: '100%',
  },
  inputContainer: {
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    color: COLORS.text,
    marginBottom: 8,
  },
  input: {
    height: 50,
    backgroundColor: COLORS.inputBackground,
    borderRadius: 10,
    paddingHorizontal: 16,
    color: COLORS.text,
    fontSize: 16,
  },
  errorText: {
    color: COLORS.error,
    marginTop: 5,
    marginBottom: 15,
  },
  button: {
    height: 50,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.primary,
    marginTop: 20,
  },
  buttonText: {
    color: COLORS.text,
    fontSize: 18,
    fontWeight: 'bold',
  },
});

export default ProfileSetupScreen; 