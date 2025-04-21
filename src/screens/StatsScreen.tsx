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
import { Text, Surface, IconButton } from 'react-native-paper';
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

const StatsScreen = () => {
  const [fadeAnim] = useState(new Animated.Value(0));
  const [slideAnim] = useState(new Animated.Value(30));
  const [cardAnimValues] = useState([
    new Animated.Value(0),
    new Animated.Value(0),
    new Animated.Value(0)
  ]);
  
  // Sample data - would come from a real database in a production app
  const weeklyProgress = [
    { day: 'Mon', minutes: 10, completed: true },
    { day: 'Tue', minutes: 15, completed: true },
    { day: 'Wed', minutes: 5, completed: true },
    { day: 'Thu', minutes: 0, completed: false },
    { day: 'Fri', minutes: 0, completed: false },
    { day: 'Sat', minutes: 0, completed: false },
    { day: 'Sun', minutes: 0, completed: false },
  ];

  const monthlyStats = {
    totalSessions: 42,
    totalMinutes: 320,
    currentStreak: 8,
    longestStreak: 14,
    averageSessionLength: 8,
  };

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

  const renderDayProgress = (day: typeof weeklyProgress[0], index: number) => (
    <View key={index} style={styles.dayContainer}>
      <Surface style={[
        styles.daySurface, 
        day.completed ? 
          { backgroundColor: COLORS.primary } : 
          { backgroundColor: 'rgba(255, 255, 255, 0.1)' }
      ]}>
        <Text style={[styles.dayText, day.completed ? styles.dayCompletedText : {}]}>
          {day.day}
        </Text>
      </Surface>
      <Text style={styles.minutesText}>{day.minutes}m</Text>
    </View>
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
        <Text style={styles.headerTitle}>Your Meditation Stats</Text>
        <Text style={styles.headerSubtitle}>Track your mindfulness journey</Text>
      </Animated.View>
      
      <ScrollView 
        style={styles.scrollView} 
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContentContainer}
      >
        {renderAnimatedCard(0, 
          <View>
            <Text style={styles.cardTitle}>This Week</Text>
            <View style={styles.weekContainer}>
              {weeklyProgress.map(renderDayProgress)}
            </View>
            <View style={styles.weekSummary}>
              <Text style={styles.summaryText}>
                You've meditated for <Text style={styles.highlightText}>30 minutes</Text> this week
              </Text>
            </View>
          </View>
        )}

        {renderAnimatedCard(1, 
          <View>
            <Text style={styles.cardTitle}>Monthly Goals</Text>
            
            <View style={styles.goalItem}>
              <View style={styles.goalHeader}>
                <View style={[styles.goalIconContainer, { backgroundColor: COLORS.primary }]}>
                  <Ionicons name="time-outline" size={22} color="white" style={styles.goalIcon} />
                </View>
                <View style={styles.goalTextContainer}>
                  <Text style={styles.goalText}>50 minutes of meditation</Text>
                  <View style={styles.progressBarContainer}>
                    <View style={styles.progressBackground}>
                      <View style={[styles.progressFill, { width: '64%', backgroundColor: COLORS.primary }]} />
                    </View>
                    <Text style={styles.goalPercentage}>64%</Text>
                  </View>
                </View>
              </View>
            </View>
            
            <View style={styles.goalItem}>
              <View style={styles.goalHeader}>
                <View style={[styles.goalIconContainer, { backgroundColor: COLORS.primary }]}>
                  <Ionicons name="flame-outline" size={22} color="white" style={styles.goalIcon} />
                </View>
                <View style={styles.goalTextContainer}>
                  <Text style={styles.goalText}>10 days streak</Text>
                  <View style={styles.progressBarContainer}>
                    <View style={styles.progressBackground}>
                      <View style={[styles.progressFill, { width: '80%', backgroundColor: COLORS.primary }]} />
                    </View>
                    <Text style={styles.goalPercentage}>80%</Text>
                  </View>
                </View>
              </View>
            </View>
            
            <View style={styles.goalItem}>
              <View style={styles.goalHeader}>
                <View style={[styles.goalIconContainer, { backgroundColor: COLORS.primary }]}>
                  <Ionicons name="calendar-outline" size={22} color="white" style={styles.goalIcon} />
                </View>
                <View style={styles.goalTextContainer}>
                  <Text style={styles.goalText}>15 meditation sessions</Text>
                  <View style={styles.progressBarContainer}>
                    <View style={styles.progressBackground}>
                      <View style={[styles.progressFill, { width: '25%', backgroundColor: COLORS.primary }]} />
                    </View>
                    <Text style={styles.goalPercentage}>25%</Text>
                  </View>
                </View>
              </View>
            </View>
          </View>
        )}

        {renderAnimatedCard(2, 
          <View>
            <Text style={styles.cardTitle}>Statistics</Text>
            
            <View style={styles.statItem}>
              <View style={[styles.statIconContainer, { backgroundColor: COLORS.primary }]}>
                <Ionicons name="calendar-outline" size={22} color="white" />
              </View>
              <View style={styles.statInfo}>
                <Text style={styles.statTitle}>Total Sessions</Text>
                <Text style={styles.statValue}>{monthlyStats.totalSessions}</Text>
              </View>
            </View>
            
            <View style={styles.statItem}>
              <View style={[styles.statIconContainer, { backgroundColor: COLORS.primary }]}>
                <Ionicons name="time-outline" size={22} color="white" />
              </View>
              <View style={styles.statInfo}>
                <Text style={styles.statTitle}>Total Minutes</Text>
                <Text style={styles.statValue}>{monthlyStats.totalMinutes}</Text>
              </View>
            </View>
            
            <View style={styles.statItem}>
              <View style={[styles.statIconContainer, { backgroundColor: COLORS.primary }]}>
                <Ionicons name="flash-outline" size={22} color="white" />
              </View>
              <View style={styles.statInfo}>
                <Text style={styles.statTitle}>Current Streak</Text>
                <Text style={styles.statValue}>{monthlyStats.currentStreak} days</Text>
              </View>
            </View>
            
            <View style={styles.statItem}>
              <View style={[styles.statIconContainer, { backgroundColor: COLORS.primary }]}>
                <Ionicons name="trophy-outline" size={22} color="white" />
              </View>
              <View style={styles.statInfo}>
                <Text style={styles.statTitle}>Longest Streak</Text>
                <Text style={styles.statValue}>{monthlyStats.longestStreak} days</Text>
              </View>
            </View>
            
            <View style={styles.statItem}>
              <View style={[styles.statIconContainer, { backgroundColor: COLORS.primary }]}>
                <Ionicons name="analytics-outline" size={22} color="white" />
              </View>
              <View style={styles.statInfo}>
                <Text style={styles.statTitle}>Average Session</Text>
                <Text style={styles.statValue}>{monthlyStats.averageSessionLength} minutes</Text>
              </View>
            </View>
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
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
    marginBottom: 20,
  },
  weekContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  dayContainer: {
    alignItems: 'center',
  },
  daySurface: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  dayText: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  dayCompletedText: {
    color: 'white',
    fontWeight: '600',
  },
  minutesText: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  weekSummary: {
    alignItems: 'center',
    marginTop: 8,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.1)',
  },
  summaryText: {
    fontSize: 16,
    color: COLORS.textPrimary,
  },
  highlightText: {
    color: COLORS.primary,
    fontWeight: 'bold',
  },
  goalItem: {
    marginBottom: 24,
  },
  goalHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  goalIconContainer: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: COLORS.darkGray,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  goalIcon: {
    opacity: 0.9,
  },
  goalTextContainer: {
    flex: 1,
  },
  goalText: {
    fontSize: 16,
    color: COLORS.textPrimary,
    marginBottom: 8,
  },
  progressBarContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  progressBackground: {
    flex: 1,
    height: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: 4,
    overflow: 'hidden',
    marginRight: 12,
  },
  progressFill: {
    height: '100%',
    borderRadius: 4,
  },
  goalPercentage: {
    fontSize: 14,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
    width: 40,
    textAlign: 'right',
  },
  statItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  statIconContainer: {
    width: 42,
    height: 42,
    borderRadius: 21,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  statInfo: {
    flex: 1,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
    paddingBottom: 12,
  },
  statTitle: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginBottom: 4,
  },
  statValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  bottomPadding: {
    height: 30,
  },
});

export default StatsScreen; 