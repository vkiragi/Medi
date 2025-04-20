import React, { useState, useEffect, useRef } from 'react';
import { StyleSheet, View, SafeAreaView, TouchableOpacity, Alert, Animated, Easing, ScrollView, Platform } from 'react-native';
import { Text, IconButton, useTheme, ProgressBar, Button } from 'react-native-paper';
import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { Audio } from 'expo-av';
import { RootStackParamList } from '../types';
import Svg, { Circle, G, LinearGradient, Stop, Defs } from 'react-native-svg';

// Create animated components
const AnimatedCircle = Animated.createAnimatedComponent(Circle);

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

type MeditationPlayerScreenRouteProp = RouteProp<RootStackParamList, 'MeditationPlayer'>;
type MeditationPlayerScreenNavigationProp = StackNavigationProp<RootStackParamList, 'MeditationPlayer'>;

interface MeditationPlayerScreenProps {
  route: MeditationPlayerScreenRouteProp;
  navigation: MeditationPlayerScreenNavigationProp;
}

const formatTime = (seconds: number): string => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs < 10 ? '0' : ''}${secs}`;
};

const CIRCLE_LENGTH = 1000; // Circumference of circle
const CIRCLE_RADIUS = CIRCLE_LENGTH / (2 * Math.PI);

const MeditationPlayerScreen = ({ route, navigation }: MeditationPlayerScreenProps) => {
  const { meditation } = route.params;
  const theme = useTheme();
  
  // Use refs for timers and intervals
  const soundRef = useRef<Audio.Sound | null>(null);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const animationRef = useRef<Animated.CompositeAnimation | null>(null);
  
  // Create animated values for continuous animations
  const circleProgressAnimation = useRef(new Animated.Value(0)).current;
  const barProgressAnimation = useRef(new Animated.Value(0)).current;
  
  const [isPlaying, setIsPlaying] = useState(false);
  const [timeRemaining, setTimeRemaining] = useState(meditation.duration * 60);
  const [timeElapsed, setTimeElapsed] = useState(0);
  const [audioLoaded, setAudioLoaded] = useState(false);
  const [audioLoadError, setAudioLoadError] = useState(false);
  const [loadingAudio, setLoadingAudio] = useState(true);
  const totalTime = meditation.duration * 60;
  
  // Map the circleProgressAnimation to the dashoffset for continuous animation
  const circleDashoffset = circleProgressAnimation.interpolate({
    inputRange: [0, totalTime],
    outputRange: [CIRCLE_LENGTH, 0],
    extrapolate: 'clamp'
  });
  
  // Keep barWidth for now to avoid breaking functionality
  const barWidth = barProgressAnimation.interpolate({
    inputRange: [0, totalTime],
    outputRange: ['0%', '100%'],
    extrapolate: 'clamp'
  });

  // Setup and manage the continuous animation
  const setupContinuousAnimations = () => {
    // Cancel any existing animations
    if (animationRef.current) {
      animationRef.current.stop();
    }
    
    // Calculate how much time is left
    const remainingTime = totalTime - timeElapsed;
    
    // Create a continuous animation for the circle
    animationRef.current = Animated.timing(circleProgressAnimation, {
      toValue: totalTime, // Target is full completion
      duration: remainingTime * 1000, // Convert seconds to milliseconds
      easing: Easing.linear, // Linear easing for continuous movement
      useNativeDriver: false, // We need to animate SVG properties which require JS driver
    });
    
    // Update the barProgressAnimation value (even though we won't display it)
    barProgressAnimation.setValue(timeElapsed);
  };

  // Effect to control animations when play/pause state changes
  useEffect(() => {
    if (isPlaying) {
      // Setup fresh animations from the current position
      setupContinuousAnimations();
      // Start the animations
      if (animationRef.current) {
        animationRef.current.start();
      }
    } else {
      // Pause the animations by stopping them at current position
      if (animationRef.current) {
        animationRef.current.stop();
      }
    }
    
    return () => {
      if (animationRef.current) {
        animationRef.current.stop();
      }
    };
  }, [isPlaying]);

  // When timeElapsed changes (like during skip or reset), update animations
  useEffect(() => {
    // Update the current animation values to match timeElapsed
    circleProgressAnimation.setValue(timeElapsed);
    barProgressAnimation.setValue(timeElapsed);
    
    // If we're currently playing, restart the animations from this new position
    if (isPlaying) {
      setupContinuousAnimations();
      if (animationRef.current) {
        animationRef.current.start();
      }
    }
  }, [timeElapsed]);

  // Load audio and set up Audio session
  useEffect(() => {
    const setupAudio = async () => {
      try {
        setLoadingAudio(true);
        // Configure audio session
        await Audio.setAudioModeAsync({
          allowsRecordingIOS: false,
          staysActiveInBackground: true,
          playsInSilentModeIOS: true,
          shouldDuckAndroid: true,
          playThroughEarpieceAndroid: false
        });
        
        // Create a new sound object
        const sound = new Audio.Sound();
        
        try {
          // Load from local asset using soundPath
          if (meditation.soundPath) {
            await sound.loadAsync(meditation.soundPath);
          } else {
            // Fallback to default audio
            await sound.loadAsync(require('../../assets/meditation.mp3'));
          }
          
          soundRef.current = sound;
          
          // Set looping behavior - we don't want looping for meditation
          await sound.setIsLoopingAsync(false);
          // Set appropriate volume
          await sound.setVolumeAsync(0.8);
          
          setAudioLoaded(true);
          setAudioLoadError(false);
        } catch (error) {
          console.error('Error loading audio:', error);
          setAudioLoadError(true);
        }
      } catch (error) {
        console.error('Error setting up audio:', error);
        setAudioLoadError(true);
      } finally {
        setLoadingAudio(false);
      }
    };
    
    setupAudio();
    
    // Cleanup function
    return () => {
      if (soundRef.current) {
        soundRef.current.unloadAsync();
      }
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
      if (animationRef.current) {
        animationRef.current.stop();
      }
    };
  }, []);
  
  // Timer effect
  useEffect(() => {
    if (isPlaying && timeRemaining > 0) {
      // Clear any existing interval
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
      
      // Create new interval
      intervalRef.current = setInterval(() => {
        setTimeRemaining(prev => {
          if (prev <= 1) {
            // If time is about to run out, clear interval and handle completion
            if (intervalRef.current) {
              clearInterval(intervalRef.current);
            }
            handleComplete();
            return 0;
          }
          return prev - 1;
        });
        setTimeElapsed(prev => prev + 1);
      }, 1000);
    } else if (!isPlaying && intervalRef.current) {
      // If not playing, clear the interval
      clearInterval(intervalRef.current);
    }
    
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [isPlaying]);
  
  // Handle play/pause
  const togglePlayPause = async () => {
    try {
      if (!soundRef.current || !audioLoaded) return;
      
      if (isPlaying) {
        await soundRef.current.pauseAsync();
        setIsPlaying(false);
      } else {
        await soundRef.current.playAsync();
        setIsPlaying(true);
      }
    } catch (error) {
      console.error('Error toggling playback:', error);
      Alert.alert('Playback Error', 'Could not play or pause meditation.');
    }
  };
  
  // Handle reset
  const handleReset = async () => {
    try {
      if (soundRef.current && audioLoaded) {
        await soundRef.current.stopAsync();
        await soundRef.current.playFromPositionAsync(0);
        if (!isPlaying) {
          await soundRef.current.pauseAsync();
        }
      }
      
      // Reset timer states
      setTimeRemaining(totalTime);
      setTimeElapsed(0);
      
      // Immediately reset the animations to starting position
      circleProgressAnimation.setValue(0);
      barProgressAnimation.setValue(0);
      
      // Setup animations from the beginning if playing
      if (isPlaying) {
        setupContinuousAnimations();
        if (animationRef.current) {
          animationRef.current.start();
        }
      }
    } catch (error) {
      console.error('Error resetting playback:', error);
    }
  };
  
  // Handle skip forward (5 seconds)
  const handleSkipForward = async () => {
    // Calculate new times
    const skipAmount = 5; // seconds to skip
    
    // Don't allow skipping past the end
    if (timeRemaining <= skipAmount) {
      handleComplete();
      return;
    }
    
    // Update timers
    const newTimeRemaining = timeRemaining - skipAmount;
    const newTimeElapsed = timeElapsed + skipAmount;
    
    setTimeRemaining(newTimeRemaining);
    setTimeElapsed(newTimeElapsed);
    
    // Update animation values
    circleProgressAnimation.setValue(newTimeElapsed);
    barProgressAnimation.setValue(newTimeElapsed);
    
    // If playing, restart animations from new position
    if (isPlaying) {
      setupContinuousAnimations();
      if (animationRef.current) {
        animationRef.current.start();
      }
    }
    
    try {
      // For guided meditations, we need to properly seek within the audio file
      if (soundRef.current && audioLoaded) {
        const status = await soundRef.current.getStatusAsync();
        if (status.isLoaded) {
          // Get current position in milliseconds
          const currentPositionMs = status.positionMillis || 0;
          // Add skip amount (convert seconds to ms)
          const newPositionMs = currentPositionMs + (skipAmount * 1000);
          // Seek to new position
          await soundRef.current.setPositionAsync(newPositionMs);
          
          // If it wasn't playing, restart playback
          if (!status.isPlaying && isPlaying) {
            await soundRef.current.playAsync();
          }
        }
      }
    } catch (error) {
      console.error('Error seeking audio:', error);
    }
  };
  
  // Handle completion
  const handleComplete = async () => {
    try {
      if (soundRef.current && audioLoaded) {
        await soundRef.current.stopAsync();
      }
      setIsPlaying(false);
      
      // Stop the animations
      if (animationRef.current) {
        animationRef.current.stop();
      }
      
      Alert.alert('Session Complete', 'Your meditation session has completed.');
    } catch (error) {
      console.error('Error completing session:', error);
    }
  };
  
  // Handle back
  const handleBack = async () => {
    try {
      if (soundRef.current) {
        await soundRef.current.unloadAsync();
      }
      navigation.goBack();
    } catch (error) {
      console.error('Error navigating back:', error);
      navigation.goBack();
    }
  };

  // Retry loading audio
  const retryAudioLoading = () => {
    setAudioLoadError(false);
    setLoadingAudio(true);
    
    // Reset the soundRef
    if (soundRef.current) {
      soundRef.current.unloadAsync();
      soundRef.current = null;
    }
    
    // Rerun the setup effect
    const setupAudio = async () => {
      try {
        // Configure audio session
        await Audio.setAudioModeAsync({
          allowsRecordingIOS: false,
          staysActiveInBackground: true,
          playsInSilentModeIOS: true,
          shouldDuckAndroid: true,
          playThroughEarpieceAndroid: false
        });
        
        // Create a new sound object
        const sound = new Audio.Sound();
        
        try {
          // Load from local asset
          if (meditation.soundPath) {
            await sound.loadAsync(meditation.soundPath);
          } else {
            await sound.loadAsync(require('../../assets/meditation.mp3'));
          }
          
          soundRef.current = sound;
          await sound.setIsLoopingAsync(false);
          await sound.setVolumeAsync(0.8);
          setAudioLoaded(true);
          setAudioLoadError(false);
        } catch (error) {
          console.error('Error loading audio on retry:', error);
          setAudioLoadError(true);
        }
      } catch (error) {
        console.error('Error setting up audio on retry:', error);
        setAudioLoadError(true);
      } finally {
        setLoadingAudio(false);
      }
    };
    
    setupAudio();
  };
  
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <IconButton 
          icon="chevron-left" 
          size={30} 
          onPress={handleBack}
          iconColor={COLORS.dark}
        />
        <Text style={styles.headerTitle}>{meditation.name}</Text>
        <IconButton 
          icon="dots-vertical" 
          size={24} 
          onPress={() => {}}
          iconColor={COLORS.dark}
        />
      </View>
      
      {loadingAudio ? (
        <View style={styles.loadingContainer}>
          <Text style={styles.loadingText}>Loading audio...</Text>
          <ProgressBar indeterminate color={COLORS.primary} style={styles.loadingBar} />
        </View>
      ) : audioLoadError ? (
        <View style={styles.errorContainer}>
          <Text style={styles.errorTitle}>Unable to load audio</Text>
          <Text style={styles.errorMessage}>
            There was a problem loading the meditation audio.
            Please make sure you have the audio files in your assets folder.
          </Text>
          <Button 
            mode="contained" 
            onPress={retryAudioLoading}
            style={[styles.retryButton, {backgroundColor: COLORS.primary}]}
          >
            Retry
          </Button>
          <Button 
            mode="outlined" 
            onPress={handleBack}
            style={styles.backButton}
          >
            Go Back
          </Button>
        </View>
      ) : (
        <ScrollView 
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.timerContainerOuter}>
            <View style={styles.timerContainer}>
              <View style={styles.timerCircleContainer}>
                <Svg width="200" height="200" viewBox="0 0 200 200" style={styles.svg}>
                  <Defs>
                    <LinearGradient id="progressGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                      <Stop offset="0%" stopColor={COLORS.primary} />
                      <Stop offset="100%" stopColor={COLORS.accent2} />
                    </LinearGradient>
                  </Defs>
                  
                  {/* Background Circle */}
                  <Circle
                    cx="100"
                    cy="100"
                    r="90"
                    strokeWidth="8"
                    stroke={COLORS.lightPurple}
                    fill="transparent"
                  />
                  
                  {/* Progress Circle - Using AnimatedCircle for continuous animation */}
                  <G transform="rotate(-90, 100, 100)">
                    <AnimatedCircle
                      cx="100"
                      cy="100"
                      r="90"
                      strokeWidth="8"
                      stroke="url(#progressGradient)"
                      fill="transparent"
                      strokeDasharray={CIRCLE_LENGTH}
                      strokeDashoffset={circleDashoffset}
                      strokeLinecap="round"
                    />
                  </G>
                </Svg>
                
                <View style={styles.timerTextContainer}>
                  <Text style={styles.timerText}>{formatTime(timeRemaining)}</Text>
                  <Text style={styles.sessionText}>
                    {isPlaying ? 'Session in progress' : timeElapsed > 0 ? 'Session paused' : 'Ready to begin'}
                  </Text>
                </View>
              </View>
            </View>
            
            <View style={styles.controlsContainer}>
              <IconButton 
                icon="replay" 
                size={30} 
                onPress={handleReset}
                style={styles.controlButton}
                disabled={!audioLoaded}
                iconColor={COLORS.dark}
              />
              <TouchableOpacity 
                style={[styles.playButton, {
                  backgroundColor: audioLoaded ? COLORS.primary : '#cccccc'
                }]} 
                onPress={togglePlayPause}
                disabled={!audioLoaded}
              >
                <IconButton 
                  icon={isPlaying ? "pause" : "play"} 
                  size={34}
                  iconColor={COLORS.light}
                />
              </TouchableOpacity>
              <IconButton 
                icon="fast-forward" 
                size={30} 
                onPress={handleSkipForward}
                style={styles.controlButton}
                disabled={!audioLoaded}
                iconColor={COLORS.dark}
              />
            </View>
          </View>

          <View style={styles.infoContainer}>
            <Text style={styles.infoTitle}>Mindfulness Tips</Text>
            
            <View style={styles.tipCard}>
              <IconButton 
                icon="meditation" 
                size={24} 
                iconColor={COLORS.primary}
                style={styles.tipIcon}
              />
              <Text style={styles.tipText}>Focus on your breathing, in and out</Text>
            </View>
            
            <View style={styles.tipCard}>
              <IconButton 
                icon="brain" 
                size={24} 
                iconColor={COLORS.accent1}
                style={styles.tipIcon}
              />
              <Text style={styles.tipText}>When your mind wanders, gently bring it back</Text>
            </View>
            
            <View style={styles.tipCard}>
              <IconButton 
                icon="human" 
                size={24} 
                iconColor={COLORS.accent2}
                style={styles.tipIcon}
              />
              <Text style={styles.tipText}>Notice sensations in your body</Text>
            </View>
            
            <View style={styles.tipCard}>
              <IconButton 
                icon="clock-time-four" 
                size={24} 
                iconColor={COLORS.primary}
                style={styles.tipIcon}
              />
              <Text style={styles.tipText}>Be present in the moment</Text>
            </View>
          </View>
        </ScrollView>
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
    padding: 16,
  },
  scrollContent: {
    paddingBottom: 20,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
    paddingTop: 10,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: COLORS.text.primary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  timerContainerOuter: {
    backgroundColor: COLORS.light,
    borderRadius: 16,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 3,
    marginBottom: 20,
  },
  timerContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: 10,
  },
  timerCircleContainer: {
    width: 200,
    height: 200,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  svg: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
  timerTextContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  timerText: {
    fontSize: 42,
    fontWeight: 'bold',
    color: COLORS.text.primary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  sessionText: {
    marginTop: 6,
    fontSize: 14,
    color: COLORS.text.secondary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  controlsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 20,
    paddingTop: 15,
    borderTopWidth: 1,
    borderTopColor: COLORS.lightPurple,
  },
  controlButton: {
    marginHorizontal: 20,
  },
  playButton: {
    width: 64,
    height: 64,
    borderRadius: 32,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
    elevation: 8,
  },
  infoContainer: {
    backgroundColor: COLORS.light,
    borderRadius: 16,
    padding: 20,
    marginTop: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 3,
  },
  infoTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    color: COLORS.text.primary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  tipCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(242, 247, 255, 0.6)',
    borderRadius: 12,
    marginBottom: 10,
    padding: 8,
  },
  tipIcon: {
    margin: 0,
  },
  tipText: {
    flex: 1,
    fontSize: 15,
    color: COLORS.text.primary,
    paddingRight: 8,
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
    marginBottom: 20,
    color: COLORS.text.secondary,
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  loadingBar: {
    width: '100%',
    height: 6,
    borderRadius: 3,
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
    color: '#E53935',
    fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
  },
  errorMessage: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 30,
    lineHeight: 24,
    color: COLORS.text.secondary,
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
});

export default MeditationPlayerScreen; 