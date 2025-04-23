import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ActivityIndicator } from 'react-native';
import { NavigationContainer, DefaultTheme as NavigationDefaultTheme } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { StatusBar } from 'expo-status-bar';
import { RootStackParamList, TabParamList, AppStackParamList, HomeStackParamList, UserProfile, AuthStackParamList } from '../types';
import HomeScreen from '../screens/HomeScreen';
import MeditationDetailScreen from '../screens/MeditationDetailScreen';
import MeditationPlayerScreen from '../screens/MeditationPlayerScreen';
import CategoryMeditationsScreen from '../screens/CategoryMeditationsScreen';
import ProfileScreen from '../screens/ProfileScreen';
import StatsScreen from '../screens/StatsScreen';
import SettingsScreen from '../screens/SettingsScreen';
import AttributionScreen from '../screens/AttributionScreen';
import LoginScreen from '../screens/LoginScreen';
import SignUpScreen from '../screens/SignUpScreen';
import ForgotPasswordScreen from '../screens/ForgotPasswordScreen';
import ProfileSetupScreen from '../screens/ProfileSetupScreen';
import { useAuth } from '../contexts/AuthContext';
import { getCurrentProfile } from '../services/api';
import theme from '../theme';
import { IconButton } from 'react-native-paper';
import { LinearGradient } from 'expo-linear-gradient';

// Gradient colors for dark theme with purple accents
const DARK_GRADIENT_COLORS = ['#0F0F0F', '#171717', '#1F1F1F'] as const;
const PURPLE_ACCENT_GRADIENT = ['#6633CC', '#7928CA', '#9D50BB'] as const;

// Create navigation theme
const NavigationTheme = {
  ...NavigationDefaultTheme,
  dark: true,
  colors: {
    ...NavigationDefaultTheme.colors,
    primary: theme.palette.primary,
    background: theme.palette.background,
    card: theme.palette.darkGray,
    text: theme.palette.textPrimary,
    border: 'rgba(40, 40, 40, 0.8)',
    notification: theme.palette.secondary,
  }
};

// Create a custom header background
const DarkGradientHeader = () => (
  <LinearGradient
    colors={DARK_GRADIENT_COLORS}
    style={StyleSheet.absoluteFill}
    start={{ x: 0.5, y: 0 }}
    end={{ x: 0.5, y: 1 }}
  />
);

const RootStack = createStackNavigator<RootStackParamList>();
const AppStackNav = createStackNavigator<AppStackParamList>();
const AuthStackNav = createStackNavigator<AuthStackParamList>();
const Tab = createBottomTabNavigator<TabParamList>();
const HomeStackNav = createStackNavigator<HomeStackParamList>();

const HomeStack = () => {
  return (
    <HomeStackNav.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <HomeStackNav.Screen 
        name="Home" 
        component={HomeScreen} 
      />
    </HomeStackNav.Navigator>
  );
};

const TabNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: string = 'home';

          if (route.name === 'HomeTab') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'ProfileTab') {
            iconName = focused ? 'account-circle' : 'account-circle-outline';
          } else if (route.name === 'StatsTab') {
            iconName = focused ? 'chart-timeline-variant' : 'chart-timeline-variant-shimmer';
          } else if (route.name === 'SettingsTab') {
            iconName = focused ? 'cog' : 'cog-outline';
          }

          // Return the icon with more space around it
          return (
            <View style={{ 
              alignItems: 'center', 
              justifyContent: 'center', 
              paddingTop: 6
            }}>
              <IconButton 
                icon={iconName} 
                size={24} 
                iconColor={color} 
              />
            </View>
          );
        },
        tabBarActiveTintColor: theme.palette.primary,
        tabBarInactiveTintColor: theme.palette.textSecondary,
        tabBarStyle: {
          elevation: 0,
          shadowOpacity: 0,
          borderTopWidth: 0,
          backgroundColor: 'rgba(18, 18, 18, 0.95)',
          borderTopColor: 'rgba(40, 40, 40, 0.8)',
          height: 85, // Increased height further
          paddingBottom: 20, // Significantly more bottom padding
          paddingTop: 5, // Added top padding
        },
        tabBarLabelStyle: {
          fontSize: 12, // Slightly larger font
          fontWeight: '600',
          marginTop: 2, // Adjust to position below the icon
          marginBottom: 6, // Added bottom margin
        },
        headerShown: false,
        tabBarShowLabel: true, // Ensure labels are shown
        tabBarItemStyle: {
          paddingVertical: 5, // Add vertical padding inside each tab item
        },
        // Remove any title from the header that might say "MARC"
        title: '', 
      })}
    >
      <Tab.Screen 
        name="HomeTab" 
        component={HomeStack}
        options={{ 
          title: 'Home'
        }}
      />
      <Tab.Screen 
        name="ProfileTab" 
        component={ProfileScreen}
        options={{ 
          title: 'Profile',
        }}
      />
      <Tab.Screen 
        name="StatsTab" 
        component={StatsScreen}
        options={{ 
          title: 'Stats',
        }}
      />
      <Tab.Screen 
        name="SettingsTab" 
        component={SettingsScreen}
        options={{ 
          title: 'Settings',
        }}
      />
    </Tab.Navigator>
  );
};

