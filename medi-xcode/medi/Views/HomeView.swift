import SwiftUI

enum MeditationMode: String, CaseIterable {
    case stressRelief = "Stress Relief"
    case focusClarity = "Focus & Clarity"
    case deepSleep = "Deep Sleep"
    case gratitudePractice = "Gratitude Practice"
    case morningCalm = "Morning Calm"
    
    var icon: String {
        switch self {
        case .stressRelief: return "leaf.fill"
        case .focusClarity: return "brain.head.profile"
        case .deepSleep: return "moon.fill"
        case .gratitudePractice: return "heart.fill"
        case .morningCalm: return "sunrise.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .stressRelief: return Color.green
        case .focusClarity: return Color.blue
        case .deepSleep: return Color.indigo
        case .gratitudePractice: return Color.pink
        case .morningCalm: return Color.orange
        }
    }
}

struct HomeView: View {
    // MARK: - Properties
    @EnvironmentObject var audioManager: AudioManager
    // MARK: - Guided Meditations Data
    
    private var guidedMeditations: [GuidedMeditation] {
        return createMeditations()
    }
    
    private var filteredMeditations: [GuidedMeditation] {
        switch selectedMode {
        case .stressRelief:
            return guidedMeditations.filter { meditation in
                meditation.title.contains("Stress") ||
                meditation.title.contains("Relax") ||
                meditation.title.contains("Peace") ||
                meditation.title.contains("Nirvikalpa") ||
                meditation.title.contains("Aberdeen")
            }
        case .focusClarity:
            return guidedMeditations.filter { meditation in
                meditation.title.contains("Focus") ||
                meditation.title.contains("Clarity") ||
                meditation.title.contains("Weightlessness") ||
                meditation.title.contains("Zen") ||
                meditation.title.contains("Ambient")
            }
        case .deepSleep:
            return guidedMeditations.filter { meditation in
                meditation.title.contains("Sleep") ||
                meditation.title.contains("Moon") ||
                meditation.title.contains("Dream") ||
                meditation.title.contains("Foetal") ||
                meditation.title.contains("Night")
            }
        case .gratitudePractice:
            return guidedMeditations.filter { meditation in
                meditation.title.contains("Gratitude") ||
                meditation.title.contains("Zen") ||
                meditation.title.contains("Vedic") ||
                meditation.title.contains("Solitude") ||
                meditation.title.contains("Contemplation")
            }
        case .morningCalm:
            return guidedMeditations.filter { meditation in
                meditation.title.contains("Morning") ||
                meditation.title.contains("Calm") ||
                meditation.title.contains("Inner") ||
                meditation.title.contains("Peace")
            }
        }
    }
    
    private func createMeditations() -> [GuidedMeditation] {
        let meditations: [GuidedMeditation] = [
            GuidedMeditation(
                id: "peace_healing",
                title: "Peace & Healing",
                description: "A meditation for inner peace and healing.",
                duration: 10,
                imageColor: Color(red: 0.8, green: 0.4, blue: 0.6),
                audioFileName: "peace-and-healing-meditation-140639"
            ),
            GuidedMeditation(
                id: "stress_relief",
                title: "Stress Relief",
                description: "Calm your mind and relieve stress.",
                duration: 15,
                imageColor: Color(red: 0.4, green: 0.7, blue: 0.5),
                audioFileName: "stress-relief-meditation-106798"
            ),
            GuidedMeditation(
                id: "deep_sleep",
                title: "Deep Sleep",
                description: "Fall into a peaceful sleep.",
                duration: 20,
                imageColor: Color(red: 0.3, green: 0.4, blue: 0.8),
                audioFileName: "deep-sleep-meditation-22029"
            ),
            GuidedMeditation(
                id: "focus_clarity",
                title: "Focus & Clarity",
                description: "Improve concentration and mental clarity.",
                duration: 12,
                imageColor: Color(red: 0.6, green: 0.5, blue: 0.9),
                audioFileName: "focus-clarity-meditation-165920"
            ),
            GuidedMeditation(
                id: "morning_calm",
                title: "Morning Calm",
                description: "Start your day with tranquility.",
                duration: 8,
                imageColor: Color(red: 0.9, green: 0.6, blue: 0.4),
                audioFileName: "morning-calm-236192"
            ),
            GuidedMeditation(
                id: "inner_peace",
                title: "Inner Peace",
                description: "Find your inner sanctuary.",
                duration: 18,
                imageColor: Color(red: 0.5, green: 0.8, blue: 0.7),
                audioFileName: "inner-peace-meditation-106798"
            )
        ]
        return meditations
    }
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var selectedMode: MeditationMode = .stressRelief
    @State private var showingGuidedMeditation = false
    @State private var selectedGuidedMeditation: GuidedMeditation?
    @State private var animationPhase: Double = 0.0
    
