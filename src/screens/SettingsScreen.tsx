import React, { useState } from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { List, Switch, Text, Divider, Button, useTheme, Card } from 'react-native-paper';
import { useNavigation, CommonActions } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { TabParamList, RootStackParamList } from '../types';

type SettingsNavigationProp = StackNavigationProp<TabParamList>;

const SettingsScreen = () => {
  const theme = useTheme();
  const navigation = useNavigation();
  
  // State for settings
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [remindersEnabled, setRemindersEnabled] = useState(true);
  const [darkModeEnabled, setDarkModeEnabled] = useState(false);
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [vibrationEnabled, setVibrationEnabled] = useState(true);
  
  // Navigate to Attribution screen (in the root stack)
  const navigateToAttribution = () => {
    navigation.dispatch(
      CommonActions.navigate({
        name: 'Attribution'
      })
    );
  };
  
  return (
    <ScrollView style={styles.container}>
      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.sectionTitle}>Notifications</Text>
          
          <List.Item
            title="Enable Notifications"
            description="Receive updates and reminders"
            left={props => <List.Icon {...props} icon="bell" color={theme.colors.primary} />}
            right={() => (
              <Switch
                value={notificationsEnabled}
                onValueChange={setNotificationsEnabled}
                color={theme.colors.primary}
              />
            )}
          />
          
          <Divider style={styles.divider} />
          
          <List.Item
            title="Daily Reminders"
            description="Get reminded of your scheduled sessions"
            left={props => <List.Icon {...props} icon="clock-alert" color={theme.colors.primary} />}
            right={() => (
              <Switch
                value={remindersEnabled}
                onValueChange={setRemindersEnabled}
                color={theme.colors.primary}
                disabled={!notificationsEnabled}
              />
            )}
          />
        </Card.Content>
      </Card>
      
      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.sectionTitle}>Appearance</Text>
          
          <List.Item
            title="Dark Mode"
            description="Use dark colors for the interface"
            left={props => <List.Icon {...props} icon="moon-waning-crescent" color={theme.colors.primary} />}
            right={() => (
              <Switch
                value={darkModeEnabled}
                onValueChange={setDarkModeEnabled}
                color={theme.colors.primary}
              />
            )}
          />
        </Card.Content>
      </Card>
      
      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.sectionTitle}>Session Settings</Text>
          
          <List.Item
            title="Background Sounds"
            description="Play ambient sounds during sessions"
            left={props => <List.Icon {...props} icon="music-note" color={theme.colors.primary} />}
            right={() => (
              <Switch
                value={soundEnabled}
                onValueChange={setSoundEnabled}
                color={theme.colors.primary}
              />
            )}
          />
          
          <Divider style={styles.divider} />
          
          <List.Item
            title="Vibration Feedback"
            description="Haptic feedback for session events"
            left={props => <List.Icon {...props} icon="vibrate" color={theme.colors.primary} />}
            right={() => (
              <Switch
                value={vibrationEnabled}
                onValueChange={setVibrationEnabled}
                color={theme.colors.primary}
              />
            )}
          />
        </Card.Content>
      </Card>
      
      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.sectionTitle}>Account</Text>
          
          <List.Item
            title="Personal Information"
            description="Manage your profile details"
            left={props => <List.Icon {...props} icon="account" color={theme.colors.primary} />}
            onPress={() => {}}
          />
          
          <Divider style={styles.divider} />
          
          <List.Item
            title="Subscription"
            description="Manage your current plan"
            left={props => <List.Icon {...props} icon="star" color={theme.colors.primary} />}
            onPress={() => {}}
          />
          
          <Divider style={styles.divider} />
          
          <List.Item
            title="Privacy Policy"
            description="Read our privacy policy"
            left={props => <List.Icon {...props} icon="shield-lock" color={theme.colors.primary} />}
            onPress={() => {}}
          />
          
          <Divider style={styles.divider} />
          
          <List.Item
            title="Terms of Service"
            description="Read our terms of service"
            left={props => <List.Icon {...props} icon="file-document" color={theme.colors.primary} />}
            onPress={() => {}}
          />
        </Card.Content>
      </Card>
      
      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.sectionTitle}>About</Text>
          
          <List.Item
            title="Credits & Attribution"
            description="Meditation content sources and licenses"
            left={props => <List.Icon {...props} icon="information" color={theme.colors.primary} />}
            onPress={navigateToAttribution}
          />
          
          <Divider style={styles.divider} />
          
          <List.Item
            title="App Version"
            description="1.0.0"
            left={props => <List.Icon {...props} icon="cellphone" color={theme.colors.primary} />}
          />
        </Card.Content>
      </Card>
      
      <View style={styles.buttonContainer}>
        <Button
          mode="outlined"
          onPress={() => {}}
          style={styles.button}
          labelStyle={styles.buttonLabel}
        >
          Sign Out
        </Button>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FE',
  },
  card: {
    margin: 16,
    marginBottom: 8,
    borderRadius: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  divider: {
    marginVertical: 8,
  },
  buttonContainer: {
    padding: 16,
    paddingBottom: 40,
  },
  button: {
    borderRadius: 8,
    borderColor: '#F44336',
  },
  buttonLabel: {
    color: '#F44336',
  },
});

export default SettingsScreen; 