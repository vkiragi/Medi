import SwiftUI

public struct MoodRecommendationsView: View {
    let mood: MoodState
    let onDismiss: () -> Void
    
    @State private var recommendedMeditations: [GuidedMeditation] = []
    @State private var personalizedMessage: String = ""
    
    public init(mood: MoodState, onDismiss: @escaping () -> Void) {
        self.mood = mood
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.95, blue: 1.0),
                        Color(red: 0.85, green: 0.85, blue: 0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header with mood
                        VStack(spacing: 15) {
                            HStack {
                                Text(mood.emoji)
                                    .font(.system(size: 50))
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Feeling \(mood.rawValue.lowercased())")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                    
                                    Text("Here's what I recommend")
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            // AI personalized message
                            Text(personalizedMessage)
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(mood.color.opacity(0.1))
                                )
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // Recommended meditations
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("🤖 AI Recommendations")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                
                                Spacer()
                                
                                Text("\(MoodBasedRecommendations.getOptimalDuration(for: mood)) min")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(red: 0.9, green: 0.9, blue: 0.95))
                                    )
                            }
                            .padding(.horizontal, 20)
                            
                            ForEach(recommendedMeditations) { meditation in
                                NavigationLink(destination: GuidedMeditationPlayerView(meditation: meditation)) {
                                    RecommendedMeditationCard(meditation: meditation, mood: mood)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Browse all option
                        Button(action: onDismiss) {
                            HStack {
                                Text("Browse All Meditations")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(red: 0.6, green: 0.7, blue: 0.9), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    onDismiss()
                }
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
            )
        }
        .onAppear {
            loadRecommendations()
        }
    }
    
    private func loadRecommendations() {
        // Get AI recommendations for this mood
        let recommendedIds = MoodBasedRecommendations.getRecommendationsFor(mood: mood)
        
        // Get the full meditation objects (from your existing list)
        let allMeditations = [
            GuidedMeditation(
                id: "1",
                title: "Morning Calm",
                description: "Start your day with a peaceful meditation",
                duration: 3,
                imageColor: Color(red: 0.4, green: 0.7, blue: 0.9),
                audioFileName: "breathing_meditation"
            ),
            GuidedMeditation(
                id: "2",
                title: "Stress Relief",
                description: "Release tension and find your center",
                duration: 5,
                imageColor: Color(red: 0.8, green: 0.6, blue: 0.9),
                audioFileName: "meditation_5min_marc"
            ),
            GuidedMeditation(
                id: "3",
                title: "Deep Sleep",
                description: "Prepare your mind and body for restful sleep",
                duration: 5,
                imageColor: Color(red: 0.4, green: 0.5, blue: 0.8),
                audioFileName: "meditation_5min_life_happens"
            ),
            GuidedMeditation(
                id: "4",
                title: "Focus & Clarity",
                description: "Sharpen your mind for better concentration",
                duration: 6,
                imageColor: Color(red: 0.5, green: 0.8, blue: 0.7),
                audioFileName: "meditation_6min_stillmind"
            ),
            GuidedMeditation(
                id: "5",
                title: "Gratitude Practice",
                description: "Cultivate appreciation and positivity",
                duration: 10,
                imageColor: Color(red: 0.9, green: 0.7, blue: 0.5),
                audioFileName: "meditation_10min_breathing"
            )
        ]
        
        // Filter to recommended meditations
        recommendedMeditations = allMeditations.filter { meditation in
            recommendedIds.contains(meditation.id)
        }
        
        // Get personalized AI message
        personalizedMessage = MoodBasedRecommendations.getPersonalizedMessage(for: mood)
    }
}

struct RecommendedMeditationCard: View {
    let meditation: GuidedMeditation
    let mood: MoodState
    
    var body: some View {
        HStack(spacing: 15) {
            // Meditation image with AI badge
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(meditation.imageColor)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "waveform")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
                
                // AI recommendation badge
                Circle()
                    .fill(mood.color)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("🤖")
                            .font(.system(size: 10))
                    )
                    .offset(x: 5, y: -5)
            }
            
            // Meditation details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(meditation.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                    
                    Spacer()
                    
                    Text("\(meditation.duration) min")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.95, green: 0.95, blue: 0.98))
                        )
                }
                
                Text(meditation.description)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    .lineLimit(2)
                
                // Why this helps with your mood
                Text(whyRecommendedText())
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(mood.color)
                    .italic()
            }
            
            // Play indicator
            Image(systemName: "play.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(mood.color)
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func whyRecommendedText() -> String {
        switch mood {
        case .stressed:
            return "Perfect for releasing tension"
        case .anxious:
            return "Helps ground anxious thoughts"
        case .tired:
            return "Gentle energy restoration"
        case .energetic:
            return "Channels your energy mindfully"
        case .calm:
            return "Deepens your peaceful state"
        case .sad:
            return "Nurtures emotional healing"
        case .excited:
            return "Focuses excited energy"
        case .overwhelmed:
            return "Clears mental clutter"
        }
    }
} 