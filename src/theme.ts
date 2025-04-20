import { DefaultTheme } from 'react-native-paper';

const theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#6A5ACD', // SlateBlue
    accent: '#9370DB', // MediumPurple
    background: '#F8F9FE',
    surface: '#FFFFFF',
    text: '#333333',
    placeholder: '#9E9E9E',
    backdrop: 'rgba(0, 0, 0, 0.4)',
    disabled: '#BDBDBD',
    notification: '#FF4081',
    secondaryBackground: '#EAE2F5',
    card: '#FFFFFF',
    success: '#4CAF50',
    error: '#F44336',
    info: '#2196F3',
    warning: '#FF9800',
  },
  roundness: 10,
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
};

export default theme; 