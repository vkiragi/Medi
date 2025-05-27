import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var audioTitle = "Guided Meditation"
    @Published var audioLoaded = false
    @Published var errorMessage: String?
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: AnyCancellable?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
            errorMessage = "Could not set up audio session"
        }
    }
    
    func loadAudio(fileName: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Audio file not found: \(fileName).\(fileExtension)")
            errorMessage = "Audio file not found: \(fileName).\(fileExtension)"
            audioLoaded = false
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            audioLoaded = true
            errorMessage = nil
        } catch {
            print("Failed to load audio: \(error)")
            errorMessage = "Failed to load audio: \(error.localizedDescription)"
            audioLoaded = false
        }
    }
    
    func play() {
        guard audioLoaded, let player = audioPlayer else {
            errorMessage = "No audio loaded"
            return
        }
        
        player.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
        isPlaying = false
        stopTimer()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentTime = self.audioPlayer?.currentTime ?? 0
                
                // Check if audio finished
                if !(self.audioPlayer?.isPlaying ?? false) && self.isPlaying {
                    self.stop()
                }
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
    }
} 