const AppStack = () => {
  return (
    <AppStackNav.Navigator
      screenOptions={{
        headerBackground: () => <DarkGradientHeader />,
        headerTintColor: '#FFFFFF',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
        headerShadowVisible: false,
        title: '', // Set an empty title by default
        headerTitle: '', // Ensure no header title is shown
      }}
    >
      <AppStackNav.Screen 
        name="Main" 
        component={TabNavigator} 
        options={{ 
          headerShown: false,
          title: '',
        }} 
      />
      <AppStackNav.Screen 
        name="MeditationDetail" 
        component={MeditationDetailScreen}
        options={{ headerShown: false }}
      />
      <AppStackNav.Screen 
        name="MeditationPlayer" 
        component={MeditationPlayerScreen}
        options={{ headerShown: false }}
      />
      <AppStackNav.Screen 
        name="CategoryMeditations" 
        component={CategoryMeditationsScreen}
        options={{ headerShown: false }}
      />
      <AppStackNav.Screen 
        name="Attribution" 
        component={AttributionScreen}
        options={{ title: 'Credits & Attribution' }}
      />
    </AppStackNav.Navigator>
  );
};

const AuthStack = () => {
  return (
    <AuthStackNav.Navigator
      screenOptions={{
        headerShown: false,
        cardStyle: { backgroundColor: theme.palette.background }
      }}
    >
      <AuthStackNav.Screen name="Login" component={LoginScreen} />
      <AuthStackNav.Screen name="SignUp" component={SignUpScreen} />
      <AuthStackNav.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
    </AuthStackNav.Navigator>
  );
};

const LoadingScreen = () => (
  <View style={styles.loadingContainer}>
    <LinearGradient
      colors={DARK_GRADIENT_COLORS}
      style={StyleSheet.absoluteFill}
    />
    <ActivityIndicator size="large" color={theme.palette.primary} />
  </View>
);

const RootNavigator = () => {
  const { user, loading: authLoading, profile, loadingProfile } = useAuth();

  console.log('[RootNavigator] Render - User:', !!user, 'AuthLoading:', authLoading, 'ProfileLoading:', loadingProfile);
  console.log('[RootNavigator] Render - Profile:', profile);

  if (authLoading || (user && loadingProfile)) { 
    console.log('[RootNavigator] Rendering LoadingScreen');
    return <LoadingScreen />;
  }

  const needsProfileSetup = user && !profile?.full_name; 
  console.log('[RootNavigator] Needs Profile Setup:', needsProfileSetup);

  // Determine which screen to render
  let screenToRender;
  if (user) {
    if (needsProfileSetup) {
      console.log('[RootNavigator] Determining to render ProfileSetupScreen');
      screenToRender = <RootStack.Screen name="ProfileSetup" component={ProfileSetupScreen} />;
    } else {
      console.log('[RootNavigator] Determining to render AppStack');
      screenToRender = <RootStack.Screen name="App" component={AppStack} />;
    }
  } else {
    console.log('[RootNavigator] Determining to render AuthStack');
    screenToRender = <RootStack.Screen name="Auth" component={AuthStack} />;
  }

  return (
    <RootStack.Navigator screenOptions={{ 
      headerShown: false,
      title: '',
      headerTitle: '',
    }}>
      {screenToRender} 
    </RootStack.Navigator>
  );
};

const AppNavigator = () => {
  return (
    <NavigationContainer theme={NavigationTheme}>
      <StatusBar style="light" />
      <RootNavigator />
    </NavigationContainer>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default AppNavigator; 