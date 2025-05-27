#!/bin/bash

# This script downloads free sample meditation audio files from a public domain source
# and renames them to match the app's naming convention

# Create GuidedMeditations directory if it doesn't exist
mkdir -p GuidedMeditations

cd GuidedMeditations

echo "Downloading sample meditation audio files..."

# Sample URLs for free meditation audio
# These are examples using NASA sounds which are in the public domain
# Replace with actual meditation audio URLs as needed

# Morning Calm meditation
curl -L "https://www.nasa.gov/wp-content/uploads/2016/11/sputnik_beep_beep.mp3" -o meditation_1.mp3

# Stress Relief meditation
curl -L "https://www.nasa.gov/wp-content/uploads/2016/11/cassini_saturn_radio_emissions_1.mp3" -o meditation_2.mp3

# Deep Sleep meditation
curl -L "https://www.nasa.gov/wp-content/uploads/2016/11/voyager_jupiter_lightning.mp3" -o meditation_3.mp3

# Focus & Clarity meditation
curl -L "https://www.nasa.gov/wp-content/uploads/2016/11/pia21073.mp3" -o meditation_4.mp3

# Gratitude Practice meditation
curl -L "https://www.nasa.gov/wp-content/uploads/2016/11/kepler_star_KIC12268220C.mp3" -o meditation_5.mp3

echo "Sample audio files downloaded successfully!"
echo "Note: These are placeholder sound files. Replace with actual guided meditation audio for production." 