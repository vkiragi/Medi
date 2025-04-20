import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { Text, Avatar, Card, List, useTheme, Button } from 'react-native-paper';

const ProfileScreen = () => {
  const theme = useTheme();

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Avatar.Image
          size={100}
          source={{ uri: 'https://randomuser.me/api/portraits/women/44.jpg' }}
          style={styles.avatar}
        />
        <Text style={styles.name}>Sarah Johnson</Text>
        <Text style={styles.subtitle}>Meditation Enthusiast</Text>
        <View style={styles.statsRow}>
          <View style={styles.statItem}>
            <Text style={styles.statNumber}>42</Text>
            <Text style={styles.statLabel}>Sessions</Text>
          </View>
          <View style={styles.statItem}>
            <Text style={styles.statNumber}>8</Text>
            <Text style={styles.statLabel}>Streak</Text>
          </View>
          <View style={styles.statItem}>
            <Text style={styles.statNumber}>320</Text>
            <Text style={styles.statLabel}>Minutes</Text>
          </View>
        </View>
      </View>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.sectionTitle}>Favorite Meditations</Text>
          
          <List.Item
            title="Morning Calm"
            description="10 minutes • Unguided"
            left={props => <List.Icon {...props} icon="leaf" color={theme.colors.primary} />}
            right={props => <List.Icon {...props} icon="star" color="#FFC107" />}
          />
          
          <List.Item
            title="Deep Sleep"
            description="30 minutes • Sleep"
            left={props => <List.Icon {...props} icon="moon-waning-crescent" color={theme.colors.primary} />}
            right={props => <List.Icon {...props} icon="star" color="#FFC107" />}
          />
          
          <List.Item
            title="Stress Relief"
            description="15 minutes • Guided"
            left={props => <List.Icon {...props} icon="compass" color={theme.colors.primary} />}
            right={props => <List.Icon {...props} icon="star" color="#FFC107" />}
          />
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.sectionTitle}>Progress Goals</Text>
          
          <List.Item
            title="Meditate 5 times per week"
            description="3/5 completed"
            left={props => <List.Icon {...props} icon="check-circle" color={theme.colors.primary} />}
          />
          
          <List.Item
            title="Complete 10 sleep sessions"
            description="7/10 completed"
            left={props => <List.Icon {...props} icon="check-circle" color={theme.colors.primary} />}
          />
          
          <List.Item
            title="Reach 10-day streak"
            description="8/10 days"
            left={props => <List.Icon {...props} icon="check-circle" color={theme.colors.primary} />}
          />
        </Card.Content>
      </Card>
      
      <View style={styles.buttonContainer}>
        <Button
          mode="outlined"
          onPress={() => {}}
          style={styles.editButton}
        >
          Edit Profile
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
  header: {
    alignItems: 'center',
    padding: 20,
    paddingBottom: 30,
    backgroundColor: '#FFFFFF',
  },
  avatar: {
    marginBottom: 16,
  },
  name: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  subtitle: {
    fontSize: 16,
    opacity: 0.7,
    marginBottom: 24,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '80%',
  },
  statItem: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  statLabel: {
    fontSize: 14,
    opacity: 0.7,
  },
  card: {
    margin: 16,
    marginTop: 8,
    borderRadius: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  buttonContainer: {
    padding: 16,
    paddingBottom: 30,
  },
  editButton: {
    borderRadius: 8,
  },
});

export default ProfileScreen; 