import React, { useState } from 'react';
import { StyleSheet, View, ScrollView, SafeAreaView, Image } from 'react-native';
import { Text, Button, Card, Paragraph, Title, Avatar, useTheme } from 'react-native-paper';
import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../types';

type MeditationDetailScreenRouteProp = RouteProp<RootStackParamList, 'MeditationDetail'>;
type MeditationDetailScreenNavigationProp = StackNavigationProp<RootStackParamList, 'MeditationDetail'>;

interface MeditationDetailScreenProps {
  route: MeditationDetailScreenRouteProp;
  navigation: MeditationDetailScreenNavigationProp;
}

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

const MeditationDetailScreen = ({ route, navigation }: MeditationDetailScreenProps) => {
  const { meditation } = route.params;
  const theme = useTheme();
  const [showImage, setShowImage] = useState(true);

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView style={styles.container}>
        <Card style={styles.card}>
          {meditation.imageUrl && showImage ? (
            <Card.Cover 
              source={meditation.imageUrl} 
              style={styles.coverImage}
              onError={() => setShowImage(false)}
            />
          ) : (
            <View style={[styles.coverImageFallback, {backgroundColor: theme.colors.primary}]}>
              <Avatar.Icon 
                size={80} 
                icon={getCategoryIcon(meditation.category)} 
                color="white"
                style={{ backgroundColor: 'transparent' }} 
              />
            </View>
          )}
          <View style={styles.headerContainer}>
            <Avatar.Icon 
              size={60} 
              icon={getCategoryIcon(meditation.category)} 
              color={theme.colors.primary} 
              style={{ backgroundColor: '#EAE2F5' }}
            />
            <View style={styles.headerTextContainer}>
              <Title style={styles.title}>{meditation.name}</Title>
              <Text style={styles.category}>{meditation.category.charAt(0).toUpperCase() + meditation.category.slice(1)} Meditation</Text>
            </View>
          </View>

          <Card.Content>
            <View style={styles.infoContainer}>
              <View style={styles.infoItem}>
                <Text style={styles.infoLabel}>Duration</Text>
                <Text style={styles.infoValue}>{meditation.duration} minutes</Text>
              </View>
              {meditation.soundName && (
                <View style={styles.infoItem}>
                  <Text style={styles.infoLabel}>Sound</Text>
                  <Text style={styles.infoValue}>{meditation.soundName}</Text>
                </View>
              )}
            </View>

            <View style={styles.descriptionContainer}>
              <Text style={styles.descriptionTitle}>Description</Text>
              <Paragraph style={styles.description}>{meditation.description}</Paragraph>
            </View>

            <View style={styles.benefitsContainer}>
              <Text style={styles.benefitsTitle}>Benefits</Text>
              <View style={styles.benefitsList}>
                <View style={styles.benefitItem}>
                  <Avatar.Icon 
                    size={32} 
                    icon="brain" 
                    color={theme.colors.primary} 
                    style={styles.benefitIcon}
                  />
                  <Text style={styles.benefitText}>Reduces stress and anxiety</Text>
                </View>
                <View style={styles.benefitItem}>
                  <Avatar.Icon 
                    size={32} 
                    icon="heart" 
                    color={theme.colors.primary} 
                    style={styles.benefitIcon}
                  />
                  <Text style={styles.benefitText}>Improves emotional well-being</Text>
                </View>
                <View style={styles.benefitItem}>
                  <Avatar.Icon 
                    size={32} 
                    icon="sleep" 
                    color={theme.colors.primary} 
                    style={styles.benefitIcon}
                  />
                  <Text style={styles.benefitText}>Enhances sleep quality</Text>
                </View>
                <View style={styles.benefitItem}>
                  <Avatar.Icon 
                    size={32} 
                    icon="focus" 
                    color={theme.colors.primary} 
                    style={styles.benefitIcon}
                  />
                  <Text style={styles.benefitText}>Increases focus and concentration</Text>
                </View>
              </View>
            </View>
          </Card.Content>
        </Card>
      </ScrollView>

      <View style={styles.buttonContainer}>
        <Button 
          mode="contained" 
          onPress={() => navigation.navigate('MeditationPlayer', { meditation })}
          style={styles.startButton}
          labelStyle={styles.buttonLabel}
        >
          Begin Meditation
        </Button>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
  },
  container: {
    flex: 1,
    padding: 16,
  },
  card: {
    marginBottom: 90,
    borderRadius: 12,
    overflow: 'hidden',
  },
  headerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    paddingBottom: 20,
  },
  headerTextContainer: {
    marginLeft: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  category: {
    opacity: 0.6,
    fontSize: 16,
  },
  infoContainer: {
    flexDirection: 'row',
    marginBottom: 24,
    marginTop: 10,
  },
  infoItem: {
    marginRight: 36,
  },
  infoLabel: {
    fontSize: 14,
    opacity: 0.6,
  },
  infoValue: {
    fontSize: 16,
    fontWeight: 'bold',
    marginTop: 4,
  },
  descriptionContainer: {
    marginBottom: 24,
  },
  descriptionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  description: {
    fontSize: 16,
    lineHeight: 24,
  },
  benefitsContainer: {
    marginBottom: 16,
  },
  benefitsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  benefitsList: {
    gap: 12,
  },
  benefitItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  benefitIcon: {
    backgroundColor: '#EAE2F5',
  },
  benefitText: {
    marginLeft: 12,
    fontSize: 16,
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    padding: 16,
    backgroundColor: 'white',
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
  },
  startButton: {
    borderRadius: 30,
    paddingVertical: 8,
  },
  buttonLabel: {
    fontSize: 16,
    paddingVertical: 4,
  },
  coverImage: {
    height: 200,
  },
  coverImageFallback: {
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default MeditationDetailScreen; 