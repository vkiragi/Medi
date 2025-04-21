import React from 'react';
import { View, StyleSheet, ActivityIndicator } from 'react-native';
import { NavigationContainer, DefaultTheme as NavigationDefaultTheme } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { StatusBar } from 'expo-status-bar';
import { RootStackParamList, TabParamList } from '../types';
import HomeScreen from '../screens/HomeScreen';
import MeditationDetailScreen from '../screens/MeditationDetailScreen';
import MeditationPlayerScreen from '../screens/MeditationPlayerScreen';
import ProfileScreen from '../screens/ProfileScreen';
import StatsScreen from '../screens/StatsScreen';
import SettingsScreen from '../screens/SettingsScreen';
import AttributionScreen from '../screens/AttributionScreen';
import LoginScreen from '../screens/LoginScreen';
import SignUpScreen from '../screens/SignUpScreen';
import ForgotPasswordScreen from '../screens/ForgotPasswordScreen';
import { useAuth } from '../contexts/AuthContext';
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

const Stack = createStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<TabParamList>();

const HomeStack = () => {
  return (
    <Stack.Navigator
      screenOptions={{
        headerBackground: () => <DarkGradientHeader />,
        headerTintColor: '#FFFFFF',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
        headerShadowVisible: false,
      }}
    >
      <Stack.Screen 
        name="Home" 
        component={HomeScreen} 
        options={{ title: 'Meditation App', headerShown: false }} 
      />
      <Stack.Screen 
        name="MeditationDetail" 
        component={MeditationDetailScreen}
        options={{ headerShown: false }}
      />
      <Stack.Screen 
        name="MeditationPlayer" 
        component={MeditationPlayerScreen}
        options={{ headerShown: false }}
      />
    </Stack.Navigator>
  );
};

const TabNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: string = 'home';

          if (route.name === 'HomeTab') {
            iconName = 'home';
          } else if (route.name === 'ProfileTab') {
            iconName = 'account';
          } else if (route.name === 'StatsTab') {
            iconName = 'chart-bar';
          } else if (route.name === 'SettingsTab') {
            iconName = 'cog';
          }

          return <IconButton icon={iconName} size={size} iconColor={color} />;
        },
        tabBarActiveTintColor: theme.palette.primary,
        tabBarInactiveTintColor: theme.palette.textSecondary,
        tabBarStyle: {
          elevation: 0,
          shadowOpacity: 0,
          borderTopWidth: 0,
          backgroundColor: 'rgba(18, 18, 18, 0.95)',
          borderTopColor: 'rgba(40, 40, 40, 0.8)',
        },
        headerShown: false,
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
          headerShown: true,
          headerBackground: () => <DarkGradientHeader />,
          headerTintColor: '#FFFFFF',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
          headerShadowVisible: false,
        }}
      />
      <Tab.Screen 
        name="StatsTab" 
        component={StatsScreen}
        options={{ 
          title: 'Stats',
          headerShown: true,
          headerBackground: () => <DarkGradientHeader />,
          headerTintColor: '#FFFFFF',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
          headerShadowVisible: false,
        }}
      />
      <Tab.Screen 
        name="SettingsTab" 
        component={SettingsScreen}
        options={{ 
          title: 'Settings',
          headerShown: true,
          headerBackground: () => <DarkGradientHeader />,
          headerTintColor: '#FFFFFF',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
          headerShadowVisible: false,
        }}
      />
    </Tab.Navigator>
  );
};

// Main app stack after authentication
const AppStack = () => {
  return (
    <Stack.Navigator
      screenOptions={{
        headerBackground: () => <DarkGradientHeader />,
        headerTintColor: '#FFFFFF',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
        headerShadowVisible: false,
      }}
    >
      <Stack.Screen 
        name="Main" 
        component={TabNavigator} 
        options={{ headerShown: false }} 
      />
      <Stack.Screen 
        name="Attribution" 
        component={AttributionScreen}
        options={{ title: 'Credits & Attribution' }}
      />
    </Stack.Navigator>
  );
};

// Authentication stack before login
const AuthStack = () => {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        cardStyle: { backgroundColor: theme.palette.background }
      }}
    >
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="SignUp" component={SignUpScreen} />
      <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
    </Stack.Navigator>
  );
};

// Main navigator that handles auth state
const RootNavigator = () => {
  const { user, loading } = useAuth();
  
  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <LinearGradient
          colors={DARK_GRADIENT_COLORS}
          style={StyleSheet.absoluteFill}
        />
        <ActivityIndicator size="large" color={theme.palette.primary} />
      </View>
    );
  }
  
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      {user ? (
        <Stack.Screen name="App" component={AppStack} />
      ) : (
        <Stack.Screen name="Auth" component={AuthStack} />
      )}
    </Stack.Navigator>
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