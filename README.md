# medi - Simple Meditation App

A beautiful, minimalist meditation app built with SwiftUI for iOS.

## Features

- **Meditation Timer**: Choose from preset durations (5, 10, 15, 20 minutes)
- **Breathing Animation**: Visual breathing guide that synchronizes with your meditation
- **Session Tracking**: Keep track of your meditation history and progress
- **Clean UI**: Minimalist design with soothing colors and smooth animations
- **Progress Stats**: View your total sessions, minutes meditated, and current streak

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.9+

## Getting Started

### Option 1: Open in Xcode (Recommended)

1. Open Xcode
2. Select "Create New Project"
3. Choose "App" under iOS
4. Name the project "medi"
5. Copy all files from `Sources/medi/` to your Xcode project
6. Build and run on simulator or device

### Option 2: Using Swift Package Manager

1. Open the project folder in Terminal
2. Run: `swift build`
3. Open Package.swift in Xcode

## Project Structure

```
medi-app/
├── Sources/
│   └── medi/
│       ├── MediApp.swift          # App entry point
│       ├── Models/
│       │   └── MeditationManager.swift  # Core meditation logic
│       └── Views/
│           ├── ContentView.swift   # Main tab view
│           ├── MeditationView.swift # Meditation timer interface
│           └── HistoryView.swift   # Session history
├── Package.swift
└── README.md
```

## How to Use

1. **Select Duration**: Choose your preferred meditation duration (5, 10, 15, or 20 minutes)
2. **Start Meditation**: Tap the "Start" button to begin your session
3. **Breathing Guide**: Follow the expanding and contracting circle for breathing rhythm
4. **Pause/Resume**: Use the pause button if you need a break
5. **View History**: Check the History tab to see your completed sessions and progress

## Design Philosophy

The app follows a minimalist design approach with:
- Soft, calming color palette
- Smooth animations for better user experience
- Clean typography
- Intuitive navigation

## Future Enhancements

- Background sounds/music
- Guided meditation sessions
- Custom duration settings
- Daily reminders
- Export meditation data
- Apple Health integration

## License

This project is available for personal use and learning purposes. 