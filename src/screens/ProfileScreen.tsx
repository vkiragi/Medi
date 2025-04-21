import React, { useState, useEffect } from 'react';
import { 
  View, 
  StyleSheet, 
  ScrollView, 
  Animated, 
  Dimensions, 
  SafeAreaView,
  StatusBar
} from 'react-native';
import { Text, Avatar, Card, List, Button, Surface, IconButton } from 'react-native-paper';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';

const { width } = Dimensions.get('window');

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

// Dark theme gradient colors
const DARK_GRADIENT_COLORS = ['#0F0F0F', '#171717', '#1F1F1F', '#171717'] as const;
const PURPLE_ACCENT_GRADIENT = ['#6633CC', '#7928CA', '#9D50BB'] as const;

const ProfileScreen = () => {
  const [fadeAnim] = useState(new Animated.Value(0));
  const [slideAnim] = useState(new Animated.Value(30));
  const [cardAnimValues] = useState([
    new Animated.Value(0),
    new Animated.Value(0),
    new Animated.Value(0)
  ]);
  
  useEffect(() => {
    // Animate header elements
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 800,
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
    
    Animated.stagger(100, animations).start();
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
        style={styles.scrollView} 
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContentContainer}
      >
        <Animated.View 
          style={[
            styles.profileHeader,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }]
            }
          ]}
        >
          <Avatar.Image
            size={90}
            source={{ uri: 'https://randomuser.me/api/portraits/women/44.jpg' }}
            style={styles.avatar}
          />
          <Text style={styles.name}>Sarah Johnson</Text>
          <Text style={styles.subtitle}>Meditation Enthusiast</Text>
        </Animated.View>
        
        <Animated.View
          style={[
            styles.statsContainer,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }]
            }
          ]}
        >
          <Surface style={styles.statsCard}>
            <View style={styles.statsRow}>
              <View style={styles.statItem}>
                <Text style={styles.statNumber}>42</Text>
                <Text style={styles.statLabel}>Sessions</Text>
              </View>
              <View style={styles.statSeparator} />
              <View style={styles.statItem}>
                <Text style={styles.statNumber}>8</Text>
                <Text style={styles.statLabel}>Streak</Text>
              </View>
              <View style={styles.statSeparator} />
              <View style={styles.statItem}>
                <Text style={styles.statNumber}>320</Text>
                <Text style={styles.statLabel}>Minutes</Text>
              </View>
            </View>
          </Surface>
        </Animated.View>

        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Favorite Meditations</Text>
        </View>

        {renderAnimatedCard(0, 
          <View>
            <View style={styles.favoriteItem}>
              <View style={[styles.favoriteIcon, { backgroundColor: COLORS.primary }]}>
                <Ionicons name="leaf-outline" size={22} color="white" />
              </View>
              <View style={styles.favoriteInfo}>
                <Text style={styles.favoriteTitle}>Morning Calm</Text>
                <Text style={styles.favoriteSubtitle}>10 minutes • Unguided</Text>
              </View>
              <IconButton
                icon="star"
                size={20}
                iconColor="#FFC107"
                style={styles.favoriteAction}
              />
            </View>

            <View style={styles.favoriteItem}>
              <View style={[styles.favoriteIcon, { backgroundColor: COLORS.secondary }]}>
                <Ionicons name="moon-outline" size={22} color="white" />
              </View>
              <View style={styles.favoriteInfo}>
                <Text style={styles.favoriteTitle}>Deep Sleep</Text>
                <Text style={styles.favoriteSubtitle}>30 minutes • Sleep</Text>
              </View>
              <IconButton
                icon="star"
                size={20}
                iconColor="#FFC107"
                style={styles.favoriteAction}
              />
            </View>

            <View style={styles.favoriteItem}>
              <View style={[styles.favoriteIcon, { backgroundColor: COLORS.primary }]}>
                <Ionicons name="compass-outline" size={22} color="white" />
              </View>
              <View style={styles.favoriteInfo}>
                <Text style={styles.favoriteTitle}>Stress Relief</Text>
                <Text style={styles.favoriteSubtitle}>15 minutes • Guided</Text>
              </View>
              <IconButton
                icon="star"
                size={20}
                iconColor="#FFC107"
                style={styles.favoriteAction}
              />
            </View>
          </View>
        )}

        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Progress Goals</Text>
        </View>

        {renderAnimatedCard(1, 
          <View>
            <View style={styles.goalItem}>
              <View style={styles.goalHeader}>
                <View style={[styles.goalIcon, { backgroundColor: COLORS.primary }]}>
                  <Ionicons name="checkmark-circle-outline" size={22} color="white" />
                </View>
                <Text style={styles.goalTitle}>Meditate 5 times per week</Text>
              </View>
              <View style={styles.progressContainer}>
                <View style={styles.progressBackground}>
                  <View style={[styles.progressFill, { width: '60%', backgroundColor: COLORS.primary }]} />
                </View>
                <Text style={styles.progressText}>3/5 completed</Text>
              </View>
            </View>
            
            <View style={styles.goalItem}>
              <View style={styles.goalHeader}>
                <View style={[styles.goalIcon, { backgroundColor: COLORS.secondary }]}>
                  <Ionicons name="checkmark-circle-outline" size={22} color="white" />
                </View>
                <Text style={styles.goalTitle}>Complete 10 sleep sessions</Text>
              </View>
              <View style={styles.progressContainer}>
                <View style={styles.progressBackground}>
                  <View style={[styles.progressFill, { width: '70%', backgroundColor: COLORS.secondary }]} />
                </View>
                <Text style={styles.progressText}>7/10 completed</Text>
              </View>
            </View>
            
            <View style={styles.goalItem}>
              <View style={styles.goalHeader}>
                <View style={[styles.goalIcon, { backgroundColor: COLORS.primary }]}>
                  <Ionicons name="checkmark-circle-outline" size={22} color="white" />
                </View>
                <Text style={styles.goalTitle}>Reach 10-day streak</Text>
              </View>
              <View style={styles.progressContainer}>
                <View style={styles.progressBackground}>
                  <View style={[styles.progressFill, { width: '80%', backgroundColor: COLORS.primary }]} />
                </View>
                <Text style={styles.progressText}>8/10 days</Text>
              </View>
            </View>
          </View>
        )}
        
        {renderAnimatedCard(2,
          <View style={styles.buttonContainer}>
            <Button
              mode="contained"
              onPress={() => {}}
              style={styles.editButton}
              contentStyle={styles.buttonContent}
              labelStyle={styles.buttonLabel}
            >
              Edit Profile
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
  scrollView: {
    flex: 1,
  },
  scrollContentContainer: {
    paddingBottom: 40,
  },
  profileHeader: {
    alignItems: 'center',
    paddingVertical: 24,
  },
  avatar: {
    marginBottom: 16,
    borderWidth: 3,
    borderColor: COLORS.primary,
  },
  name: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  subtitle: {
    fontSize: 16,
    color: COLORS.textSecondary,
    marginTop: 4,
  },
  statsContainer: {
    paddingHorizontal: 24,
    marginBottom: 24,
  },
  statsCard: {
    borderRadius: 16,
    overflow: 'hidden',
    backgroundColor: COLORS.cardBg,
    elevation: 8,
    shadowColor: 'black',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 16,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statSeparator: {
    height: 30,
    width: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
  },
  statNumber: {
    fontSize: 22,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  statLabel: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginTop: 4,
  },
  sectionHeader: {
    paddingHorizontal: 24,
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  card: {
    marginHorizontal: 24,
    borderRadius: 16,
    backgroundColor: COLORS.cardBg,
    overflow: 'hidden',
    elevation: 8,
    shadowColor: 'black',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    padding: 16,
  },
  favoriteItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  favoriteIcon: {
    width: 42,
    height: 42,
    borderRadius: 21,
    justifyContent: 'center',
    alignItems: 'center',
  },
  favoriteInfo: {
    flex: 1,
    marginLeft: 16,
  },
  favoriteTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.textPrimary,
  },
  favoriteSubtitle: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  favoriteAction: {
    margin: 0,
  },
  goalItem: {
    marginBottom: 20,
  },
  goalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  goalIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  goalTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: COLORS.textPrimary,
    flex: 1,
  },
  progressContainer: {
    paddingLeft: 52,
  },
  progressBackground: {
    height: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 4,
  },
  progressText: {
    fontSize: 12,
    color: COLORS.textSecondary,
    marginTop: 6,
  },
  buttonContainer: {
    alignItems: 'center',
    paddingVertical: 8,
  },
  editButton: {
    borderRadius: 30,
    width: '100%',
    backgroundColor: COLORS.primary,
  },
  buttonContent: {
    paddingVertical: 8,
  },
  buttonLabel: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  bottomPadding: {
    height: 30,
  },
});

export default ProfileScreen; 