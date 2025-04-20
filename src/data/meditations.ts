import { MeditationSession } from '../types';

export const meditationSessions: MeditationSession[] = [
  {
    id: '1',
    name: 'Three Minute Breathing',
    duration: 3.5,
    description: 'A short mindfulness exercise focusing on bringing awareness to the process of breathing.',
    category: 'breathing',
    soundPath: require('../assets/meditations/FreeMindfulness3MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  },
  {
    id: '2',
    name: 'Five Minute Breathing (MARC)',
    duration: 5,
    description: 'A brief mindfulness practice to cultivate awareness of breathing, from UCLA\'s Mindful Awareness Research Center.',
    category: 'breathing',
    soundPath: require('../assets/meditations/MARC5MinuteBreathing.mp3'),
    attribution: 'Mindful Awareness Research Centre, UCLA',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  },
  {
    id: '3',
    name: 'Life Happens (5 Minutes)',
    duration: 5,
    description: 'A guided meditation focusing on embracing life\'s challenges through mindful breathing.',
    category: 'breathing',
    soundPath: require('../assets/meditations/LifeHappens5MinuteBreathing.mp3'),
    attribution: 'Mindfulness Meditation',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  },
  {
    id: '4',
    name: 'Breath Awareness (6 Minutes)',
    duration: 6,
    description: 'Develop breath awareness and mindful presence through this short guided practice.',
    category: 'breathing',
    soundPath: require('../assets/meditations/StillMind6MinuteBreathAwareness.mp3'),
    attribution: 'Still Mind',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  },
  {
    id: '5',
    name: 'Ten Minute Breathing',
    duration: 10,
    description: 'A guided breathing meditation to help establish a deeper awareness of the present moment.',
    category: 'breathing',
    soundPath: require('../assets/meditations/FreeMindfulness10MinuteBreathing.mp3'),
    attribution: 'Peter Morgan, freemindfulness.org',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  },
  {
    id: '6',
    name: 'Mindfulness of Breathing (10 Minutes)',
    duration: 10,
    description: 'A gentle practice to develop concentration and awareness through mindful breathing.',
    category: 'breathing',
    soundPath: require('../assets/meditations/PadraigTenMinuteMindfulnessOfBreathing.mp3'),
    attribution: 'Padraig O\'Morain',
    imageUrl: require('../../assets/meditation.mp3'), // Temporary placeholder
  }
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