import SwiftUI

struct MoodRecommendationsView: View {
    let mood: MoodState
    let onDismiss: () -> Void
    
    @State private var recommendedMeditations: [GuidedMeditation] = []
    @State private var personalizedMessage: String = ""
    
    init(mood: MoodState, onDismiss: @escaping () -> Void) {
        self.mood = mood
        self.onDismiss = onDismiss
    }
    
    var body: some View {
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
                        // Mood Display
                        VStack(spacing: 15) {
                            Text(mood.emoji)
                                .font(.system(size: 60))
                            
                            Text("Feeling \(mood.rawValue)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(mood.color)
                        }
                        .padding(.top, 20)
                        
                        // AI Personalized Message
                        VStack(spacing: 15) {
                            HStack {
                                Text("🤖")
                                    .font(.title2)
                                Text("AI Recommendation")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            Text(personalizedMessage)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .padding(15)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.8))
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        // Recommended Meditations
                        VStack(spacing: 15) {
                            HStack {
                                Text("✨ Perfect for You")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            ForEach(recommendedMeditations, id: \.id) { meditation in
                                NavigationLink(destination: GuidedMeditationPlayerView(meditation: meditation)) {
                                    RecommendationCard(meditation: meditation, mood: mood)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                }
            }
        }
        .onAppear {
            loadRecommendations()
        }
    }
    
    private func loadRecommendations() {
        recommendedMeditations = MoodRecommendationEngine.getRecommendations(for: mood)
        personalizedMessage = MoodRecommendationEngine.getPersonalizedMessage(for: mood)
    }
}

struct RecommendationCard: View {
    let meditation: GuidedMeditation
    let mood: MoodState
    
    var body: some View {
        HStack(spacing: 15) {
            // Meditation Image
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            meditation.imageColor,
                            meditation.imageColor.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    VStack {
                        Text("🧘‍♀️")
                            .font(.title2)
                        Text("\(meditation.duration)m")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                )
            
            // Meditation Info
            VStack(alignment: .leading, spacing: 8) {
                Text(meditation.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(meditation.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("\(meditation.duration) minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // AI Match Score
                    HStack(spacing: 4) {
                        Text("🎯")
                            .font(.caption)
                        Text("Perfect Match")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(mood.color)
                    }
                }
            }
            
            Spacer()
            
            // Play Icon
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    MoodRecommendationsView(mood: .stressed) {
        print("Dismissed")
    }
} 