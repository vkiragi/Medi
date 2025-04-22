import { MeditationSession } from '../types';

export const meditationSessions: MeditationSession[] = [
  // Breathing meditations (renamed from "breathing" to "breath" to match category)
  {
    id: '1',
    name: 'Three Minute Breathing',
    duration: 3.5,
    description: 'A short mindfulness exercise focusing on bringing awareness to the process of breathing.',
    category: 'breath',
    soundPath: require('../assets/meditations/FreeMindfulness3MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  },
  {
    id: '2',
    name: 'Five Minute Breathing (MARC)',
    duration: 5,
    description: 'A brief mindfulness practice to cultivate awareness of breathing, from UCLA\'s Mindful Awareness Research Center.',
    category: 'breath',
    soundPath: require('../assets/meditations/MARC5MinuteBreathing.mp3'),
    attribution: 'Mindful Awareness Research Centre, UCLA',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  },
  {
    id: '3',
    name: 'Life Happens (5 Minutes)',
    duration: 5,
    description: 'A guided meditation focusing on embracing life\'s challenges through mindful breathing.',
    category: 'breath',
    soundPath: require('../assets/meditations/LifeHappens5MinuteBreathing.mp3'),
    attribution: 'Mindfulness Meditation',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  },
  
  // Meditation category
  {
    id: '7',
    name: 'Mindful Awareness',
    duration: 10,
    description: 'A classic mindfulness meditation focused on developing present moment awareness.',
    category: 'meditate',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
  {
    id: '8',
    name: 'Body Scan Meditation',
    duration: 15,
    description: 'A guided meditation that helps you develop awareness of your body and physical sensations.',
    category: 'meditate',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
  {
    id: '9',
    name: 'Loving-Kindness',
    duration: 12,
    description: 'A meditation practice that cultivates unconditional kindness toward oneself and others.',
    category: 'meditate',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
  
  // Sleep category
  {
    id: '10',
    name: 'Sleep Body Scan',
    duration: 20,
    description: 'A calming body scan meditation designed to help you relax and fall asleep naturally.',
    category: 'sleep',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
  {
    id: '11',
    name: 'Bedtime Relaxation',
    duration: 15,
    description: 'A gentle guided meditation to quiet the mind and prepare the body for restful sleep.',
    category: 'sleep',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
  {
    id: '12',
    name: 'Deep Sleep',
    duration: 30,
    description: 'A longer meditation designed to gradually guide you into deep, restorative sleep.',
    category: 'sleep',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
  
  // Affirmate category
  {
    id: '13',
    name: 'Morning Affirmations',
    duration: 8,
    description: 'Start your day with positive affirmations that build confidence and set a positive tone.',
    category: 'affirmate',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
  {
    id: '14',
    name: 'Self-Compassion',
    duration: 12,
    description: 'Guided affirmations focused on developing kindness and compassion toward yourself.',
    category: 'affirmate',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
  {
    id: '15',
    name: 'Confidence Builder',
    duration: 10,
    description: 'Affirmations designed to build self-esteem and confidence in your abilities.',
    category: 'affirmate',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'),
  },
];

export const attributionText = `
# Attribution

The guided meditation content in this app is provided under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License from freemindfulness.org and other sources.

## Contributors:

- Peter Morgan (freemindfulness.org)
- Mindful Awareness Research Centre, UCLA
- Still Mind
- Padraig O'Morain

All meditation audio files are sourced from open access resources with appropriate licensing.

This app is a non-commercial project. If you enjoy these meditations, please consider supporting the original creators.
`; 