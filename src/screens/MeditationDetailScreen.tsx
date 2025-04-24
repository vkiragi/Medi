import React, { useState, useEffect } from 'react';
import { 
  StyleSheet, 
  View, 
  ScrollView, 
  Animated, 
  Dimensions,
  StatusBar,
  Platform
} from 'react-native';
import { Text, Button, Card, Paragraph, Avatar, IconButton } from 'react-native-paper';
import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList, AppStackParamList } from '../types';
import { LinearGradient } from 'expo-linear-gradient';
import Ionicons from '@expo/vector-icons/Ionicons';
import { SafeAreaView } from 'react-native-safe-area-context';

type MeditationDetailScreenRouteProp = RouteProp<AppStackParamList, 'MeditationDetail'>;
type MeditationDetailScreenNavigationProp = StackNavigationProp<AppStackParamList, 'MeditationDetail'>;

interface MeditationDetailScreenProps {
  route: MeditationDetailScreenRouteProp;
  navigation: MeditationDetailScreenNavigationProp;
}

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

// Category icons
const getCategoryIcon = (category: string) => {
  switch (category) {
    case 'guided': return 'compass-outline';
    case 'unguided': return 'leaf-outline';
    case 'breathing': return 'water-outline';
    case 'sleep': return 'moon-outline';
    case 'body': return 'body-outline';
    case 'compassion': return 'heart-outline';
    case 'relaxation': return 'flower-outline';
    default: return 'color-palette-outline';
  }
};

// Get animation based on category
const getCategoryAnimation = (category: string) => {
  if (category === 'breathing') {
    return require('../../assets/images/meditation-breathing.jpg');
  }
  return require('../../assets/images/meditation-space.jpg');
};

