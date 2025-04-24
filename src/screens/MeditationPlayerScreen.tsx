import React, { useState, useEffect, useCallback } from 'react';
import { StyleSheet, View, SafeAreaView, TouchableOpacity, Alert, Platform, StatusBar, ActivityIndicator } from 'react-native';
import { Text, IconButton, useTheme, Button } from 'react-native-paper';
import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import TrackPlayer, {
  usePlaybackState,
  useProgress,
  Capability,
  RepeatMode,
  State,
  Event,
  PlaybackState
} from 'react-native-track-player';
import Slider from '@react-native-community/slider';
import { AppStackParamList } from '../types';
import { LinearGradient as ExpoLinearGradient } from 'expo-linear-gradient';
import appTheme from '../theme';
import { recordMeditationSession, incrementPlayCount } from '../services/api';

// Get colors directly to avoid theme type issues
const primaryColor = '#7928CA'; // Vibrant purple
const secondaryColor = '#FF0080'; // Hot pink
const darkBg = '#000000'; // Black background
const darkCard = 'rgba(30, 30, 30, 0.7)'; // Translucent dark gray
const darkSurface = '#121212'; // Near-black surface
const lightPurple = 'rgba(121, 40, 202, 0.2)'; // Translucent light purple
const textPrimary = '#FFFFFF'; // White text
const textSecondary = '#A1A1A1'; // Light gray text

// Import these gradient colors directly
const DARK_GRADIENT_COLORS = ['#0F0F0F', '#171717', '#1F1F1F'] as const;
const PURPLE_ACCENT_GRADIENT = ['#6633CC', '#7928CA', '#9D50BB'] as const;

// Modern color palette
const COLORS = {
  primary: '#6C63FF',
  secondary: '#F2F7FF',
  accent1: '#FFAB91',
  accent2: '#4ECDC4',
  dark: '#3F3D56',
  light: '#FFFFFF',
  background: '#F8F9FE',
  lightPurple: '#EAE2F5',
  text: {
    primary: '#3F3D56',
    secondary: '#84838B',
  }
};

// Correctly type the route and navigation props using AppStackParamList
type MeditationPlayerScreenRouteProp = RouteProp<AppStackParamList, 'MeditationPlayer'>;
type MeditationPlayerScreenNavigationProp = StackNavigationProp<AppStackParamList, 'MeditationPlayer'>;

interface MeditationPlayerScreenProps {
  route: MeditationPlayerScreenRouteProp;
  navigation: MeditationPlayerScreenNavigationProp;
}

const formatTime = (seconds: number): string => {
  const mins = Math.floor(seconds / 60);
  const secs = Math.round(seconds % 60); // Use Math.round for better display
  return `${mins}:${secs < 10 ? '0' : ''}${secs}`;
};

