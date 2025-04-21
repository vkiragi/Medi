import React, { useState } from 'react';
import { 
  StyleSheet, 
  View, 
  SafeAreaView, 
  TouchableOpacity, 
  KeyboardAvoidingView, 
  Platform, 
  ScrollView,
  StatusBar 
} from 'react-native';
import { Text, TextInput, Button } from 'react-native-paper';
import { LinearGradient } from 'expo-linear-gradient';
import { useAuth } from '../contexts/AuthContext';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../types';

type SignUpScreenNavigationProp = StackNavigationProp<RootStackParamList, 'SignUp'>;

// Dark theme gradient colors
const DARK_GRADIENT_COLORS = ['#0F0F0F', '#171717', '#1F1F1F', '#171717'] as const;

// Color palette for dark theme
const COLORS = {
  primary: '#7928CA', // Vibrant purple
  secondary: '#FF0080', // Hot pink
  dark: '#000000', // Black
  darkGray: '#121212', // Dark gray
  mediumGray: '#1E1E1E', // Medium gray
  cardBg: 'rgba(30, 30, 30, 0.7)', // Translucent dark gray
  textPrimary: '#FFFFFF', // White
  textSecondary: '#A1A1A1', // Light gray
};

const SignUpScreen = () => {
  const { signUp } = useAuth();
  const navigation = useNavigation<SignUpScreenNavigationProp>();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [secureTextEntry, setSecureTextEntry] = useState(true);
  const [confirmSecureTextEntry, setConfirmSecureTextEntry] = useState(true);

  const handleSignUp = async () => {
    if (!email || !password || !confirmPassword) {
      alert('Please fill in all fields');
      return;
    }
    
    if (password !== confirmPassword) {
      alert('Passwords do not match');
      return;
    }
    
    if (password.length < 6) {
      alert('Password should be at least 6 characters long');
      return;
    }
    
    setLoading(true);
    await signUp(email, password);
    setLoading(false);
  };

  const navigateToLogin = () => {
    navigation.navigate('Login');
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      
      <LinearGradient
        colors={DARK_GRADIENT_COLORS}
        style={styles.background}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
      />
      
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardAvoidingView}
      >
        <ScrollView 
          contentContainerStyle={styles.scrollContent}
          keyboardShouldPersistTaps="handled"
        >
          <View style={styles.headerContainer}>
            <Text style={styles.appName}>MindfulMoments</Text>
            <Text style={styles.tagline}>Begin your mindfulness journey</Text>
          </View>
          
          <View style={styles.formContainer}>
            <Text style={styles.formTitle}>Create Account</Text>
            
            <TextInput
              label="Email"
              value={email}
              onChangeText={setEmail}
              style={styles.input}
              autoCapitalize="none"
              keyboardType="email-address"
              mode="outlined"
              outlineColor={COLORS.mediumGray}
              activeOutlineColor={COLORS.primary}
              textColor={COLORS.textPrimary}
              theme={{ colors: { onSurfaceVariant: COLORS.textSecondary } }}
            />
            
            <TextInput
              label="Password"
              value={password}
              onChangeText={setPassword}
              style={styles.input}
              secureTextEntry={true}
              mode="outlined"
              outlineColor={COLORS.mediumGray}
              activeOutlineColor={COLORS.primary}
              textColor={COLORS.textPrimary}
              theme={{ colors: { onSurfaceVariant: COLORS.textSecondary } }}
              textContentType="oneTimeCode"
              autoComplete="off"
              autoCapitalize="none"
            />
            
            <TextInput
              label="Confirm Password"
              value={confirmPassword}
              onChangeText={setConfirmPassword}
              style={styles.input}
              secureTextEntry={true}
              mode="outlined"
              outlineColor={COLORS.mediumGray}
              activeOutlineColor={COLORS.primary}
              textColor={COLORS.textPrimary}
              theme={{ colors: { onSurfaceVariant: COLORS.textSecondary } }}
              textContentType="oneTimeCode"
              autoComplete="off"
              autoCapitalize="none"
            />
            
            <Button 
              mode="contained"
              onPress={handleSignUp}
              loading={loading}
              disabled={loading}
              buttonColor={COLORS.primary}
              style={styles.signUpButton}
              contentStyle={styles.buttonContent}
              labelStyle={styles.buttonLabel}
            >
              Sign Up
            </Button>
            
            <View style={styles.loginContainer}>
              <Text style={styles.loginText}>Already have an account? </Text>
              <TouchableOpacity onPress={navigateToLogin}>
                <Text style={styles.loginLink}>Log In</Text>
              </TouchableOpacity>
            </View>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.dark,
  },
  background: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
  },
  keyboardAvoidingView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 40,
  },
  headerContainer: {
    alignItems: 'center',
    marginBottom: 50,
  },
  appName: {
    fontSize: 32,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
    marginBottom: 10,
  },
  tagline: {
    fontSize: 16,
    color: COLORS.textSecondary,
  },
  formContainer: {
    backgroundColor: COLORS.cardBg,
    borderRadius: 16,
    padding: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  formTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
    marginBottom: 24,
  },
  input: {
    marginBottom: 16,
    backgroundColor: 'rgba(30, 30, 30, 0.7)',
  },
  signUpButton: {
    marginTop: 8,
    marginBottom: 24,
    borderRadius: 8,
  },
  buttonContent: {
    height: 48,
  },
  buttonLabel: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  loginContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
  },
  loginText: {
    color: COLORS.textSecondary,
    fontSize: 14,
  },
  loginLink: {
    color: COLORS.primary,
    fontSize: 14,
    fontWeight: 'bold',
  },
});

export default SignUpScreen; 