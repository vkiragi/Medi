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
        errorMessage = nil
        
        print("Attempting to load audio file: \(fileName).\(fileExtension)")
        
        // First try directly in the main bundle
        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            loadAudioFromURL(url)
            return
        }
        
        // Check in various project locations if not found
        let locations = ["", "Resources/", "Resources/Audio/"]
        for location in locations {
            if let url = Bundle.main.url(forResource: "\(location)\(fileName)", withExtension: fileExtension) {
                print("Found audio file at: \(location)\(fileName).\(fileExtension)")
                loadAudioFromURL(url)
                return
            }
        }
        
        // If we reach here, no file was found
        let errorMsg = "Audio file not found: \(fileName)"
        print(errorMsg)
        
        // List available audio files for debugging
        print("Available audio files in bundle:")
        let bundles = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
        for path in bundles {
            print("- \(path)")
        }
        
        #if DEBUG
        errorMessage = "Audio file not found: \(fileName).\(fileExtension)"
        #else
        errorMessage = "This meditation is not available right now."
        #endif
        audioLoaded = false
    }
    
    private func loadAudioFromURL(_ url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            audioLoaded = true
            errorMessage = nil
            print("Successfully loaded audio: \(url.lastPathComponent)")
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