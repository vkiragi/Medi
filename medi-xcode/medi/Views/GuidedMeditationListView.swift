import SwiftUI

struct GuidedMeditationListView: View {
    // Sample guided meditations
    let guidedMeditations = [
        GuidedMeditation(
            id: "1",
            title: "Morning Calm",
            description: "Start your day with a peaceful meditation",
            duration: 10,
            imageColor: Color(red: 0.4, green: 0.7, blue: 0.9)
        ),
        GuidedMeditation(
            id: "2",
            title: "Stress Relief",
            description: "Release tension and find your center",
            duration: 15,
            imageColor: Color(red: 0.8, green: 0.6, blue: 0.9)
        ),
        GuidedMeditation(
            id: "3",
            title: "Deep Sleep",
            description: "Prepare your mind and body for restful sleep",
            duration: 20,
            imageColor: Color(red: 0.4, green: 0.5, blue: 0.8)
        ),
        GuidedMeditation(
            id: "4",
            title: "Focus & Clarity",
            description: "Sharpen your mind for better concentration",
            duration: 12,
            imageColor: Color(red: 0.5, green: 0.8, blue: 0.7)
        ),
        GuidedMeditation(
            id: "5",
            title: "Gratitude Practice",
            description: "Cultivate appreciation and positivity",
            duration: 8,
            imageColor: Color(red: 0.9, green: 0.7, blue: 0.5)
        )
    ]
    
    @State private var selectedCategory = "All"
    let categories = ["All", "Popular", "Sleep", "Stress", "Focus"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                            ForEach(guidedMeditations) { meditation in
                                NavigationLink(destination: GuidedMeditationPlayerView(meditation: meditation)) {
                                    GuidedMeditationCard(meditation: meditation)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Guided")
            .navigationBarTitleDisplayMode(.large)
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

struct GuidedMeditation: Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: Int
    let imageColor: Color
} 