    var body: some View {
        ZStack {
            // Quyo-style purple gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.8),  // Deep purple
                    Color(red: 0.6, green: 0.3, blue: 0.9),  // Medium purple
                    Color(red: 0.8, green: 0.4, blue: 1.0)   // Light purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom App Title
                AppTitle("Medi")
                    .padding(.top, 60)
                
                // Mode Selection
                VStack(spacing: 20) {
                    Text("MODE")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(MeditationMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    selectedMode = mode
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: mode.icon)
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                                        
                                        Text(mode.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                                    }
                                    .frame(width: 100, height: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedMode == mode ? 
                                                  mode.color.opacity(0.3) : 
                                                  Color.white.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(selectedMode == mode ? 
                                                   mode.color.opacity(0.5) : 
                                                   Color.clear, lineWidth: 1)
                                    )
                                }
                                .scaleEffect(selectedMode == mode ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: selectedMode)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                Spacer()
                
                // Guided Meditations Section (shows when mode is selected)
                if !filteredMeditations.isEmpty {
                    VStack(spacing: 20) {
                        // Section Header
                        HStack {
                            Text("\(selectedMode.rawValue) Meditations")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // Meditations List
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(filteredMeditations, id: \.id) { meditation in
                                    Button(action: {
                                        selectedGuidedMeditation = meditation
                                        showingGuidedMeditation = true
                                    }) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            // Meditation card with gradient background
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20)
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
                                                    .frame(width: 220, height: 140)
                                                    .shadow(color: meditation.imageColor.opacity(0.3), radius: 8, x: 0, y: 4)
                                                
                                                // Play button overlay
                                                Circle()
                                                    .fill(Color.white.opacity(0.2))
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Image(systemName: "play.fill")
                                                            .font(.system(size: 16, weight: .medium))
                                                            .foregroundColor(.white)
                                                    )
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(meditation.title)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                
                                                Text("\(meditation.duration) min")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                        .frame(width: 220)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                Spacer()
                
                // Quick Meditation Button (Bottom)
                VStack(spacing: 0) {
                    if meditationManager.isActive {
                        // Active meditation controls
                        VStack(spacing: 30) {
                            // Timer display
                            Text(formattedTime)
                                .font(.system(size: 64, weight: .ultraLight))
                                .foregroundColor(.white)
                                .tracking(4)
                            
                            // Control buttons
                            HStack(spacing: 50) {
                                // Stop button
                                Button(action: { 
                                    meditationManager.stop()
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "stop.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                        Text("Stop")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Circle())
                                }
                                
                                // Pause/Resume button
                                Button(action: {
                                    if meditationManager.isPaused {
                                        meditationManager.resume()
                                    } else {
                                        meditationManager.pause()
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: meditationManager.isPaused ? "play.fill" : "pause.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                        Text(meditationManager.isPaused ? "Resume" : "Pause")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                                }
                            }
                        }
                    } else {
                        // Inactive state - show start button
                        Button(action: {
                            meditationManager.start()
                        }) {
                            HStack(spacing: 16) {
                                Spacer()
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Start Quick")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("5 Min Meditation")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                            .frame(width: 320, height: 60)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                

            }
        }
        .onAppear {
            // Start the animation cycle
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animationPhase = 1.0
            }
        }
        .sheet(isPresented: $showingGuidedMeditation) {
            if let meditation = selectedGuidedMeditation {
                GuidedMeditationPlayerView(meditation: meditation)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    var formattedTime: String {
        let minutes = Int(meditationManager.timeRemaining) / 60
        let seconds = Int(meditationManager.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct DurationPickerView: View {
    let selectedDuration: Int
    let onSelect: (Int) -> Void
    let durations: [Int]
    
    var body: some View {
        VStack {
            Text("Select Duration")
                .font(.headline)
                .padding()
            
            List {
                ForEach(durations, id: \.self) { duration in
                    Button(action: {
                        onSelect(duration)
                    }) {
                        HStack {
                            Text("\(duration) minutes")
                            
                            Spacer()
                            
                            if duration == selectedDuration {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Button("Cancel") {
                onSelect(selectedDuration)
            }
            .padding()
        }
    }
} 