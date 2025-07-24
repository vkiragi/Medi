import SwiftUI

public struct MoodCheckInView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMood: MoodState? = nil
    @State private var showingRecommendations = false
    
    let onMoodSelected: (MoodState) -> Void
    
    public init(onMoodSelected: @escaping (MoodState) -> Void) {
        self.onMoodSelected = onMoodSelected
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
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Text("How are you feeling?")
                                .font(.system(size: 32, weight: .thin, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                .multilineTextAlignment(.center)
                            
                            Text("Choose what best describes your current mood")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 40)
                        
                        // Mood Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 20) {
                            ForEach(MoodState.allCases, id: \.self) { mood in
                                MoodCard(
                                    mood: mood,
                                    isSelected: selectedMood == mood,
                                    onTap: {
                                        selectedMood = mood
                                        // Add haptic feedback
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Continue button
                        if selectedMood != nil {
                            Button(action: {
                                if let mood = selectedMood {
                                    onMoodSelected(mood)
                                    showingRecommendations = true
                                }
                            }) {
                                HStack {
                                    Text("Continue")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                                .cornerRadius(27.5)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                            .animation(.easeInOut(duration: 0.3), value: selectedMood)
                        }
                        
                        // Skip option
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Skip for now")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingRecommendations) {
            if let mood = selectedMood {
                MoodRecommendationsView(mood: mood) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct MoodCard: View {
    let mood: MoodState
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Mood emoji
                Text(mood.emoji)
                    .font(.system(size: 40))
                
                // Mood name
                Text(mood.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                
                // Mood description
                Text(mood.description)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? mood.color : Color.clear,
                                lineWidth: isSelected ? 3 : 0
                            )
                    )
            )
            .shadow(
                color: isSelected ? mood.color.opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 