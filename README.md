# medi - iOS Meditation App

A beautiful, minimalist meditation app built with SwiftUI for iOS.

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-14.0+-blue.svg)

## ✨ Features

- **Timer Meditation**: Choose from preset durations (5, 10, 15, 20 minutes)
- **Guided Meditations**: 6 different guided sessions (3-10 minutes)
  - 3-Minute Breathing - Gentle introduction
  - Life Happens Breathing (5 min) - For stressful moments
  - MARC Breathing (5 min) - Mindfulness-based practice
  - Still Mind Breath Awareness (6 min) - Cultivating awareness
  - 10-Minute Breathing - Extended session
  - Padraig's Mindfulness (10 min) - Mindfulness of breathing
- **Breathing Animation**: Visual breathing guide that synchronizes with meditation
- **Session Tracking**: Keep track of meditation history and progress
- **Progress Stats**: View total sessions, minutes meditated, and current streak
- **Clean UI**: Minimalist design with soothing colors and smooth animations

## 📱 Screenshots

The app features three main tabs:
- **Meditate**: Silent timer with breathing animation
- **Guided**: List of guided meditation sessions with audio playback
- **History**: Track your meditation progress and streaks

## 🚀 Getting Started

### Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.9+

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/vkiragi/Medi.git
   cd Medi
   ```

2. **Open in Xcode**:
   ```bash
   open medi-xcode/medi.xcodeproj
   ```

3. **Build and Run**:
   - Select an iPhone simulator
   - Press `Cmd + R` or click the Play button

### Quick Setup Script

Alternatively, use the provided setup script:
```bash
./open_medi.sh
```

## 🏗️ Project Structure

```
medi-app/
├── medi-xcode/
│   └── medi.xcodeproj          # Main Xcode project
│   └── medi/
│       ├── Models/
│       │   ├── MeditationManager.swift    # Timer logic
│       │   ├── AudioManager.swift         # Audio playback
│       │   └── GuidedMeditation.swift     # Meditation data
│       ├── Views/
│       │   ├── MeditationView.swift       # Timer interface
│       │   ├── GuidedMeditationListView.swift
│       │   ├── GuidedMeditationPlayerView.swift
│       │   └── HistoryView.swift          # Session history
│       └── *.mp3                          # Guided meditation audio files
├── README.md
└── setup scripts
```

## 🎯 How to Use

1. **Timer Meditation**:
   - Select your preferred duration (5, 10, 15, or 20 minutes)
   - Tap "Start" to begin
   - Follow the breathing circle animation
   - Use pause/resume as needed

2. **Guided Meditation**:
   - Browse available guided sessions
   - Tap a session to open the player
   - Press play to start the guided meditation
   - Follow along with the breathing circle

3. **Track Progress**:
   - View your meditation history in the History tab
   - See total sessions, minutes, and current streak
   - All sessions are automatically saved

## 🎨 Design Philosophy

The app follows a minimalist design approach with:
- Soft, calming color palette (purple/blue tones)
- Smooth animations for better user experience
- Clean typography and intuitive navigation
- Breathing circle that guides meditation rhythm

## 🔧 Technical Details

- **Architecture**: MVVM pattern with SwiftUI
- **Audio**: AVFoundation for guided meditation playback
- **Data Persistence**: UserDefaults for session history
- **Animations**: SwiftUI animations for breathing guidance
- **Navigation**: Tab-based interface with NavigationView

## 🚧 Future Enhancements

- [ ] Background sounds/ambient music
- [ ] Custom duration settings
- [ ] Daily meditation reminders
- [ ] Apple Health integration
- [ ] Export meditation data
- [ ] More guided meditation categories
- [ ] Dark mode support
- [ ] Apple Watch companion app

## 📄 License

This project is available for personal use and learning purposes.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

---

**Happy meditating!** 🧘‍♀️✨ 