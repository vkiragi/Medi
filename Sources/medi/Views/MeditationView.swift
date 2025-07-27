import SwiftUI

public struct MeditationView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var breathingScale: CGFloat = 1.0
    @State private var showingDurationPicker = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0
    @State private var breathTimer: Timer?
    
    public var body: some View {
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
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 280, height: 280)
                    
                    // Ripple effects
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
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
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2)
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
                    VStack(spacing: 8) {
                        Text(timeString(from: meditationManager.timeRemaining))
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundColor(.white)
                            .tracking(2)
                        
                        if meditationManager.isActive && !meditationManager.isPaused {
                            Text(breathPhase.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .animation(.easeInOut(duration: 2), value: breathPhase)
                        } else {
                            Text("remaining")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
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
                .onReceive(meditationManager.$isActive) { isActive in
                    if !isActive {
                        stopBreathingAnimation()
                    }
                }
                
                Spacer()
                
                // Duration selector
                if !meditationManager.isActive {
                    VStack(spacing: 15) {
                        Text("Duration")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        HStack(spacing: 20) {
                            ForEach(meditationManager.availableDurations, id: \.self) { duration in
                                DurationButton(
                                    duration: duration,
                                    isSelected: meditationManager.selectedDuration == duration
                                ) {
                                    meditationManager.updateDuration(duration)
                                }
                            }
                        }
                    }
                    .transition(.opacity)
                }
                
                // Control buttons
                HStack(spacing: 40) {
                    if meditationManager.isActive {
                        // Stop button
                        Button(action: { 
                            meditationManager.stop()
                            stopBreathingAnimation()
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color(red: 0.9, green: 0.5, blue: 0.5))
                                .clipShape(Circle())
                        }
                        
                        // Play/Pause button
                        Button(action: {
                            if meditationManager.isPaused {
                                meditationManager.resume()
                            } else {
                                meditationManager.pause()
                            }
                        }) {
                            Image(systemName: meditationManager.isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                                .clipShape(Circle())
                        }
                    } else {
                        // Start button
                        Button(action: { meditationManager.start() }) {
                            Text("Start")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 60)
                                .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func startBreathingAnimation() {
        breathingScale = 1.3
        rippleScale = 1.0
        rippleOpacity = 0.0
        
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
        
        withAnimation(.easeOut(duration: 0.5)) {
            breathingScale = 1.0
            rippleScale = 1.0
            rippleOpacity = 0.0
        }
        breathPhase = .inhale
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Types

enum BreathPhase: String, CaseIterable {
    case inhale = "Breathe in"
    case exhale = "Breathe out"
}

struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(duration)")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.5, green: 0.5, blue: 0.6))
                .frame(width: 60, height: 60)
                .background(
                    isSelected ?
                    Color(red: 0.6, green: 0.7, blue: 0.9) :
                    Color(red: 0.9, green: 0.9, blue: 0.95)
                )
                .clipShape(Circle())
        }
    }
} 