const MeditationDetailScreen = ({ route, navigation }: MeditationDetailScreenProps) => {
  const { meditation } = route.params;
  const [fadeAnim] = useState(new Animated.Value(0));
  const [slideAnim] = useState(new Animated.Value(50));

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 600,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 800,
        useNativeDriver: true,
      })
    ]).start();
  }, []);

  const renderHeader = () => {
    return (
      <Animated.View style={styles.headerContainer}>
        <View style={styles.headerContent}>
          <IconButton
            icon="arrow-left"
            size={28}
            iconColor="#FFFFFF"
            onPress={() => navigation.goBack()}
            style={styles.backButton}
          />
          <View style={styles.titleContainer}>
            <Text style={styles.headerTitle} numberOfLines={2} ellipsizeMode="tail">
              {meditation.name}
            </Text>
            <Text style={styles.headerSubtitle}>
              {meditation.duration} minutes • {meditation.category}
            </Text>
          </View>
          <View style={{ width: 28 }} />
        </View>
      </Animated.View>
    );
  };

  return (
    <SafeAreaView style={styles.safeAreaContainer}>
      <StatusBar barStyle="light-content" />
      
      <LinearGradient
        colors={DARK_GRADIENT_COLORS}
        style={styles.background}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
      />
      
      {renderHeader()}

      <Animated.View style={[
        styles.contentContainer,
        {
          opacity: fadeAnim,
          transform: [{ translateY: slideAnim }]
        }
      ]}>
        <Card style={styles.card}>
          <Card.Content>
            <View style={styles.infoContainer}>
              <View style={styles.infoItem}>
                <View style={[styles.iconContainer, { backgroundColor: COLORS.primary }]}>
                  <Ionicons name="time-outline" size={22} color="white" />
                </View>
                <View>
                  <Text style={styles.infoLabel}>Duration</Text>
                  <Text style={styles.infoValue}>{meditation.duration} minutes</Text>
                </View>
              </View>
              
              <View style={styles.infoItem}>
                <View style={[styles.iconContainer, { backgroundColor: COLORS.primary }]}>
                  <Ionicons name={getCategoryIcon(meditation.category)} size={22} color="white" />
                </View>
                <View>
                  <Text style={styles.infoLabel}>Type</Text>
                  <Text style={styles.infoValue}>{meditation.category.charAt(0).toUpperCase() + meditation.category.slice(1)}</Text>
                </View>
              </View>
            </View>

            <View style={styles.descriptionContainer}>
              <Text style={styles.sectionTitle}>Description</Text>
              <Paragraph style={styles.description}>{meditation.description}</Paragraph>
            </View>

            <View style={styles.attributionContainer}>
              <Text style={styles.sectionTitle}>Attribution</Text>
              <Paragraph style={styles.attribution}>
                {meditation.attribution || "Original content"}
              </Paragraph>
            </View>

            <View style={styles.benefitsContainer}>
              <Text style={styles.sectionTitle}>Benefits</Text>
              <View style={styles.benefitsList}>
                <View style={styles.benefitItem}>
                  <View style={[styles.benefitIconContainer, { backgroundColor: COLORS.primary }]}>
                    <Ionicons name="fitness-outline" size={22} color="white" />
                  </View>
                  <Text style={styles.benefitText}>Reduces stress and anxiety</Text>
                </View>
                <View style={styles.benefitItem}>
                  <View style={[styles.benefitIconContainer, { backgroundColor: COLORS.primary }]}>
                    <Ionicons name="heart-outline" size={22} color="white" />
                  </View>
                  <Text style={styles.benefitText}>Improves emotional well-being</Text>
                </View>
                <View style={styles.benefitItem}>
                  <View style={[styles.benefitIconContainer, { backgroundColor: COLORS.primary }]}>
                    <Ionicons name="moon-outline" size={22} color="white" />
                  </View>
                  <Text style={styles.benefitText}>Enhances sleep quality</Text>
                </View>
                <View style={styles.benefitItem}>
                  <View style={[styles.benefitIconContainer, { backgroundColor: COLORS.primary }]}>
                    <Ionicons name="analytics-outline" size={22} color="white" />
                  </View>
                  <Text style={styles.benefitText}>Increases focus and concentration</Text>
                </View>
              </View>
            </View>
          </Card.Content>
        </Card>
      </Animated.View>

      <Animated.View 
        style={[
          styles.buttonContainer,
          {
            opacity: fadeAnim,
            transform: [{ translateY: slideAnim }]
          }
        ]}
      >
        <Button 
          mode="contained" 
          onPress={() => navigation.navigate('MeditationPlayer', { meditation })}
          style={styles.startButton}
          labelStyle={styles.buttonLabel}
        >
          Begin Meditation
        </Button>
      </Animated.View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeAreaContainer: {
    flex: 1,
    backgroundColor: COLORS.dark,
  },
  background: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    zIndex: -1,
  },
  headerContainer: {
    // Remove background related styles if any
    // zIndex: 10, // Likely remove zIndex
    // Height will be determined by content + padding
  },
  headerContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingTop: Platform.OS === 'ios' ? 10 : 10, // Keep padding for positioning
    paddingBottom: 16,
  },
  titleContainer: {
    flex: 1,
    alignItems: 'center',
  },
  headerTitle: {
    color: COLORS.textPrimary,
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  headerSubtitle: {
    color: COLORS.textSecondary,
    fontSize: 14,
    marginTop: 4,
    textAlign: 'center',
  },
  backButton: {
    padding: 0,
    margin: 0,
  },
  contentContainer: {
    flex: 1,
    paddingHorizontal: 24,
    paddingVertical: 20,
    justifyContent: 'center',
  },
  card: {
    borderRadius: 16,
    backgroundColor: COLORS.cardBg,
  },
  infoContainer: {
    flexDirection: 'row',
    marginBottom: 20,
    justifyContent: 'flex-start',
  },
  infoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 24,
  },
  iconContainer: {
    width: 42,
    height: 42,
    borderRadius: 21,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  infoLabel: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  infoValue: {
    fontSize: 14,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  descriptionContainer: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    color: COLORS.textPrimary,
  },
  description: {
    fontSize: 16,
    lineHeight: 23,
    color: COLORS.textSecondary,
  },
  attributionContainer: {
    marginBottom: 20,
  },
  attribution: {
    fontSize: 14,
    lineHeight: 19,
    fontStyle: 'italic',
    color: COLORS.textSecondary,
  },
  benefitsContainer: {
    marginBottom: 12,
  },
  benefitsList: {
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    borderRadius: 12,
    padding: 14,
  },
  benefitItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  benefitIconContainer: {
    width: 42,
    height: 42,
    borderRadius: 21,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  benefitText: {
    fontSize: 16,
    flex: 1,
    color: COLORS.textPrimary,
  },
  buttonContainer: {
    backgroundColor: COLORS.cardBg,
    paddingVertical: 16,
    paddingHorizontal: 24,
    marginBottom: 10,
  },
  startButton: {
    borderRadius: 30,
    height: 56,
    justifyContent: 'center',
    backgroundColor: COLORS.primary,
  },
  buttonLabel: {
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default MeditationDetailScreen; 