import { DefaultTheme } from 'react-native-paper';

// Dark/purple color palette inspired by Vercel's aesthetic
const palette = {
  // Primary colors
  primary: '#7928CA', // Vibrant purple
  secondary: '#FF0080', // Hot pink accent
  
  // Gradient colors
  gradientStart: '#0F0F0F', // Near black
  gradientMiddle: '#171717', // Dark gray
  gradientEnd: '#1F1F1F', // Medium gray
  
  // Dark theme base colors
  dark: '#000000', // Pure black
  darkGray: '#121212', // Near-black for cards
  mediumGray: '#272727', // Medium gray for surfaces
  light: '#FFFFFF', // White
  
  // Text colors
  textPrimary: '#FFFFFF', // White text
  textSecondary: '#A1A1A1', // Light gray text
  textMuted: '#777777', // Muted text
  
  // Background colors
  background: '#000000', // Black background
  backgroundAlt: '#121212', // Slightly lighter black
  cardBackground: 'rgba(30, 30, 30, 0.7)', // Translucent dark gray
  
  // Accent colors
  purple: {
    light: '#9D50BB', // Light purple
    medium: '#7928CA', // Medium purple
    dark: '#6633CC', // Dark purple
  },
  pink: '#FF0080', // Pink accent
  
  // UI colors
  playButtonBg: '#7928CA', // Purple play button
  lightPurple: 'rgba(121, 40, 202, 0.2)', // Translucent purple
  shadow: 'rgba(0, 0, 0, 0.5)', // Darker shadow for dark mode
  overlay: 'rgba(0, 0, 0, 0.7)', // Dark overlay
};

const theme = {
  ...DefaultTheme,
  dark: true,
  colors: {
    ...DefaultTheme.colors,
    primary: palette.primary,
    accent: palette.secondary,
    background: palette.background,
    surface: palette.darkGray,
    text: palette.textPrimary,
    placeholder: palette.textSecondary,
    backdrop: palette.overlay,
    disabled: '#444444',
    notification: palette.secondary,
    secondaryBackground: palette.backgroundAlt,
    card: palette.darkGray,
    success: '#50E3C2',
    error: '#FF4365',
    info: '#7928CA',
    warning: '#F5A623',
  },
  roundness: 16,
  animation: {
    scale: 1.0,
  },
  fonts: {
    ...DefaultTheme.fonts,
    regular: {
      fontFamily: 'System',
      fontWeight: 'normal',
    },
    medium: {
      fontFamily: 'System',
      fontWeight: '500' as '500',
    },
    light: {
      fontFamily: 'System',
      fontWeight: '300' as '300',
    },
    thin: {
      fontFamily: 'System',
      fontWeight: '100' as '100',
    },
  },
  // Common style elements
  commonStyles: {
    shadows: {
      default: {
        shadowColor: palette.shadow,
        shadowOffset: { width: 0, height: 10 },
        shadowOpacity: 0.5,
        shadowRadius: 20,
        elevation: 10,
      },
      intense: {
        shadowColor: palette.shadow,
        shadowOffset: { width: 0, height: 20 },
        shadowOpacity: 0.8,
        shadowRadius: 30,
        elevation: 25,
      },
    },
    gradients: {
      primary: [palette.gradientStart, palette.gradientMiddle, palette.gradientEnd] as const,
      purple: [palette.purple.dark, palette.purple.medium, palette.purple.light] as const,
      glow: [palette.primary, palette.secondary] as const,
    },
  },
  // Export palette directly
  palette,
};

export default theme; 