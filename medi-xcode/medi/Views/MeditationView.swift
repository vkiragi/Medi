import SwiftUI

struct MeditationView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var breathingScale: CGFloat = 1.0
    @State private var showingDurationPicker = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0
    @State private var backgroundOffset: CGFloat = 0.0
    @State private var particleOpacity: Double = 0.0
    @State private var breathTimer: Timer?
    
    var body: some View {
        ZStack {
            // Dynamic background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.9),
                    Color(red: 0.6, green: 0.8, blue: 1.0),
                    Color(red: 0.8, green: 0.9, blue: 1.0)
                ]),
                startPoint: UnitPoint(x: 0.5 + backgroundOffset * 0.1, y: 0.5 + backgroundOffset * 0.1),
                endPoint: UnitPoint(x: 1.0 - backgroundOffset * 0.1, y: 1.0 - backgroundOffset * 0.1)
            )
            .ignoresSafeArea()
            .animation(
                meditationManager.isActive && !meditationManager.isPaused ?
                    .easeInOut(duration: 8).repeatForever(autoreverses: true) :
                    .default,
                value: backgroundOffset
            )
            
            // Subtle particle effects
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 4...12))
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...800)
                    )
                    .opacity(particleOpacity)
                    .animation(
                        meditationManager.isActive && !meditationManager.isPaused ?
                            .easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.5) :
                            .default,
                        value: particleOpacity
                    )
            }
            
            VStack(spacing: 0) {
                // Title
                Text("Meditation")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                // Modern breathing animation
                ZStack {
                    // Background circle (subtle)
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 300, height: 300)
                    
                    // Progress ring (subtle)
                    if meditationManager.isActive {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 2)
                            .frame(width: 260, height: 260)
                        
                        Circle()
                            .trim(from: 0, to: meditationProgress)
                            .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 260, height: 260)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1), value: meditationProgress)
                    }
                    
                    // Ripple effects
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            .frame(width: 200, height: 200)
                            .scaleEffect(rippleScale)
                            .opacity(rippleOpacity)
                            .animation(
                                meditationManager.isActive && !meditationManager.isPaused ?
                                    Animation.easeOut(duration: 4)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 1.33) :
                                    .default,
                                value: rippleScale
                            )
                    }
                    
                    // Main breathing circle
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(breathingScale)
                        .animation(
                            meditationManager.isActive && !meditationManager.isPaused ?
                                Animation.easeInOut(duration: 4).repeatForever(autoreverses: true) :
                                .default,
                            value: breathingScale
                        )
                    
                    // Timer and breath guidance
                    VStack(spacing: 12) {
                        Text(formattedTime)
                            .font(.system(size: 52, weight: .ultraLight))
                            .foregroundColor(.white)
                            .tracking(3)
                        
                        if meditationManager.isActive && !meditationManager.isPaused {
                            Text(breathPhase.rawValue)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .animation(.easeInOut(duration: 2), value: breathPhase)
                        } else {
                            Text("remaining")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 40)
                .onAppear {
                    if meditationManager.isActive && !meditationManager.isPaused {
                        startBreathingAnimation()
                    }
                }
                .onChange(of: meditationManager.isActive) { isActive in
                    if isActive && !meditationManager.isPaused {
                        startBreathingAnimation()
                    } else {
                        stopBreathingAnimation()
                    }
                }
                .onChange(of: meditationManager.isPaused) { isPaused in
                    if meditationManager.isActive && !isPaused {
                        startBreathingAnimation()
                    } else {
                        stopBreathingAnimation()
                    }
                }
                .onDisappear {
                    // Clean up timer when view disappears
                    breathTimer?.invalidate()
                    breathTimer = nil
                }
                .onReceive(meditationManager.$isActive) { isActive in
                    if !isActive {
                        stopBreathingAnimation()
                    }
                }
                
                Spacer()
                
                Spacer()
                
                // Controls
                VStack(spacing: 32) {
                    if meditationManager.isActive {
                        // Main controls row
                        HStack(spacing: 80) {
                            // Stop button
                            Button(action: { 
                                meditationManager.stop()
                                stopBreathingAnimation()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                    Text("Stop")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .frame(width: 64, height: 64)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Circle())
                            }
                            
                            // Pause/Resume button
                            Button(action: {
                                if meditationManager.isPaused {
                                    meditationManager.resume()
                                    startBreathingAnimation()
                                } else {
                                    meditationManager.pause()
                                    stopBreathingAnimation()
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: meditationManager.isPaused ? "play.fill" : "pause.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                    Text(meditationManager.isPaused ? "Resume" : "Pause")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .frame(width: 80, height: 80)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())
                            }
                        }
                        
                        
                        
                        // Complete Early section
                        let totalDuration = Double(meditationManager.selectedDuration * 60)
                        let timeElapsed = totalDuration - meditationManager.timeRemaining
                        
                        if timeElapsed >= 30 {
                            Button(action: { 
                                meditationManager.completeEarly()
                                stopBreathingAnimation()
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Complete Early")
                                        .font(.system(size: 17, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(width: 180, height: 48)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(24)
                            }
                        } else if timeElapsed > 0 {
                            // Progress indicator
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                Text("\(Int(30 - timeElapsed))s until early completion")
                                    .font(.system(size: 14, weight: .light))
                            }
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                    } else {
                        // Duration selector
                        VStack(spacing: 16) {
                            Text("Choose Duration")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button(action: {
                                showingDurationPicker = true
                            }) {
                                HStack(spacing: 10) {
                                    Text("\(meditationManager.selectedDuration) minutes")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(24)
                            }
                            .sheet(isPresented: $showingDurationPicker) {
                                DurationPickerView(
                                    selectedDuration: meditationManager.selectedDuration,
                                    onSelect: { duration in
                                        meditationManager.updateDuration(duration)
                                        showingDurationPicker = false
                                    },
                                    durations: meditationManager.availableDurations
                                )
                            }
                        }
                        
                        // Start button
                        Button(action: {
                            meditationManager.start()
                            startBreathingAnimation()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20))
                                Text("Start Meditation")
                                    .font(.system(size: 20, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(width: 220, height: 60)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(30)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func startBreathingAnimation() {
        breathingScale = 1.3
        rippleScale = 1.0
        rippleOpacity = 0.0
        
        // Start background animation
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            backgroundOffset = 1.0
        }
        
        // Start particle animation
        withAnimation(.easeInOut(duration: 2)) {
            particleOpacity = 1.0
        }
        
        // Start breath phase animation
        breathTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2)) {
                breathPhase = breathPhase == .inhale ? .exhale : .inhale
            }
        }
        
        // Start ripple animation
        withAnimation(.easeOut(duration: 4).repeatForever(autoreverses: false)) {
            rippleScale = 2.0
            rippleOpacity = 0.0
        }
    }
    
    private func stopBreathingAnimation() {
        // Invalidate the breath timer
        breathTimer?.invalidate()
        breathTimer = nil
        
        // Reset all animation states immediately
        breathingScale = 1.0
        rippleScale = 1.0
        rippleOpacity = 0.0
        backgroundOffset = 0.0
        particleOpacity = 0.0
        breathPhase = .inhale
    }
    
    var formattedTime: String {
        let minutes = Int(meditationManager.timeRemaining) / 60
        let seconds = Int(meditationManager.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var meditationProgress: Double {
        let totalDuration = Double(meditationManager.selectedDuration * 60)
        let elapsed = totalDuration - meditationManager.timeRemaining
        return min(elapsed / totalDuration, 1.0)
    }
}

// MARK: - Supporting Types

enum BreathPhase: String, CaseIterable {
    case inhale = "Breathe in"
    case exhale = "Breathe out"
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