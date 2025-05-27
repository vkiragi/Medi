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
        // Clear any previous audio
        audioPlayer = nil
        
        // Try locations in order of preference
        let locations = ["Audio/", ""]
        
        var foundURL: URL?
        
        // Search for the audio file
        for location in locations {
            if let url = Bundle.main.url(forResource: "\(location)\(fileName)", withExtension: fileExtension) {
                foundURL = url
                break
            }
        }
        
        // Handle result
        guard let url = foundURL else {
            print("Audio file not found: \(fileName)")
            #if DEBUG
            errorMessage = "Audio file not found: \(fileName).\(fileExtension)"
            #else
            errorMessage = "This meditation is not available right now."
            #endif
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
            #if DEBUG
            errorMessage = "Failed to load audio: \(error.localizedDescription)"
            #else
            errorMessage = "Unable to play this meditation. Please try again later."
            #endif
            audioLoaded = false
        }
    }
    
    func play() {
        guard audioLoaded, let player = audioPlayer else {
            #if DEBUG
            errorMessage = "No audio loaded"
            #else
            errorMessage = "This meditation is not available right now."
            #endif
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