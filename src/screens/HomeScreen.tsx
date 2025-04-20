import React, { useState } from 'react';
import { StyleSheet, View, FlatList, TouchableOpacity, Image } from 'react-native';
import { Card, Title, Paragraph, Button, Text, Surface, useTheme, Avatar, IconButton } from 'react-native-paper';
import { useNavigation, CommonActions } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList, MeditationSession } from '../types';
import { meditationSessions } from '../data/meditations';

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

// Category icons
const getCategoryIcon = (category: string) => {
  switch (category) {
    case 'guided': return 'compass';
    case 'unguided': return 'leaf';
    case 'breathing': return 'weather-windy';
    case 'sleep': return 'moon-waning-crescent';
    case 'body': return 'human-male';
    case 'compassion': return 'heart';
    case 'relaxation': return 'spa';
    default: return 'meditation';
  }
};

const HomeScreen = () => {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const theme = useTheme();
  const [failedImages, setFailedImages] = useState<{[key: string]: boolean}>({});

  const handleImageError = (id: string) => {
    setFailedImages(prev => ({
      ...prev,
      [id]: true
    }));
  };

  const renderMeditationCard = ({ item }: { item: MeditationSession }) => (
    <TouchableOpacity
      onPress={() => navigation.navigate('MeditationDetail', { meditation: item })}
      style={styles.cardContainer}
    >
      <Surface style={styles.surface}>
        <Card style={styles.card}>
          <View style={styles.cardHeader}>
            <Avatar.Icon 
              size={40} 
              icon={getCategoryIcon(item.category)} 
              color={theme.colors.primary} 
              style={{ backgroundColor: '#EAE2F5' }}
            />
            <View style={styles.durationBadge}>
              <Text style={styles.durationText}>{item.duration} min</Text>
            </View>
          </View>
          <Card.Content>
            <Title style={styles.cardTitle}>{item.name}</Title>
            <Paragraph numberOfLines={2} style={styles.cardDescription}>
              {item.description}
            </Paragraph>
            {item.attribution && (
              <Text style={styles.attribution}>
                Credit: {item.attribution}
              </Text>
            )}
          </Card.Content>
          <Card.Actions style={styles.cardActions}>
            <Button 
              mode="contained" 
              onPress={() => navigation.navigate('MeditationPlayer', { meditation: item })}
              style={styles.startButton}
            >
              Start
            </Button>
          </Card.Actions>
        </Card>
      </Surface>
    </TouchableOpacity>
  );

  const navigateToAttribution = () => {
    navigation.dispatch(
      CommonActions.navigate({
        name: 'Attribution'
      })
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View>
          <Text style={styles.welcomeText}>Welcome back</Text>
          <Text style={styles.headerText}>Find your peaceful moment</Text>
        </View>
        <TouchableOpacity onPress={navigateToAttribution}>
          <IconButton
            icon="information-outline"
            size={24}
            iconColor={theme.colors.primary}
          />
        </TouchableOpacity>
      </View>

      <View style={styles.listContainer}>
        <FlatList
          data={meditationSessions}
          renderItem={renderMeditationCard}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 10,
  },
  header: {
    paddingHorizontal: 20,
    paddingBottom: 20,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  welcomeText: {
    fontSize: 18,
    opacity: 0.6,
  },
  headerText: {
    fontSize: 28,
    fontWeight: 'bold',
    marginTop: 5,
  },
  listContainer: {
    flex: 1,
  },
  listContent: {
    padding: 20,
    paddingTop: 10,
  },
  cardContainer: {
    marginBottom: 16,
  },
  surface: {
    elevation: 2,
    borderRadius: 10,
  },
  card: {
    borderRadius: 10,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 16,
  },
  durationBadge: {
    backgroundColor: '#F0F0F0',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 20,
  },
  durationText: {
    fontSize: 12,
    fontWeight: 'bold',
  },
  cardTitle: {
    marginTop: 10,
    fontSize: 18,
  },
  cardDescription: {
    fontSize: 14,
    opacity: 0.7,
    marginTop: 5,
  },
  attribution: {
    fontSize: 11,
    fontStyle: 'italic',
    marginTop: 8,
    opacity: 0.6,
  },
  cardActions: {
    justifyContent: 'flex-end',
    paddingBottom: 8,
  },
  startButton: {
    borderRadius: 20,
  },
});

export default HomeScreen; 