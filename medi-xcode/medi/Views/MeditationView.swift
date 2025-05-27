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
                    Color(red: 0.6, green: 0.7, blue: 0.9),
                    Color(red: 0.7, green: 0.8, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Title
                Text("Meditation")
                    .font(.system(size: 36, weight: .thin))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                Spacer()
                
                // Breathing animation
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 250, height: 250)
                    
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 200 * breathingScale, height: 200 * breathingScale)
                        .scaleEffect(breathingScale)
                        .animation(
                            meditationManager.isActive && !meditationManager.isPaused ?
                                Animation.easeInOut(duration: 4).repeatForever(autoreverses: true) :
                                .default,
                            value: breathingScale
                        )
                        .onAppear {
                            if meditationManager.isActive && !meditationManager.isPaused {
                                breathingScale = 1.2
                            }
                        }
                    
                    // Timer display
                    VStack {
                        Text(formattedTime)
                            .font(.system(size: 46, weight: .light))
                            .foregroundColor(.white)
                        
                        Text("remaining")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Duration selector
                if !meditationManager.isActive {
                    Button(action: {
                        showingDurationPicker = true
                    }) {
                        HStack {
                            Text("\(meditationManager.selectedDuration) minutes")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
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
                
                // Controls
                HStack(spacing: 50) {
                    if meditationManager.isActive {
                        // Stop button
                        Button(action: { meditationManager.stop() }) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        // Pause/Resume button
                        Button(action: {
                            if meditationManager.isPaused {
                                meditationManager.resume()
                                breathingScale = 1.2
                            } else {
                                meditationManager.pause()
                                breathingScale = 1.0
                            }
                        }) {
                            Image(systemName: meditationManager.isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    } else {
                        // Start button
                        Button(action: {
                            meditationManager.start()
                            breathingScale = 1.2
                        }) {
                            Text("Start")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 180, height: 60)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(30)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
    
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