import SwiftUI

struct GuidedMeditationListView: View {
    @State private var selectedMeditation: GuidedMeditation?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 15) {
                        // Header
                        VStack(spacing: 10) {
                            Text("Guided Meditations")
                                .font(.system(size: 32, weight: .thin, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                            
                            Text("Choose your practice")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // Meditation cards
                        ForEach(GuidedMeditation.meditations) { meditation in
                            NavigationLink(destination: GuidedMeditationPlayerView(meditation: meditation)) {
                                MeditationCard(meditation: meditation)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MeditationCard: View {
    let meditation: GuidedMeditation
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(meditation.title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                    
                    Spacer()
                    
                    Text(meditation.duration)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.1))
                        .cornerRadius(12)
                }
                
                Text(meditation.description)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    .multilineTextAlignment(.leading)
            }
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
} 