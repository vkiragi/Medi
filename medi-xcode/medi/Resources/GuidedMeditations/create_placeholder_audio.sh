#!/bin/bash

# This script creates placeholder audio files for guided meditations
# It uses the macOS 'say' command to generate voice audio

# Create Morning Calm meditation
say -v Samantha "Welcome to the Morning Calm meditation. This is a placeholder for a real guided meditation. Take a deep breath in, and slowly exhale. Continue breathing deeply for the next few minutes." -o morning_calm.aiff
ffmpeg -i morning_calm.aiff -acodec libmp3lame -ab 128k -ac 2 meditation_1.mp3
rm morning_calm.aiff

# Create Stress Relief meditation
say -v Samantha "Welcome to the Stress Relief meditation. This is a placeholder for a real guided meditation. Imagine the tension leaving your body with each breath. Feel your muscles relaxing as you continue to breathe deeply." -o stress_relief.aiff
ffmpeg -i stress_relief.aiff -acodec libmp3lame -ab 128k -ac 2 meditation_2.mp3
rm stress_relief.aiff

# Create Deep Sleep meditation
say -v Samantha "Welcome to the Deep Sleep meditation. This is a placeholder for a real guided meditation. Allow your body to sink deeply into relaxation as you prepare for restful sleep. With each breath, you're becoming more and more relaxed." -o deep_sleep.aiff
ffmpeg -i deep_sleep.aiff -acodec libmp3lame -ab 128k -ac 2 meditation_3.mp3
rm deep_sleep.aiff

# Create Focus & Clarity meditation
say -v Samantha "Welcome to the Focus and Clarity meditation. This is a placeholder for a real guided meditation. As you breathe, feel your mind becoming sharper and more alert. With each breath, your concentration improves." -o focus_clarity.aiff
ffmpeg -i focus_clarity.aiff -acodec libmp3lame -ab 128k -ac 2 meditation_4.mp3
rm focus_clarity.aiff

# Create Gratitude Practice meditation
say -v Samantha "Welcome to the Gratitude Practice meditation. This is a placeholder for a real guided meditation. Take a moment to reflect on the things you're grateful for in your life. As you breathe, feel appreciation filling your heart." -o gratitude.aiff
ffmpeg -i gratitude.aiff -acodec libmp3lame -ab 128k -ac 2 meditation_5.mp3
rm gratitude.aiff

echo "Placeholder audio files created successfully." 