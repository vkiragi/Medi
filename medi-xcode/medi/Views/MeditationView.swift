import SwiftUI

struct MeditationView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var breathingScale: CGFloat = 1.0
    @State private var showingDurationPicker = false
    
    var body: some View {
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
            
            VStack(spacing: 40) {
                // Title
                Text("medi")
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                    .padding(.top, 40)
                
                Spacer()
                
                // Breathing Circle & Timer
                ZStack {
                    // Breathing circle
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.3),
                                    Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.1)
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 150
                            )
                        )
                        .frame(width: 250, height: 250)
                        .scaleEffect(breathingScale)
                        .animation(
                            meditationManager.isActive && !meditationManager.isPaused ?
                            Animation.easeInOut(duration: 4).repeatForever(autoreverses: true) :
                            .default,
                            value: breathingScale
                        )
                    
                    // Timer display
                    VStack(spacing: 10) {
                        Text(timeString(from: meditationManager.timeRemaining))
                            .font(.system(size: 48, weight: .light, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                        
                        if meditationManager.isActive {
                            Text(meditationManager.isPaused ? "Paused" : "Breathe")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                                .animation(.easeInOut, value: meditationManager.isPaused)
                        }
                    }
                }
                .onAppear {
                    if meditationManager.isActive && !meditationManager.isPaused {
                        breathingScale = 1.3
                    }
                }
                .onChange(of: meditationManager.isActive) { newValue in
                    breathingScale = newValue && !meditationManager.isPaused ? 1.3 : 1.0
                }
                .onChange(of: meditationManager.isPaused) { isPaused in
                    breathingScale = meditationManager.isActive && !isPaused ? 1.3 : 1.0
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
                        Button(action: { meditationManager.stop() }) {
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
                .padding(.bottom, 100)
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
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