import React, { useState, useEffect } from 'react';
import { 
  StyleSheet, 
  View, 
  TouchableOpacity, 
  Animated, 
  Dimensions,
  StatusBar,
  SafeAreaView,
  TextInput,
  ScrollView
} from 'react-native';
import { Text, Surface, useTheme, Avatar, IconButton } from 'react-native-paper';
import { useNavigation, CommonActions } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { AppStackParamList, MeditationSession } from '../types';
import { meditationSessions } from '../data/meditations';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import appTheme from '../theme';
import { useAuth } from '../contexts/AuthContext';

type HomeScreenNavigationProp = StackNavigationProp<AppStackParamList>;

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

// Define type for category
type Category = {
  id: string;
  name: string;
  icon: keyof typeof Ionicons.glyphMap;
  color: string;
};

// Category data with updated colors
const categories: Category[] = [
  { id: '1', name: 'Meditate', icon: 'triangle-outline', color: '#7928CA' },
  { id: '2', name: 'Sleep', icon: 'moon-outline', color: '#FF0080' },
  { id: '3', name: 'Breath', icon: 'water-outline', color: '#7928CA' },
  { id: '4', name: 'Affirmate', icon: 'heart-outline', color: '#FF0080' },
];

// Dark theme gradient colors
const DARK_GRADIENT_COLORS = ['#0F0F0F', '#171717', '#1F1F1F', '#171717'] as const;
const PURPLE_ACCENT_GRADIENT = ['#6633CC', '#7928CA', '#9D50BB'] as const;
const GLOW_GRADIENT = ['#7928CA', '#FF0080'] as const;

// Get time of day greeting
const getGreeting = () => {
  const hour = new Date().getHours();
  if (hour < 12) return 'Morning';
  if (hour < 18) return 'Afternoon';
  return 'Evening';
};

const { width } = Dimensions.get('window');
const cardWidth = (width - 64) / 2; // Two cards per row with padding

