# Guided Meditation Audio Files

This directory contains the audio files used for guided meditations in the app.

## Audio Files Naming Convention

The app looks for audio files with these names:

1. `meditation_1.mp3` - Morning Calm meditation
2. `meditation_2.mp3` - Stress Relief meditation
3. `meditation_3.mp3` - Deep Sleep meditation
4. `meditation_4.mp3` - Focus & Clarity meditation
5. `meditation_5.mp3` - Gratitude Practice meditation

## Audio File Locations

Your audio files should be placed in one of these locations:
- Directly in the Resources directory
- In the Resources/Audio directory (preferred)

## Including Audio Files in the App Bundle

To ensure these files are included in the app bundle:
1. In Xcode, select the project in the navigator
2. Select the "medi" target
3. Go to "Build Phases" tab
4. Expand "Copy Bundle Resources"
5. Verify your audio files are listed there 