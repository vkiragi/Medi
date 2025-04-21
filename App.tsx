import React, { useEffect } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Provider as PaperProvider } from 'react-native-paper';
import AppNavigator from './src/navigation/AppNavigator';
import theme from './src/theme';
import { AuthProvider } from './src/contexts/AuthContext';
import { testSupabaseConnection } from './src/lib/supabase';

export default function App() {
  useEffect(() => {
    // Test Supabase connectivity
    const testConnection = async () => {
      try {
        const connected = await testSupabaseConnection();
        console.log('Supabase connection test result:', connected);
      } catch (error) {
        console.error('Connection test error:', error);
      }
    };
    
    testConnection();
  }, []);

  return (
    <SafeAreaProvider>
      <PaperProvider theme={theme}>
        <AuthProvider>
          <AppNavigator />
        </AuthProvider>
      </PaperProvider>
    </SafeAreaProvider>
  );
}
