import SwiftUI

struct MoodCheckInView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMood: MoodState? = nil
    @State private var showingRecommendations = false
    
    let onMoodSelected: (MoodState) -> Void
    let onDismiss: () -> Void
    
    init(onMoodSelected: @escaping (MoodState) -> Void, onDismiss: @escaping () -> Void) {
        self.onMoodSelected = onMoodSelected
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
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Text("🧠")
                            .font(.system(size: 60))
                        
                        Text("How are you feeling?")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
                        
                        Text("Select your current mood to get personalized meditation recommendations")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    }
                    
                    // Mood Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                        ForEach(MoodState.allCases, id: \.self) { mood in
                            MoodCard(
                                mood: mood,
                                isSelected: selectedMood == mood
                            ) {
                                selectedMood = mood
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                // Delay to show selection, then proceed
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onMoodSelected(mood)
                                    showingRecommendations = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                }
            }
        }
        .sheet(isPresented: $showingRecommendations) {
            if let mood = selectedMood {
                MoodRecommendationsView(mood: mood) {
                    onDismiss()
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
                Text(mood.emoji)
                    .font(.system(size: 40))
                
                Text(mood.rawValue)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(mood.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        isSelected ? 
                        mood.color.opacity(0.3) : 
                        Color.white.opacity(0.8)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        isSelected ? mood.color : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MoodCheckInView { mood in
        print("Selected mood: \(mood)")
    } onDismiss: {
        print("Dismissed")
    }
} 