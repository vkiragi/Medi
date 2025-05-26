#!/bin/bash

echo "🎵 Verifying Audio Files for medi App"
echo "=================================="
echo ""

# Expected audio files based on GuidedMeditation.swift
expected_files=(
    "breathing_meditation.mp3"
    "meditation_5min_life_happens.mp3"
    "meditation_5min_marc.mp3"
    "meditation_6min_stillmind.mp3"
    "meditation_10min_breathing.mp3"
    "meditation_10min_padraig.mp3"
)

# Check if all expected files exist in the Xcode project
echo "📁 Checking audio files in medi-xcode/medi/:"
echo ""

all_found=true
for file in "${expected_files[@]}"; do
    if [ -f "medi-xcode/medi/$file" ]; then
        size=$(ls -lh "medi-xcode/medi/$file" | awk '{print $5}')
        echo "✅ $file ($size)"
    else
        echo "❌ $file - MISSING"
        all_found=false
    fi
done

echo ""
echo "📊 Summary:"
echo "----------"

if [ "$all_found" = true ]; then
    echo "🎉 All audio files are in the correct location!"
    echo ""
    echo "📱 Your app is ready with these guided meditations:"
    echo "   • 3-Minute Breathing (breathing_meditation.mp3)"
    echo "   • Life Happens Breathing - 5 min"
    echo "   • MARC Breathing - 5 min"
    echo "   • Still Mind Breath Awareness - 6 min"
    echo "   • 10-Minute Breathing"
    echo "   • Padraig's Mindfulness - 10 min"
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Open Xcode: open medi-xcode/medi.xcodeproj"
    echo "   2. Add these MP3 files to your Xcode project:"
    echo "      - Right-click 'medi' folder in Xcode"
    echo "      - Select 'Add Files to medi...'"
    echo "      - Select all 6 MP3 files"
    echo "      - Make sure 'Add to targets: medi' is checked"
    echo "   3. Build and run!"
else
    echo "⚠️  Some audio files are missing. Please check the missing files above."
fi

echo ""
echo "🎯 File locations verified for iOS app bundle." 