# Guided Meditation Audio Files

This directory contains the audio files used for guided meditations in the app.

## Audio Files Structure

The app expects audio files to be named according to this convention:

1. `meditation_1.mp3` - Morning Calm meditation
2. `meditation_2.mp3` - Stress Relief meditation
3. `meditation_3.mp3` - Deep Sleep meditation
4. `meditation_4.mp3` - Focus & Clarity meditation
5. `meditation_5.mp3` - Gratitude Practice meditation

## Getting Sample Audio Files

We provide two scripts to help you get sample audio files:

1. `download_sample_audio.sh` - Downloads free public domain sounds from NASA as placeholders
   - Run with: `cd medi-xcode/medi/Resources && ./download_sample_audio.sh`
   - These are just placeholders (space sounds), not actual guided meditations

2. `GuidedMeditations/create_placeholder_audio.sh` - Creates text-to-speech guided meditations
   - Run with: `cd medi-xcode/medi/Resources/GuidedMeditations && ./create_placeholder_audio.sh`
   - Requires macOS (uses the `say` command) and ffmpeg installed

## Adding Your Own Audio Files

If you want to replace the default meditation audio with your own:

1. Rename your audio files to match the naming convention above
2. Right-click on the "Resources" group in Xcode
3. Select "Add Files to 'medi'..."
4. Navigate to your audio files
5. Select the files you want to add
6. Make sure "Copy items if needed" and "Add to targets: medi" are checked
7. Click "Add"

## Including Audio Files in the App Bundle

To ensure these files are included in the app bundle:
1. In Xcode, select the project in the navigator
2. Select the "medi" target
3. Go to "Build Phases" tab
4. Expand "Copy Bundle Resources"
5. Click the "+" button and add all your audio files

## Sample Audio Sources

You can obtain free guided meditation audio files from various sources:

- [Free Mindfulness Project](http://www.freemindfulness.org/download)
- [Insight Timer](https://insighttimer.com/)
- [Mindful.org](https://www.mindful.org/audio-resources-for-mindfulness-meditation/)

Or create your own guided meditation audio files using recording software. 