const HomeScreen = () => {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const theme = useTheme();
  const [greeting] = useState(getGreeting());
  const [animatedValues] = useState(() => 
    categories.map(() => new Animated.Value(0))
  );
  const { user, profile } = useAuth();
  const [username, setUsername] = useState<string>('Friend');

  // Set username from profile full_name when available, fallback to email
  useEffect(() => {
    if (profile?.full_name) {
      // Extract first name only
      const firstName = profile.full_name.split(' ')[0];
      setUsername(firstName);
    } else if (user && user.email) {
      // Fallback to email username
      const emailName = user.email.split('@')[0];
      const capitalized = emailName.charAt(0).toUpperCase() + emailName.slice(1);
      setUsername(capitalized);
    } else {
      setUsername('Friend');
    }
  }, [user, profile]);

  // Start animations when component mounts
  useEffect(() => {
    const animations = animatedValues.map((anim, index) => {
      return Animated.timing(anim, {
        toValue: 1,
        duration: 500,
        delay: index * 100,
        useNativeDriver: true,
      });
    });
    
    Animated.stagger(100, animations).start();
  }, []);

  const renderCategoryCard = (category: typeof categories[0], index: number) => {
    // Use the pre-created animated value
    const fadeAnim = animatedValues[index];
    
    return (
      <Animated.View 
        key={category.id}
        style={{
          opacity: fadeAnim,
          transform: [{
            translateY: fadeAnim.interpolate({
              inputRange: [0, 1],
              outputRange: [30, 0],
            }),
          }],
        }}
      >
        <TouchableOpacity
          onPress={() => {
            // Navigate to the category meditations screen instead of individual meditation
            navigation.navigate('CategoryMeditations', {
              categoryName: category.name,
              categoryColor: category.color
            });
          }}
          activeOpacity={0.8}
        >
          <Surface style={styles.categoryCard}>
            <View style={styles.cardIconContainer}>
              <Ionicons name={category.icon} size={32} color={category.color} />
            </View>
            <Text style={styles.categoryName}>{category.name}</Text>
            
            <View style={[styles.playButton, { backgroundColor: category.color }]}>
              <Ionicons name="play" size={18} color="white" />
            </View>
          </Surface>
        </TouchableOpacity>
      </Animated.View>
    );
  };

  const navigateToAttribution = () => {
    navigation.navigate('Attribution');
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
      
      <ScrollView 
        style={styles.scrollContainer}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContentContainer}
      >
        <View style={styles.header}>
          <View>
            <View style={styles.greetingRow}>
              <Text style={styles.greeting}>{greeting}, {username}! </Text>
              <Text style={styles.emoji}>👋</Text>
            </View>
            <Text style={styles.subtitle}>Start your mindfulness journey</Text>
          </View>
        </View>

        <View style={styles.searchContainer}>
          <Ionicons name="search-outline" size={22} color="#A1A1A1" style={styles.searchIcon} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search meditations..."
            placeholderTextColor="#777777"
          />
        </View>

        <View style={styles.categoryGrid}>
          {categories.map((category, index) => renderCategoryCard(category, index))}
        </View>

        <View style={styles.recentSessionsHeader}>
          <Text style={styles.sectionTitle}>Recent Sessions</Text>
          <TouchableOpacity>
            <Text style={styles.seeAllText}>See All</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.recentSessionsContainer}>
          {meditationSessions.slice(0, 2).map((session) => (
            <TouchableOpacity 
              key={session.id}
              style={styles.recentSessionCard}
              onPress={() => navigation.navigate('MeditationDetail', { meditation: session })}
            >
              <View style={styles.sessionCardContent}>
                <View style={styles.sessionIconContainer}>
                  <Ionicons 
                    name="water-outline"
                    size={22} 
                    color="white" 
                  />
                </View>
                <View style={styles.sessionInfo}>
                  <Text style={styles.sessionName}>{session.name}</Text>
                  <Text style={styles.sessionDuration}>{session.duration} minutes</Text>
                </View>
              </View>
              <IconButton
                icon="play"
                size={20}
                iconColor="white"
                style={styles.sessionPlayButton}
                onPress={(e) => {
                  e.stopPropagation();
                  navigation.navigate('MeditationPlayer', { meditation: session });
                }}
              />
            </TouchableOpacity>
          ))}
        </View>
        
        {/* Add padding at the bottom for better scrolling */}
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
  scrollContainer: {
    flex: 1,
  },
  scrollContentContainer: {
    paddingBottom: 40,
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
    paddingTop: 20,
    paddingBottom: 20,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  greetingRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  greeting: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  emoji: {
    fontSize: 24,
  },
  subtitle: {
    fontSize: 18,
    color: COLORS.textSecondary,
    marginTop: 5,
    fontWeight: '500',
  },
  infoButton: {
    backgroundColor: 'rgba(50, 50, 50, 0.4)',
  },
  searchContainer: {
    marginHorizontal: 24,
    marginTop: 16,
    backgroundColor: 'rgba(40, 40, 40, 0.8)',
    borderRadius: 30,
    height: 50,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
  },
  searchIcon: {
    marginRight: 10,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: COLORS.textPrimary,
  },
  categoryGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginTop: 30,
    paddingHorizontal: 24,
    marginBottom: 10,
  },
  categoryCard: {
    width: cardWidth,
    height: cardWidth * 0.9,
    borderRadius: 18,
    padding: 20,
    marginBottom: 20,
    backgroundColor: COLORS.cardBg,
    elevation: 25,
    shadowColor: 'rgba(0, 0, 0, 0.5)',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.5,
    shadowRadius: 20,
    justifyContent: 'space-between',
  },
  cardIconContainer: {
    width: 46,
    height: 46,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(40, 40, 40, 0.8)',
  },
  categoryName: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginTop: 20,
    marginBottom: 10,
  },
  playButton: {
    position: 'absolute',
    bottom: 20,
    right: 20,
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recentSessionsHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    marginTop: 24,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  seeAllText: {
    fontSize: 14,
    color: COLORS.secondary,
    fontWeight: '600',
    paddingVertical: 4,
    paddingHorizontal: 8,
  },
  recentSessionsContainer: {
    paddingHorizontal: 24,
  },
  recentSessionCard: {
    height: 80,
    backgroundColor: COLORS.cardBg,
    borderRadius: 16,
    marginBottom: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingLeft: 16,
    paddingRight: 8,
    elevation: 25,
    shadowColor: 'rgba(0, 0, 0, 0.5)',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.5,
    shadowRadius: 20,
  },
  sessionCardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  sessionIconContainer: {
    width: 46,
    height: 46,
    borderRadius: 23,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  sessionInfo: {
    marginLeft: 20,
    flex: 1,
    paddingRight: 16,
  },
  sessionName: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: 4,
  },
  sessionDuration: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  sessionPlayButton: {
    backgroundColor: COLORS.primary,
    margin: 0,
    width: 50,
    height: 50,
    borderRadius: 25,
  },
  bottomPadding: {
    height: 30,
  },
});

export default HomeScreen; 