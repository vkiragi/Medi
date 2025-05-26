import Foundation
import SwiftUI
import Combine

class MeditationManager: ObservableObject {
    @Published var selectedDuration: Int = 10 // minutes
    @Published var timeRemaining: TimeInterval = 600 // seconds
    @Published var isActive = false
    @Published var isPaused = false
    @Published var completedSessions: [MeditationSession] = []
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    
    let availableDurations = [5, 10, 15, 20] // minutes
    
    init() {
        loadSessions()
        timeRemaining = Double(selectedDuration * 60)
    }
    
    func start() {
        isActive = true
        isPaused = false
        startTime = Date()
        timeRemaining = Double(selectedDuration * 60)
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.1
                } else {
                    self.complete()
                }
            }
    }
    
    func pause() {
        isPaused = true
    }
    
    func resume() {
        isPaused = false
    }
    
    func stop() {
        timer?.cancel()
        isActive = false
        isPaused = false
        timeRemaining = Double(selectedDuration * 60)
    }
    
    func complete() {
        timer?.cancel()
        isActive = false
        isPaused = false
        
        if let startTime = startTime {
            let session = MeditationSession(
                date: startTime,
                duration: selectedDuration * 60,
                completed: true
            )
            completedSessions.append(session)
            saveSessions()
        }
        
        timeRemaining = Double(selectedDuration * 60)
    }
    
    func updateDuration(_ minutes: Int) {
        selectedDuration = minutes
        if !isActive {
            timeRemaining = Double(minutes * 60)
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(completedSessions) {
            UserDefaults.standard.set(encoded, forKey: "meditation_sessions")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "meditation_sessions"),
           let decoded = try? JSONDecoder().decode([MeditationSession].self, from: data) {
            completedSessions = decoded
        }
    }
}

struct MeditationSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let completed: Bool
    
    init(date: Date, duration: TimeInterval, completed: Bool) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.completed = completed
    }
} 