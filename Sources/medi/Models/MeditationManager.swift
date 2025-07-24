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
    
    // Mood tracking
    @Published public var moodSessions: [MoodSession] = []
    @Published public var currentMoodSession: MoodSession?
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    private let supabase = SupabaseManager.shared
    
    public let availableDurations = [5, 10, 15, 20] // minutes
    
    public init() {
        loadSessions()
        loadMoodSessions()
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
                duration: Double(selectedDuration * 60),
                completed: true
            )
            completedSessions.append(session)
            saveSessions()
            
            // Link to mood session if one exists and capture meditation data
            if var moodSession = currentMoodSession {
                moodSession.meditationSessionId = session.id
                moodSession.meditationType = "timer_meditation" // Could be made more specific
                moodSession.meditationDurationMinutes = selectedDuration
                moodSession.completedMeditation = true
                moodSession.meditationCompletedAt = Date()
                updateMoodSession(moodSession)
                
                // Note: Cloud sync should be called from the view with the current user ID
            }
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
    
    /// Syncs mood sessions with Supabase
    @MainActor
    public func syncMoodWithCloud(userId: String) async {
        guard !userId.isEmpty else { return }
        
        // Skip sync for anonymous users
        if userId.hasPrefix("anonymous_") {
            syncStatus = "Cloud sync is only available when signed in"
            return
        }
        
        isSyncing = true
        syncStatus = "Syncing mood data with cloud..."
        
        // Upload local mood sessions to cloud
        await supabase.syncMoodSessions(userId: userId, moodSessions: moodSessions)
        
        // Get any mood sessions from the cloud that we don't have locally
        if let cloudMoodSessions = await supabase.fetchMoodSessions(userId: userId) {
            // Find sessions that exist in the cloud but not locally
            let localIds = Set(moodSessions.map { $0.id.uuidString })
            let newMoodSessions = cloudMoodSessions.filter { !localIds.contains($0.id.uuidString) }
            
            // Add new mood sessions to local storage
            if !newMoodSessions.isEmpty {
                moodSessions.append(contentsOf: newMoodSessions)
                saveMoodSessions()
                syncStatus = "Synced \(newMoodSessions.count) new mood sessions from cloud"
            } else {
                syncStatus = "All mood data synced"
            }
        }
        
        isSyncing = false
    }
    
    // MARK: - Mood Session Management
    
    // Helper function to create mood session and optionally sync to cloud  
    public func createMoodSession(mood: MoodState, userId: String? = nil, moodIntensity: Int? = nil, stressLevel: Int? = nil, energyLevel: Int? = nil, contextTags: [String] = [], notes: String? = nil) {
        var moodSession = MoodSession(mood: mood)
        
        // Add enhanced data if provided
        moodSession.moodIntensity = moodIntensity
        moodSession.stressLevel = stressLevel
        moodSession.energyLevel = energyLevel
        moodSession.contextTags = contextTags
        moodSession.notes = notes
        
        moodSessions.append(moodSession)
        currentMoodSession = moodSession
        saveMoodSessions()
        
        // Sync to cloud if user ID provided
        if let userId = userId {
            Task {
                await syncMoodWithCloud(userId: userId)
            }
        }
    }
    
    // Helper function to complete meditation and optionally sync mood data
    public func completeMeditation(userId: String? = nil) {
        timer?.cancel()
        isActive = false
        isPaused = false
        
        if let startTime = startTime {
            let session = MeditationSession(
                date: startTime,
                duration: Double(selectedDuration * 60),
                completed: true
            )
            completedSessions.append(session)
            saveSessions()
            
            // Link to mood session if one exists and capture meditation data
            if var moodSession = currentMoodSession {
                moodSession.meditationSessionId = session.id
                moodSession.meditationType = "timer_meditation"
                moodSession.meditationDurationMinutes = selectedDuration
                moodSession.completedMeditation = true
                moodSession.meditationCompletedAt = Date()
                updateMoodSession(moodSession)
                
                // Sync to cloud if user ID provided
                if let userId = userId {
                    Task {
                        await syncMoodWithCloud(userId: userId)
                    }
                }
            }
        }
        
        timeRemaining = Double(selectedDuration * 60)
    }
    
    public func updateMoodSession(_ updatedSession: MoodSession) {
        if let index = moodSessions.firstIndex(where: { $0.id == updatedSession.id }) {
            moodSessions[index] = updatedSession
            saveMoodSessions()
        }
    }
    
    public func rateMoodSessionExperience(rating: Int) {
        guard var currentSession = currentMoodSession else { return }
        currentSession.postMoodRating = rating
        updateMoodSession(currentSession)
        currentMoodSession = nil // Clear after rating
    }
    
    public func getMoodInsights() -> MoodInsights {
        return MoodInsights(moodSessions: moodSessions)
    }
    
    private func saveMoodSessions() {
        if let encoded = try? JSONEncoder().encode(moodSessions) {
            UserDefaults.standard.set(encoded, forKey: "mood_sessions")
        }
    }
    
    private func loadMoodSessions() {
        if let data = UserDefaults.standard.data(forKey: "mood_sessions"),
           let decoded = try? JSONDecoder().decode([MoodSession].self, from: data) {
            moodSessions = decoded
        }
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