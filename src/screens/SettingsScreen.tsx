import React, { useState, useEffect } from 'react';
import { 
  View, 
  StyleSheet, 
  ScrollView, 
  TouchableOpacity,
  Animated,
  SafeAreaView,
  StatusBar
} from 'react-native';
import { Text, Switch, Divider, Button, Surface, IconButton } from 'react-native-paper';
import { useNavigation, CommonActions } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { TabParamList, RootStackParamList } from '../types';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';

type SettingsNavigationProp = StackNavigationProp<TabParamList>;

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
  danger: '#FF4365', // Red for dangerous actions
};

// Dark theme gradient colors
const DARK_GRADIENT_COLORS = ['#0F0F0F', '#171717', '#1F1F1F', '#171717'] as const;

const SettingsScreen = () => {
  const navigation = useNavigation();
  
  // Animation states
  const [fadeAnim] = useState(new Animated.Value(0));
  const [slideAnim] = useState(new Animated.Value(30));
  const [cardAnimValues] = useState([
    new Animated.Value(0),
    new Animated.Value(0),
    new Animated.Value(0),
    new Animated.Value(0),
    new Animated.Value(0),
    new Animated.Value(0)
  ]);
  
  // State for settings
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [remindersEnabled, setRemindersEnabled] = useState(true);
  const [darkModeEnabled, setDarkModeEnabled] = useState(true);
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [vibrationEnabled, setVibrationEnabled] = useState(true);
  
  useEffect(() => {
    // Animate header elements
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 600,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 700,
        useNativeDriver: true,
      })
    ]).start();

    // Staggered animations for cards
    const animations = cardAnimValues.map((anim, index) => {
      return Animated.timing(anim, {
        toValue: 1,
        duration: 500,
        delay: index * 100,
        useNativeDriver: true,
      });
    });
    
    Animated.stagger(80, animations).start();
  }, []);

  const renderAnimatedCard = (index: number, children: React.ReactNode) => {
    const animValue = cardAnimValues[index];
    
    return (
      <Animated.View 
        style={{
          opacity: animValue,
          transform: [{
            translateY: animValue.interpolate({
              inputRange: [0, 1],
              outputRange: [30, 0],
            }),
          }],
          marginBottom: 16,
        }}
      >
        <Surface style={styles.card}>
          {children}
        </Surface>
      </Animated.View>
    );
  };
  
  // Navigate to Attribution screen (in the root stack)
  const navigateToAttribution = () => {
    navigation.dispatch(
      CommonActions.navigate({
        name: 'Attribution'
      })
    );
  };

  // Custom list item component with dark theme styling
  const SettingsItem = ({ 
    icon, 
    title, 
    description, 
    rightContent,
    onPress,
    iconColor = COLORS.primary
  }: {
    icon: keyof typeof Ionicons.glyphMap,
    title: string,
    description: string,
    rightContent?: React.ReactNode,
    onPress?: () => void,
    iconColor?: string
  }) => (
    <TouchableOpacity 
      style={styles.settingsItem} 
      onPress={onPress}
      disabled={!onPress}
      activeOpacity={onPress ? 0.7 : 1}
    >
      <View style={[styles.iconContainer, { backgroundColor: iconColor }]}>
        <Ionicons name={icon} size={22} color="white" />
      </View>
      <View style={styles.settingsContent}>
        <View style={styles.settingsTextContainer}>
          <Text style={styles.settingsTitle}>{title}</Text>
          <Text style={styles.settingsDescription}>{description}</Text>
        </View>
        {rightContent && (
          <View style={styles.settingsAction}>
            {rightContent}
          </View>
        )}
      </View>
    </TouchableOpacity>
  );
  
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      
      <LinearGradient
        colors={DARK_GRADIENT_COLORS}
        style={styles.background}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
      />
      
      <Animated.View 
        style={[
          styles.header,
          {
            opacity: fadeAnim,
            transform: [{ translateY: slideAnim }]
          }
        ]}
      >
        <Text style={styles.headerTitle}>Settings</Text>
        <Text style={styles.headerSubtitle}>Customize your meditation experience</Text>
      </Animated.View>
      
      <ScrollView 
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContentContainer}
      >
        {renderAnimatedCard(0, 
          <View>
            <Text style={styles.sectionTitle}>Notifications</Text>
            
            <SettingsItem
              icon="notifications-outline"
              title="Enable Notifications"
              description="Receive updates and reminders"
              rightContent={
                <Switch
                  value={notificationsEnabled}
                  onValueChange={setNotificationsEnabled}
                  color={COLORS.primary}
                />
              }
            />
            
            <Divider style={styles.divider} />
            
            <SettingsItem
              icon="time-outline"
              title="Daily Reminders"
              description="Get reminded of your scheduled sessions"
              rightContent={
                <Switch
                  value={remindersEnabled}
                  onValueChange={setRemindersEnabled}
                  color={COLORS.primary}
                  disabled={!notificationsEnabled}
                />
              }
            />
          </View>
        )}
        
        {renderAnimatedCard(1, 
          <View>
            <Text style={styles.sectionTitle}>Appearance</Text>
            
            <SettingsItem
              icon="moon-outline"
              title="Dark Mode"
              description="Use dark colors for the interface"
              rightContent={
                <Switch
                  value={darkModeEnabled}
                  onValueChange={setDarkModeEnabled}
                  color={COLORS.primary}
                />
              }
            />
          </View>
        )}
        
        {renderAnimatedCard(2, 
          <View>
            <Text style={styles.sectionTitle}>Session Settings</Text>
            
            <SettingsItem
              icon="musical-notes-outline"
              title="Background Sounds"
              description="Play ambient sounds during sessions"
              rightContent={
                <Switch
                  value={soundEnabled}
                  onValueChange={setSoundEnabled}
                  color={COLORS.primary}
                />
              }
            />
            
            <Divider style={styles.divider} />
            
            <SettingsItem
              icon="pulse-outline"
              title="Vibration Feedback"
              description="Haptic feedback for session events"
              rightContent={
                <Switch
                  value={vibrationEnabled}
                  onValueChange={setVibrationEnabled}
                  color={COLORS.primary}
                />
              }
            />
          </View>
        )}
        
        {renderAnimatedCard(3, 
          <View>
            <Text style={styles.sectionTitle}>Account</Text>
            
            <SettingsItem
              icon="person-outline"
              title="Personal Information"
              description="Manage your profile details"
              onPress={() => {}}
            />
            
            <Divider style={styles.divider} />
            
            <SettingsItem
              icon="star-outline"
              title="Subscription"
              description="Manage your current plan"
              iconColor={COLORS.secondary}
              onPress={() => {}}
            />
            
            <Divider style={styles.divider} />
            
            <SettingsItem
              icon="shield-outline"
              title="Privacy Policy"
              description="Read our privacy policy"
              onPress={() => {}}
            />
            
            <Divider style={styles.divider} />
            
            <SettingsItem
              icon="document-text-outline"
              title="Terms of Service"
              description="Read our terms of service"
              onPress={() => {}}
            />
          </View>
        )}
        
        {renderAnimatedCard(4, 
          <View>
            <Text style={styles.sectionTitle}>About</Text>
            
            <SettingsItem
              icon="information-circle-outline"
              title="Credits & Attribution"
              description="Meditation content sources and licenses"
              iconColor={COLORS.secondary}
              onPress={navigateToAttribution}
            />
            
            <Divider style={styles.divider} />
            
            <SettingsItem
              icon="phone-portrait-outline"
              title="App Version"
              description="1.0.0"
            />
          </View>
        )}
        
        {renderAnimatedCard(5, 
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
        )}
        
        <View style={styles.bottomPadding} />
      </ScrollView>
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
  header: {
    paddingHorizontal: 24,
    paddingTop: 16,
    paddingBottom: 8,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  headerSubtitle: {
    fontSize: 16,
    color: COLORS.textSecondary,
    marginTop: 4,
  },
  scrollView: {
    flex: 1,
  },
  scrollContentContainer: {
    paddingHorizontal: 24,
    paddingBottom: 40,
  },
  card: {
    borderRadius: 16,
    backgroundColor: COLORS.cardBg,
    overflow: 'hidden',
    elevation: 8,
    shadowColor: 'black',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    padding: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
    marginBottom: 16,
  },
  settingsItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  iconContainer: {
    width: 42,
    height: 42,
    borderRadius: 21,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  settingsContent: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingBottom: 8,
  },
  settingsTextContainer: {
    flex: 1,
    paddingRight: 16,
  },
  settingsTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: COLORS.textPrimary,
  },
  settingsDescription: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginTop: 2,
  },
  settingsAction: {
    justifyContent: 'center',
  },
  divider: {
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    marginVertical: 12,
  },
  buttonContainer: {
    marginTop: 8,
  },
  button: {
    borderRadius: 30,
    borderColor: COLORS.danger,
    borderWidth: 2,
    height: 50,
    justifyContent: 'center',
  },
  buttonLabel: {
    color: COLORS.danger,
    fontSize: 16,
    fontWeight: 'bold',
  },
  bottomPadding: {
    height: 30,
  },
});

export default SettingsScreen; 