import Foundation
import SwiftUI
import Combine

public class MeditationManager: ObservableObject {
    @Published public var selectedDuration: Int = 10 // minutes
    @Published public var timeRemaining: TimeInterval = 600 // seconds
    @Published public var isActive = false
    @Published public var isPaused = false
    @Published public var completedSessions: [MeditationSession] = []
    @Published public var isSyncing = false
    @Published public var syncStatus: String?
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    private let supabase = SupabaseManager.shared
    
    public let availableDurations = [5, 10, 15, 20] // minutes
    
    public init() {
        loadSessions()
        timeRemaining = Double(selectedDuration * 60)
    }
    
    public func start() {
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
    
    public func pause() {
        isPaused = true
    }
    
    public func resume() {
        isPaused = false
    }
    
    public func stop() {
        timer?.cancel()
        isActive = false
        isPaused = false
        timeRemaining = Double(selectedDuration * 60)
    }
    
    public func complete() {
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
    
    public func updateDuration(_ minutes: Int) {
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
    
    // MARK: - Cloud Sync
    
    /// Syncs meditation sessions with Supabase
    @MainActor
    public func syncWithCloud(userId: String) async {
        guard !userId.isEmpty else { return }
        
        // Skip sync for anonymous users
        if userId.hasPrefix("anonymous_") {
            syncStatus = "Cloud sync is only available when signed in"
            return
        }
        
        isSyncing = true
        syncStatus = "Syncing with cloud..."
        
        // Upload local sessions to cloud
        await supabase.syncMeditationSessions(userId: userId, sessions: completedSessions)
        
        // Get any sessions from the cloud that we don't have locally
        if let cloudSessions = await supabase.fetchMeditationSessions(userId: userId) {
            // Find sessions that exist in the cloud but not locally
            let localIds = Set(completedSessions.map { $0.id.uuidString })
            let newSessions = cloudSessions.filter { !localIds.contains($0.id.uuidString) }
            
            // Add new sessions to local storage
            if !newSessions.isEmpty {
                completedSessions.append(contentsOf: newSessions)
                saveSessions()
                syncStatus = "Synced \(newSessions.count) new sessions from cloud"
            } else {
                syncStatus = "All sessions synced"
            }
        }
        
        isSyncing = false
    }
}

public struct MeditationSession: Codable, Identifiable {
    public let id: UUID
    public let date: Date
    public let duration: TimeInterval
    public let completed: Bool
    
    public init(date: Date, duration: TimeInterval, completed: Bool) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.completed = completed
    }
    
    // Custom initializer for cloud data
    public init(id: UUID, date: Date, duration: TimeInterval, completed: Bool) {
        self.id = id
        self.date = date
        self.duration = duration
        self.completed = completed
    }
} 