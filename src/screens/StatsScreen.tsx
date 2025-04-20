import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { Text, Card, ProgressBar, List, useTheme, Surface } from 'react-native-paper';

const StatsScreen = () => {
  const theme = useTheme();

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

  const renderDayProgress = (day: typeof weeklyProgress[0], index: number) => (
    <View key={index} style={styles.dayContainer}>
      <Surface style={[styles.daySurface, day.completed ? styles.dayCompleted : {}]}>
        <Text style={[styles.dayText, day.completed ? styles.dayCompletedText : {}]}>
          {day.day}
        </Text>
      </Surface>
      <Text style={styles.minutesText}>{day.minutes}m</Text>
    </View>
  );

  return (
    <ScrollView style={styles.container}>
      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.cardTitle}>This Week</Text>
          <View style={styles.weekContainer}>
            {weeklyProgress.map(renderDayProgress)}
          </View>
          <View style={styles.weekSummary}>
            <Text style={styles.summaryText}>
              You've meditated for <Text style={styles.highlightText}>30 minutes</Text> this week
            </Text>
          </View>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.cardTitle}>Monthly Goals</Text>
          
          <View style={styles.goalItem}>
            <View style={styles.goalHeader}>
              <Text style={styles.goalText}>50 minutes of meditation</Text>
              <Text style={styles.goalPercentage}>64%</Text>
            </View>
            <ProgressBar 
              progress={0.64} 
              color={theme.colors.primary} 
              style={styles.progressBar} 
            />
          </View>
          
          <View style={styles.goalItem}>
            <View style={styles.goalHeader}>
              <Text style={styles.goalText}>10 days streak</Text>
              <Text style={styles.goalPercentage}>80%</Text>
            </View>
            <ProgressBar 
              progress={0.8} 
              color={theme.colors.primary} 
              style={styles.progressBar} 
            />
          </View>
          
          <View style={styles.goalItem}>
            <View style={styles.goalHeader}>
              <Text style={styles.goalText}>15 meditation sessions</Text>
              <Text style={styles.goalPercentage}>25%</Text>
            </View>
            <ProgressBar 
              progress={0.25} 
              color={theme.colors.primary} 
              style={styles.progressBar} 
            />
          </View>
        </Card.Content>
      </Card>

      <Card style={styles.card}>
        <Card.Content>
          <Text style={styles.cardTitle}>Statistics</Text>
          
          <List.Item
            title="Total Sessions"
            description={monthlyStats.totalSessions.toString()}
            left={props => <List.Icon {...props} icon="calendar-check" color={theme.colors.primary} />}
          />
          
          <List.Item
            title="Total Minutes"
            description={monthlyStats.totalMinutes.toString()}
            left={props => <List.Icon {...props} icon="clock-outline" color={theme.colors.primary} />}
          />
          
          <List.Item
            title="Current Streak"
            description={monthlyStats.currentStreak.toString() + " days"}
            left={props => <List.Icon {...props} icon="lightning-bolt" color={theme.colors.primary} />}
          />
          
          <List.Item
            title="Longest Streak"
            description={monthlyStats.longestStreak.toString() + " days"}
            left={props => <List.Icon {...props} icon="trophy" color={theme.colors.primary} />}
          />
          
          <List.Item
            title="Average Session"
            description={monthlyStats.averageSessionLength.toString() + " minutes"}
            left={props => <List.Icon {...props} icon="chart-line" color={theme.colors.primary} />}
          />
        </Card.Content>
      </Card>
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
  cardTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 16,
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
    backgroundColor: '#F0F0F0',
    marginBottom: 8,
  },
  dayCompleted: {
    backgroundColor: '#6A5ACD',
  },
  dayText: {
    fontSize: 14,
  },
  dayCompletedText: {
    color: 'white',
  },
  minutesText: {
    fontSize: 12,
    color: '#666',
  },
  weekSummary: {
    alignItems: 'center',
    marginTop: 8,
  },
  summaryText: {
    fontSize: 16,
  },
  highlightText: {
    color: '#6A5ACD',
    fontWeight: 'bold',
  },
  goalItem: {
    marginBottom: 20,
  },
  goalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  goalText: {
    fontSize: 16,
  },
  goalPercentage: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  progressBar: {
    height: 8,
    borderRadius: 4,
  },
});

export default StatsScreen; 