# Guided Meditations Content Structure

This directory contains organized meditation content for the medi app.

## 📁 Folder Structure

```
GuidedMeditations/
├── Morning Calm/          # Start-of-day practices
├── Stress Relief/         # Tension release and anxiety management
├── Deep Sleep/           # Sleep preparation and relaxation
├── Focus and Clarity/    # Concentration and mental clarity
├── Gratitude Practice/   # Appreciation and positive emotions
└── README.md            # This file
```

## 🎵 Content Guidelines

### Audio Requirements
- **Format:** MP3 (recommended) or M4A
- **Quality:** 128kbps minimum, 320kbps preferred
- **Mono/Stereo:** Stereo preferred for immersive experience
- **Normalization:** -16 LUFS for consistent volume

### Naming Convention
- Use descriptive filenames: `category_theme_duration.mp3`
- Examples:
  - `morning_breath_awareness_5min.mp3`
  - `stress_body_scan_15min.mp3`
  - `sleep_progressive_relaxation_20min.mp3`

### Duration Recommendations
- **Short Sessions:** 3-10 minutes (quick practice)
- **Medium Sessions:** 10-20 minutes (standard practice)
- **Long Sessions:** 20+ minutes (deep practice)

## 📋 Integration Steps

After adding content:

1. **Add files to Xcode:**
   - Drag and drop audio files into appropriate category folders
   - Ensure "Copy items if needed" is checked
   - Select "Add to targets: medi"

2. **Update code:**
   - Modify `GuidedMeditationListView.swift` to reference new files
   - Update `PlanPlaybackResolver.swift` mapping if needed
   - Test audio playback in app

3. **Metadata (Optional):**
   - Create `GuidedMeditations.json` for track metadata
   - Include title, description, duration, category, attribution

## ⚖️ Licensing Requirements

All content must comply with:
- ✅ **Commercial use** permitted
- ✅ **App distribution** rights included
- ✅ **Modification** rights (if needed for processing)
- ✅ **Attribution** provided (if required)

### Acceptable Sources
- ✅ Original commissioned content
- ✅ AI-generated TTS with commercial license
- ✅ Stock audio with app distribution rights
- ✅ Public domain content
- ✅ Creative Commons with commercial permissions

### Unacceptable Sources
- ❌ Copyrighted content without permission
- ❌ Non-commercial or personal-use-only licenses
- ❌ Content that restricts app distribution
- ❌ Unauthorized recordings or samples

## 🔄 Next Steps

1. Add properly licensed audio files to category folders
2. Update `GuidedMeditationListView.swift` with new content
3. Test in app to ensure proper playback
4. Consider implementing metadata system for better organization
