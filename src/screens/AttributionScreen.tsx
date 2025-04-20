import React from 'react';
import { StyleSheet, ScrollView, View, Linking } from 'react-native';
import { Text, Card, Title, Paragraph, useTheme, Button } from 'react-native-paper';
import { attributionText } from '../data/meditations';
import Markdown from 'react-native-markdown-display';

const AttributionScreen = () => {
  const theme = useTheme();
  
  const openFreeMindfulness = () => {
    Linking.openURL('https://www.freemindfulness.org/download');
  };
  
  return (
    <ScrollView style={styles.container}>
      <Card style={styles.card}>
        <Card.Content>
          <Title style={styles.title}>Attribution</Title>
          <Paragraph style={styles.paragraph}>
            The guided meditations in this app are licensed under Creative Commons and sourced from freemindfulness.org.
          </Paragraph>
          
          <View style={styles.divider} />
          
          <Title style={styles.contributorsTitle}>Contributors</Title>
          <View style={styles.contributor}>
            <Text style={styles.contributorName}>• Peter Morgan</Text>
            <Text style={styles.contributionDetail}>Three Minute Breathing, Mountain Meditation</Text>
          </View>
          
          <View style={styles.contributor}>
            <Text style={styles.contributorName}>• UCSD Center for Mindfulness</Text>
            <Text style={styles.contributionDetail}>Body Scan, Wisdom Meditation</Text>
          </View>
          
          <View style={styles.contributor}>
            <Text style={styles.contributorName}>• Mindful Awareness Research Centre, UCLA</Text>
            <Text style={styles.contributionDetail}>Breath, Sounds & Body</Text>
          </View>
          
          <View style={styles.contributor}>
            <Text style={styles.contributorName}>• Vidyamala Burch, Breathworks</Text>
            <Text style={styles.contributionDetail}>Compassionate Breath, Breathing Space, Tension Release</Text>
          </View>
          
          <View style={styles.divider} />
          
          <Text style={styles.licenseTitle}>License</Text>
          <Text style={styles.licenseText}>
            Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License
          </Text>
          <Text style={styles.licenseDetails}>
            This license requires that you provide attribution to the original creators, use the content for non-commercial purposes only, and share any adaptations under the same license.
          </Text>
          
          <Button 
            mode="contained" 
            onPress={openFreeMindfulness}
            style={[styles.button, {backgroundColor: theme.colors.primary}]}
          >
            Visit freemindfulness.org
          </Button>
        </Card.Content>
      </Card>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FE',
    padding: 16,
  },
  card: {
    borderRadius: 12,
    marginBottom: 20,
  },
  title: {
    fontSize: 24,
    marginBottom: 8,
  },
  paragraph: {
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 16,
  },
  divider: {
    height: 1,
    backgroundColor: '#e0e0e0',
    marginVertical: 16,
  },
  contributorsTitle: {
    fontSize: 20,
    marginBottom: 12,
  },
  contributor: {
    marginBottom: 12,
  },
  contributorName: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  contributionDetail: {
    fontSize: 14,
    opacity: 0.7,
    marginLeft: 16,
    marginTop: 2,
  },
  licenseTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  licenseText: {
    fontSize: 16,
    fontStyle: 'italic',
    marginBottom: 8,
  },
  licenseDetails: {
    fontSize: 14,
    opacity: 0.7,
    marginBottom: 20,
  },
  button: {
    marginTop: 16,
    marginBottom: 8,
    borderRadius: 8,
  },
});

export default AttributionScreen; 