const MeditationPlayerScreen = ({ route, navigation }: MeditationPlayerScreenProps) => {
  const { meditation } = route.params;
  const theme = useTheme();
  const playbackState = usePlaybackState();
  const playerState = playbackState.state;
  const { position, duration, buffered } = useProgress();

  const [isLoading, setIsLoading] = useState(true);
  const [isPlayerReady, setIsPlayerReady] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [sessionCompleted, setSessionCompleted] = useState(false);

  const isPlaying = playerState === State.Playing || playerState === State.Buffering;

  const setupPlayer = useCallback(async () => {
    setIsLoading(true);
    setLoadError(null);
    try {
      try {
          await TrackPlayer.getActiveTrack();
          await TrackPlayer.reset();
      } catch {
          await TrackPlayer.setupPlayer();
      }

      await TrackPlayer.updateOptions({
        capabilities: [
          Capability.Play,
          Capability.Pause,
          Capability.SeekTo,
        ],
        compactCapabilities: [Capability.Play, Capability.Pause, Capability.SeekTo],
        alwaysPauseOnInterruption: true,
      });

      let audioSource;
      if (meditation.soundPath) {
          try {
              audioSource = meditation.soundPath;
          } catch (e) {
              console.error("Could not resolve meditation.soundPath, falling back", e);
              audioSource = require('../../assets/meditation.mp3');
          }
      } else {
        audioSource = require('../../assets/meditation.mp3');
      }

      await TrackPlayer.add({
        id: meditation.id.toString(),
        url: audioSource,
        title: meditation.name,
        artist: 'Meditation App',
        duration: meditation.duration * 60,
      });

      await TrackPlayer.setRepeatMode(RepeatMode.Off);

      setIsPlayerReady(true);
      setLoadError(null);
    } catch (error: any) {
      console.error('Error setting up Track Player:', error);
      setLoadError(error.message || 'Failed to initialize audio player.');
      setIsPlayerReady(false);
    } finally {
      setIsLoading(false);
    }
  }, [meditation]);

  useEffect(() => {
    setupPlayer();

    return () => {
      TrackPlayer.reset();
    };
  }, [setupPlayer]);

  useEffect(() => {
    const listener = TrackPlayer.addEventListener(Event.PlaybackQueueEnded, (data) => {
      if (playerState !== State.Stopped && playerState !== State.None && data.position > 0 && !sessionCompleted) {
        console.log('[TrackPlayer] PlaybackQueueEnded, triggering handleComplete');
        handleComplete();
      }
    });
    return () => listener.remove();
  }, [sessionCompleted, playerState]);

  const togglePlayPause = async () => {
    if (!isPlayerReady || loadError) return;
    if (isPlaying) {
      await TrackPlayer.pause();
    } else {
      await TrackPlayer.play();
    }
  };

  const handleReset = async () => {
    if (!isPlayerReady || loadError) return;
    await TrackPlayer.seekTo(0);
    if (playerState !== State.Playing) {
       await TrackPlayer.pause();
    }
     setSessionCompleted(false);
  };

  const handleSkipForward = async () => {
    if (!isPlayerReady || loadError) return;
    const newPosition = Math.min(position + 5, duration);
    if (newPosition >= duration - 1 && duration > 0) {
        handleComplete();
    } else {
        await TrackPlayer.seekTo(newPosition);
    }
  };

  const handleSeek = async (value: number) => {
      if (!isPlayerReady || loadError) return;
      await TrackPlayer.seekTo(value);
  };

  const handleComplete = useCallback(async () => {
    if (sessionCompleted || !isPlayerReady) return;
    
    console.log('[handleComplete] Called');
    setSessionCompleted(true);

    try {
      await recordMeditationSession(
        meditation.id,
        meditation.duration * 60,
        true,
        ''
      );
      await incrementPlayCount(meditation.id);
      console.log('[MeditationPlayer] Session recorded successfully via handleComplete');

      Alert.alert(
        'Session Complete',
        'Your meditation session has completed. Great job!',
        [{ text: 'OK', onPress: () => navigation.goBack() }]
      );
    } catch (error) {
      console.error('[MeditationPlayer] Error recording session:', error);
       Alert.alert(
        'Completion Error',
        'Session finished, but there was an error recording your progress.',
        [{ text: 'OK', onPress: () => navigation.goBack() }]
      );
    }
  }, [meditation, navigation, isPlayerReady, sessionCompleted]);

  const handleBack = async () => {
    navigation.goBack();
  };

  const retryAudioLoading = () => {
    setupPlayer();
  };

  const timeRemaining = Math.max(0, duration - position);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      <ExpoLinearGradient
        colors={DARK_GRADIENT_COLORS}
        style={styles.background}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
      />
      
      <View style={styles.header}>
        <IconButton 
          icon="chevron-left" 
          size={28} 
          onPress={handleBack}
          iconColor="#FFFFFF"
          style={styles.backIcon}
        />
        <Text style={styles.headerTitle}>{meditation.name}</Text>
        <IconButton 
          icon="dots-vertical" 
          size={24} 
          onPress={() => {}}
          iconColor="#FFFFFF"
        />
      </View>
      
      <View style={styles.contentArea}>
        {isLoading ? (
          <View style={styles.loadingContainer}>
             <ActivityIndicator size="large" color={primaryColor} />
             <Text style={styles.loadingText}>Initializing player...</Text>
          </View>
        ) : loadError ? (
          <View style={styles.errorContainer}>
            <Text style={styles.errorTitle}>Audio Error</Text>
            <Text style={styles.errorMessage}>{loadError}</Text>
            <Button 
              mode="contained" 
              onPress={retryAudioLoading}
              buttonColor={primaryColor}
              style={styles.retryButton}
              textColor="#FFFFFF"
            >
              Retry
            </Button>
            <Button 
              mode="outlined" 
              onPress={handleBack}
              style={[styles.backButton, { borderColor: primaryColor }]}
              textColor={primaryColor}
            >
              Go Back
            </Button>
          </View>
        ) : (
          <>
            <View style={styles.timerContainerOuter}>
              <View style={styles.timerTextContainer}>
                <Text style={styles.timerText}>{formatTime(timeRemaining)}</Text>
                <Text style={styles.sessionText}>
                  {playerState === State.Playing ? 'Session in progress' :
                   playerState === State.Paused ? 'Session paused' :
                   playerState === State.Ready || playerState === State.Stopped || playerState === State.None ? 'Ready to begin' :
                   playerState === State.Buffering ? 'Buffering...' :
                   playerState === State.Connecting ? 'Connecting...' :
                   'Loading...'}
                </Text>
              </View>

              <Slider
                  style={styles.slider}
                  minimumValue={0}
                  maximumValue={duration > 0 ? duration : 1}
                  value={position}
                  minimumTrackTintColor={primaryColor}
                  maximumTrackTintColor={lightPurple}
                  thumbTintColor={primaryColor}
                  onSlidingComplete={handleSeek}
                  disabled={!isPlayerReady || duration <= 0}
              />
              
              <View style={styles.timeLabels}>
                   <Text style={styles.timeLabelText}>{formatTime(position)}</Text>
                   <Text style={styles.timeLabelText}>{formatTime(duration)}</Text>
               </View>

              <View style={styles.controlsContainer}>
                <IconButton 
                  icon="replay" 
                  size={28} 
                  onPress={handleReset}
                  style={styles.controlButton}
                  disabled={!isPlayerReady}
                  iconColor="#FFFFFF"
                />
                <TouchableOpacity 
                  style={[styles.playButton, { backgroundColor: isPlayerReady ? primaryColor : 'rgba(121, 40, 202, 0.4)' }]} 
                  onPress={togglePlayPause}
                  disabled={!isPlayerReady}
                >
                  <IconButton icon={isPlaying ? "pause" : "play"} size={30} iconColor="#FFFFFF"/>
                </TouchableOpacity>
                <IconButton 
                  icon="fast-forward" 
                  size={28} 
                  onPress={handleSkipForward}
                  style={styles.controlButton}
                  disabled={!isPlayerReady}
                  iconColor="#FFFFFF"
                />
              </View>
            </View>

            <View style={styles.infoContainer}>
              <Text style={styles.infoTitle}>Mindfulness Tips</Text>
              
              <View style={styles.tipCard}>
                <IconButton icon="meditation" size={20} iconColor={primaryColor} style={styles.tipIcon}/>
                <Text style={styles.tipText}>Focus on your breathing, in and out</Text>
              </View>
              
              <View style={styles.tipCard}>
                <IconButton icon="brain" size={20} iconColor={secondaryColor} style={styles.tipIcon}/>
                <Text style={styles.tipText}>When your mind wanders, gently bring it back</Text>
              </View>
              
              <View style={styles.tipCard}>
                <IconButton icon="human" size={20} iconColor="#5B7DE5" style={styles.tipIcon}/>
                <Text style={styles.tipText}>Notice sensations in your body</Text>
              </View>
              
              <View style={styles.tipCard}>
                <IconButton icon="clock-time-four" size={20} iconColor="#6A5ACD" style={styles.tipIcon}/>
                <Text style={styles.tipText}>Be present in the moment</Text>
              </View>
            </View>
          </>
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: darkBg,
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
    paddingTop: Platform.OS === 'ios' ? 4 : 0,
    paddingBottom: 12,
  },
  headerTitle: {
    flex: 1, 
    textAlign: 'center',
    fontSize: 20,
    fontWeight: 'bold',
    color: textPrimary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  backIcon: {
    margin: 0,
  },
  contentArea: {
    flex: 1,
    paddingHorizontal: 16, 
    paddingBottom: 10,
    justifyContent: 'space-around',
  },
  timerContainerOuter: {
    backgroundColor: darkCard,
    borderRadius: 16,
    padding: 20,
  },
  timerTextContainer: {
    alignItems: 'center',
    marginBottom: 15,
  },
  timerText: {
    fontSize: 42,
    fontWeight: 'bold',
    color: textPrimary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  sessionText: {
    marginTop: 4,
    fontSize: 13,
    color: textSecondary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  controlsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 20,
    paddingTop: 10,
    borderTopWidth: 1,
    borderTopColor: lightPurple,
  },
  controlButton: {
    marginHorizontal: 15,
  },
  playButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
  },
  infoContainer: {
    backgroundColor: darkCard,
    borderRadius: 16,
    padding: 15,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 10,
    color: textPrimary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  tipCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(40, 40, 40, 0.8)',
    borderRadius: 10,
    marginBottom: 8,
    padding: 6,
  },
  tipIcon: {
    margin: 0,
    marginRight: 8,
  },
  tipText: {
    flex: 1,
    fontSize: 14,
    color: textPrimary,
    paddingRight: 4,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 30,
  },
  loadingText: {
    fontSize: 18,
    marginTop: 15,
    color: textSecondary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 30,
  },
  errorTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#FF4365',
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  errorMessage: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 30,
    lineHeight: 24,
    color: textSecondary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  retryButton: {
    marginBottom: 16,
    paddingHorizontal: 30,
    paddingVertical: 6,
  },
  backButton: {
    paddingHorizontal: 30,
    paddingVertical: 6,
  },
  slider: {
    width: '100%',
    height: 40,
  },
  timeLabels: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
    paddingHorizontal: 5,
    marginTop: -5,
     marginBottom: 10,
  },
  timeLabelText: {
    fontSize: 12,
    color: textSecondary,
  },
});

export default MeditationPlayerScreen; 