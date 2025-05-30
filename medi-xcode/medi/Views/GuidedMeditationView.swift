import SwiftUI
import AVFoundation

struct GuidedMeditationView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var breathingScale: CGFloat = 1.0
    
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
            
            VStack(spacing: 30) {
                // Title
                Text("Guided Breathing")
                    .font(.system(size: 36, weight: .thin, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                    .padding(.top, 40)
                
                Text("3 Minute Session")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                
                Spacer()
                
                // Breathing Circle
                ZStack {
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
                            audioManager.isPlaying ?
                            Animation.easeInOut(duration: 4).repeatForever(autoreverses: true) :
                            .default,
                            value: breathingScale
                        )
                    
                    VStack(spacing: 10) {
                        Image(systemName: audioManager.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                        
                        Text(audioManager.isPlaying ? "Playing" : "Ready")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    }
                }
                .onAppear {
                    audioManager.loadAudio(fileName: "breathing_meditation")
                }
                .onChange(of: audioManager.isPlaying) { isPlaying in
                    breathingScale = isPlaying ? 1.3 : 1.0
                }
                
                // Progress bar
                if audioManager.duration > 0 {
                    VStack(spacing: 10) {
                        ProgressView(value: audioManager.currentTime, total: audioManager.duration)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.6, green: 0.7, blue: 0.9)))
                            .frame(height: 4)
                        
                        HStack {
                            Text(timeString(from: audioManager.currentTime))
                            Spacer()
                            Text(timeString(from: audioManager.duration))
                        }
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 40) {
                    // Stop button
                    Button(action: { audioManager.stop() }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(red: 0.9, green: 0.5, blue: 0.5))
                            .clipShape(Circle())
                    }
                    .opacity(audioManager.isPlaying || audioManager.currentTime > 0 ? 1 : 0.5)
                    .disabled(!audioManager.isPlaying && audioManager.currentTime == 0)
                    
                    // Play/Pause button
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.pause()
                        } else {
                            audioManager.play()
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                            .clipShape(Circle())
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