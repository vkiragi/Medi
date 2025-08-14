import SwiftUI

struct GuidedMeditationListView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    // Ambient soundscape meditations
    var guidedMeditations: [GuidedMeditation] {
        return createMeditations()
    }
    
    private func createMeditations() -> [GuidedMeditation] {
        var meditations: [GuidedMeditation] = []
        
        // Morning Calm
        meditations.append(contentsOf: [
            GuidedMeditation(
                id: "morning_calm_1",
                title: "Morning Calm",
                description: "Gentle ambient sounds to start your day peacefully",
                duration: 5,
                imageColor: Color(red: 0.4, green: 0.7, blue: 0.9),
                audioFileName: "morning-calm-236192"
            ),
            GuidedMeditation(
                id: "morning_calm_2",
                title: "Dawn Awakening",
                description: "Soft ambient tones for gentle morning meditation",
                duration: 8,
                imageColor: Color(red: 0.5, green: 0.8, blue: 0.9),
                audioFileName: "MP3 audio"
            ),
            GuidedMeditation(
                id: "morning_calm_3",
                title: "Morning Serenity",
                description: "Peaceful soundscape for mindful morning practice",
                duration: 10,
                imageColor: Color(red: 0.6, green: 0.7, blue: 0.9),
                audioFileName: "MP3 audio 2"
            ),
            GuidedMeditation(
                id: "morning_calm_4",
                title: "Daybreak Harmony",
                description: "Harmonious ambient sounds for morning clarity",
                duration: 12,
                imageColor: Color(red: 0.7, green: 0.6, blue: 0.9),
                audioFileName: "MP3 audio 3"
            )
        ])
        
        // Stress Relief
        meditations.append(contentsOf: [
            GuidedMeditation(
                id: "stress_relief_1",
                title: "Peace & Healing",
                description: "432Hz healing frequencies for deep relaxation",
                duration: 15,
                imageColor: Color(red: 0.8, green: 0.6, blue: 0.9),
                audioFileName: "meditation-peace-love-healing-432hz-music-prayer-aura-good-vibes-202323"
            ),
            GuidedMeditation(
                id: "stress_relief_2",
                title: "Nirvikalpa",
                description: "New age ambient meditation for inner peace",
                duration: 12,
                imageColor: Color(red: 0.7, green: 0.5, blue: 0.8),
                audioFileName: "nirvikalpa-new-age-ambient-meditative-227882"
            ),
            GuidedMeditation(
                id: "stress_relief_3",
                title: "Meditation Ambience",
                description: "Soothing ambient sounds for stress relief",
                duration: 10,
                imageColor: Color(red: 0.6, green: 0.4, blue: 0.7),
                audioFileName: "meditation-ambience-262905"
            ),
            GuidedMeditation(
                id: "stress_relief_4",
                title: "Aberdeen Soundscape",
                description: "Meditative ambient for learning and relaxing",
                duration: 18,
                imageColor: Color(red: 0.5, green: 0.3, blue: 0.6),
                audioFileName: "aberdeen-meditative-ambient-soundscape-for-learning-and-relaxing-95397"
            )
        ])
        
        // Focus and Clarity
        meditations.append(contentsOf: [
            GuidedMeditation(
                id: "focus_clarity_1",
                title: "Electronic Ambient",
                description: "Electronic ambient music for relaxation and focus",
                duration: 14,
                imageColor: Color(red: 0.5, green: 0.8, blue: 0.7),
                audioFileName: "electronic-ambient-music-for-relaxation-and-meditation-9362"
            ),
            GuidedMeditation(
                id: "focus_clarity_2",
                title: "Zen Oasis",
                description: "Zen-inspired ambient for mental clarity",
                duration: 16,
                imageColor: Color(red: 0.4, green: 0.7, blue: 0.6),
                audioFileName: "zen-oasis-165858"
            ),
            GuidedMeditation(
                id: "focus_clarity_3",
                title: "Ambient Documentary",
                description: "Peaceful background ambient for deep focus",
                duration: 12,
                imageColor: Color(red: 0.3, green: 0.6, blue: 0.5),
                audioFileName: "ambient-background-for-documentary-165920"
            ),
            GuidedMeditation(
                id: "focus_clarity_4",
                title: "Weightlessness",
                description: "Floating ambient sounds for mental clarity",
                duration: 18,
                imageColor: Color(red: 0.2, green: 0.5, blue: 0.4),
                audioFileName: "weightlessness-213970"
            )
        ])
        
        // Deep Sleep
        meditations.append(contentsOf: [
            GuidedMeditation(
                id: "deep_sleep_1",
                title: "Foetal Meditation",
                description: "Deep relaxation meditation for sleep",
                duration: 20,
                imageColor: Color(red: 0.4, green: 0.5, blue: 0.8),
                audioFileName: "foetal-meditation-for-sleep-amp-relaxation-22029"
            ),
            GuidedMeditation(
                id: "deep_sleep_2",
                title: "Full Moon Relaxation",
                description: "Zen positive sleep music for deep rest",
                duration: 25,
                imageColor: Color(red: 0.3, green: 0.4, blue: 0.7),
                audioFileName: "full-moon-deep-relaxation-meditation-yoga-zen-positive-sleep-music-140639"
            ),
            GuidedMeditation(
                id: "deep_sleep_3",
                title: "Inner Peace",
                description: "Meditation for inner peace and sleep",
                duration: 15,
                imageColor: Color(red: 0.2, green: 0.3, blue: 0.6),
                audioFileName: "inner-peace-meditation-106798"
            ),
            GuidedMeditation(
                id: "deep_sleep_4",
                title: "Meditation Sounds",
                description: "Soothing meditation sounds for sleep",
                duration: 22,
                imageColor: Color(red: 0.1, green: 0.2, blue: 0.5),
                audioFileName: "meditation-sounds-122698"
            )
        ])
        
        // Gratitude Practice
        meditations.append(contentsOf: [
            GuidedMeditation(
                id: "gratitude_1",
                title: "Quiet Contemplation",
                description: "Peaceful meditation for gratitude practice",
                duration: 12,
                imageColor: Color(red: 0.9, green: 0.7, blue: 0.5),
                audioFileName: "quiet-contemplation-meditation-283536"
            ),
            GuidedMeditation(
                id: "gratitude_2",
                title: "Solitude",
                description: "Meditation for peaceful solitude and reflection",
                duration: 14,
                imageColor: Color(red: 0.8, green: 0.6, blue: 0.4),
                audioFileName: "solitude-meditation-14250"
            ),
            GuidedMeditation(
                id: "gratitude_3",
                title: "Vedic Meditations",
                description: "Ancient wisdom ambient for gratitude",
                duration: 16,
                imageColor: Color(red: 0.7, green: 0.5, blue: 0.3),
                audioFileName: "vedic-meditations-169182"
            ),
            GuidedMeditation(
                id: "gratitude_4",
                title: "Zen Garden",
                description: "Zen garden meditation for appreciation",
                duration: 18,
                imageColor: Color(red: 0.6, green: 0.4, blue: 0.2),
                audioFileName: "zen-garden-meditation-147712"
            )
        ])
        
        return meditations
    }
    
    @State private var selectedCategory = "All"
    @State private var showingPaywall = false
    let categories = ["All", "Morning Calm", "Stress Relief", "Deep Sleep", "Focus & Clarity", "Gratitude Practice"]
    
    // Filter meditations based on selected category
    var filteredMeditations: [GuidedMeditation] {
        if selectedCategory == "All" {
            return guidedMeditations
        }
        
        return guidedMeditations.filter { meditation in
            switch selectedCategory {
            case "Morning Calm":
                return meditation.id.hasPrefix("morning_calm")
            case "Stress Relief":
                return meditation.id.hasPrefix("stress_relief")
            case "Deep Sleep":
                return meditation.id.hasPrefix("deep_sleep")
            case "Focus & Clarity":
                return meditation.id.hasPrefix("focus_clarity")
            case "Gratitude Practice":
                return meditation.id.hasPrefix("gratitude")
            default:
                return true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if !subscriptionManager.isSubscribed {
                        UpsellHeader { showingPaywall = true }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                    }
                    
                    // Category selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.system(size: 16, weight: selectedCategory == category ? .medium : .regular))
                                        .foregroundColor(selectedCategory == category ? .white : Color(red: 0.5, green: 0.5, blue: 0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color(red: 0.6, green: 0.7, blue: 0.9) : Color.clear)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                    
                    // Meditations list
                    ScrollView {
                        VStack(spacing: 20) {
                            if filteredMeditations.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "music.note")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                    
                                    Text("No meditations found")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                    
                                    Text("Try selecting a different category")
                                        .font(.body)
                                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                                }
                                .padding(.vertical, 60)
                            } else {
                                ForEach(filteredMeditations) { meditation in
                                    NavigationLink(destination: destinationView(for: meditation)) {
                                        GuidedMeditationCard(meditation: meditation)
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        if !subscriptionManager.isSubscribed { showingPaywall = true }
                                    })
                                    .disabled(!subscriptionManager.isSubscribed)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Meditations")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }
    
    @ViewBuilder
    private func destinationView(for meditation: GuidedMeditation) -> some View {
        if subscriptionManager.isSubscribed {
            GuidedMeditationPlayerView(meditation: meditation)
        } else {
            EmptyView()
        }
    }
}

private struct UpsellHeader: View {
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock the full meditation library")
                        .font(.headline)
                    Text("Get medi Premium for AI plans and all sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
    }
}

struct GuidedMeditationCard: View {
    let meditation: GuidedMeditation
    
    var body: some View {
        HStack(spacing: 15) {
            // Meditation image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(meditation.imageColor)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "waveform")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            // Meditation details
            VStack(alignment: .leading, spacing: 5) {
                Text(meditation.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                
                Text(meditation.description)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    .lineLimit(2)
                
                Text("\(meditation.duration) min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Play button
            Image(systemName: "play.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                .padding(.trailing, 5)
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

 