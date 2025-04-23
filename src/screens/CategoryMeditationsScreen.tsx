import React, { useEffect, useState } from 'react';
import { 
  StyleSheet, 
  View, 
  SafeAreaView, 
  FlatList,
  StatusBar,
  TouchableOpacity
} from 'react-native';
import { Text, Surface, IconButton } from 'react-native-paper';
import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { AppStackParamList, MeditationSession } from '../types';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { meditationSessions } from '../data/meditations';

type CategoryMeditationsScreenRouteProp = RouteProp<AppStackParamList, 'CategoryMeditations'>;
type CategoryMeditationsScreenNavigationProp = StackNavigationProp<AppStackParamList, 'CategoryMeditations'>;

interface CategoryMeditationsScreenProps {
  route: CategoryMeditationsScreenRouteProp;
  navigation: CategoryMeditationsScreenNavigationProp;
}

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

const CategoryMeditationsScreen = ({ route, navigation }: CategoryMeditationsScreenProps) => {
  const { categoryName, categoryColor } = route.params;
  const [meditations, setMeditations] = useState<MeditationSession[]>([]);
  
  useEffect(() => {
    // Filter meditations by the selected category
    const filteredMeditations = meditationSessions.filter(
      m => m.category.toLowerCase() === categoryName.toLowerCase()
    );
    setMeditations(filteredMeditations);
  }, [categoryName]);

  const renderMeditationItem = ({ item }: { item: MeditationSession }) => (
    <Surface style={styles.meditationCard}>
      <TouchableOpacity 
        style={styles.meditationContent}
        onPress={() => navigation.navigate('MeditationDetail', { meditation: item })}
      >
        <View style={[styles.iconContainer, { backgroundColor: categoryColor }]}>
          <Ionicons 
            name={getCategoryIcon(categoryName)} 
            size={24}
            color="white"
          />
        </View>
        <View style={styles.meditationInfo}>
          <Text style={styles.meditationTitle}>{item.name}</Text>
          <Text style={styles.meditationDuration}>{item.duration} minutes</Text>
        </View>
        <IconButton
          icon="play-circle"
          size={36}
          iconColor={categoryColor}
          onPress={() => navigation.navigate('MeditationPlayer', { meditation: item })}
        />
      </TouchableOpacity>
    </Surface>
  );

  // Get appropriate icon based on category
  const getCategoryIcon = (category: string): string => {
    switch (category.toLowerCase()) {
      case 'breath':
        return 'water-outline';
      case 'sleep':
        return 'moon-outline';
      case 'meditate':
        return 'triangle-outline';
      case 'affirmate':
        return 'heart-outline';
      default:
        return 'triangle-outline';
    }
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
      
      <View style={styles.header}>
        <IconButton
          icon="arrow-left"
          size={24}
          iconColor={COLORS.textPrimary}
          onPress={() => navigation.goBack()}
        />
        <Text style={styles.headerTitle}>{categoryName} Meditations</Text>
        <View style={styles.headerRight} />
      </View>
      
      <FlatList
        data={meditations}
        keyExtractor={item => item.id}
        renderItem={renderMeditationItem}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No meditations found in this category.</Text>
          </View>
        }
      />
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
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: COLORS.textPrimary,
  },
  headerRight: {
    width: 40, // Same width as the back button to balance the header
  },
  listContent: {
    padding: 16,
    paddingBottom: 30,
  },
  meditationCard: {
    marginBottom: 16,
    borderRadius: 16,
    backgroundColor: COLORS.cardBg,
    overflow: 'hidden',
    elevation: 4,
    shadowColor: 'black',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  meditationContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  meditationInfo: {
    flex: 1,
  },
  meditationTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.textPrimary,
    marginBottom: 4,
  },
  meditationDuration: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  emptyContainer: {
    padding: 20,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
});

export default CategoryMeditationsScreen; 