import Foundation
import SwiftUI
import Combine

class MeditationManager: ObservableObject {
    @Published var selectedDuration: Int = 10 // minutes
    @Published var timeRemaining: TimeInterval = 600 // seconds
    @Published var isActive = false
    @Published var isPaused = false
    @Published var completedSessions: [MeditationSession] = []
    @Published var isSyncing = false
    @Published var syncStatus: String?
    
    // Mood tracking
    @Published var moodSessions: [MoodSession] = []
    @Published var currentMoodSession: MoodSession?
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    private let supabase = SupabaseManager.shared
    
    let availableDurations = [5, 10, 15, 20] // minutes
    
    init() {
        loadSessions()
        loadMoodSessions()
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
    
    /// Completes the current session early, counting the time spent meditating
    func completeEarly() {
        print("🎯 Session completion triggered (early)")
        
        guard isActive, let startTime = startTime else { 
            print("❌ Cannot complete early - session not active or no start time")
            return 
        }
        
        timer?.cancel()
        isActive = false
        isPaused = false
        
        // Calculate actual time spent meditating
        let actualDuration = Double(selectedDuration * 60) - timeRemaining
        let minutesSpent = actualDuration / 60
        
        print("⏱️ Actual duration: \(actualDuration)s")
        print("📊 Minutes spent: \(minutesSpent)")
        
        // Only count if at least 30 seconds were spent meditating
        if actualDuration >= 30 {
            let session = MeditationSession(
                date: startTime,
                duration: actualDuration,
                completed: false // Mark as partial completion
            )
            
            print("📝 Created partial session: \(session.id.uuidString)")
            print("📅 Start time: \(startTime)")
            print("⏱️ Duration: \(session.duration)s")
            print("✅ Completed: \(session.completed)")
            
            completedSessions.append(session)
            saveSessions()
            
            print("💾 Saved to local storage. Total sessions: \(completedSessions.count)")
            
            // Link to mood session if one exists
            if var moodSession = currentMoodSession {
                moodSession.meditationSessionId = session.id
                moodSession.meditationType = "timer_meditation"
                moodSession.meditationDurationMinutes = Int(minutesSpent)
                moodSession.completedMeditation = false
                moodSession.meditationCompletedAt = Date()
                updateMoodSession(moodSession)
            }
            
            // Auto-sync to cloud in background
            print("☁️ Triggering auto-sync...")
            Task {
                await autoSyncToCloud()
            }
        } else {
            print("⚠️ Session too short (< 30s) - not counting")
        }
        
        timeRemaining = Double(selectedDuration * 60)
    }
    
    func complete() {
        print("🎯 Session completion triggered (full)")
        
        timer?.cancel()
        isActive = false
        isPaused = false
        
        if let startTime = startTime {
            let session = MeditationSession(
                date: startTime,
                duration: Double(selectedDuration * 60),
                completed: true
            )
            
            print("📝 Created session: \(session.id.uuidString)")
            print("📅 Start time: \(startTime)")
            print("⏱️ Duration: \(session.duration)s")
            print("✅ Completed: \(session.completed)")
            
            completedSessions.append(session)
            saveSessions()
            
            print("💾 Saved to local storage. Total sessions: \(completedSessions.count)")
            
            // Link to mood session if one exists and capture meditation data
            if var moodSession = currentMoodSession {
                moodSession.meditationSessionId = session.id
                moodSession.meditationType = "timer_meditation" // Could be made more specific
                moodSession.meditationDurationMinutes = selectedDuration
                moodSession.completedMeditation = true
                moodSession.meditationCompletedAt = Date()
                updateMoodSession(moodSession)
            }
            
            // Auto-sync to cloud in background
            print("☁️ Triggering auto-sync...")
            Task {
                await autoSyncToCloud()
            }
        } else {
            print("❌ No start time found for session completion")
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
    
    // MARK: - Cloud Sync
    
    /// Syncs meditation sessions with Supabase
    @MainActor
    func syncWithCloud(userId: String) async {
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
    
    /// Auto-syncs the latest session to cloud (called after completing a session)
    @MainActor
    private func autoSyncToCloud() async {
        print("🔄 Auto-sync triggered...")
        
        // Get the current user ID from UserDefaults (since we don't have direct access to AuthManager here)
        guard let userId = UserDefaults.standard.string(forKey: "apple_user_id"),
              !userId.hasPrefix("anonymous_") else { 
            print("❌ Auto-sync failed - no valid user ID")
            return 
        }
        
        print("👤 User ID for auto-sync: \(userId)")
        print("📊 Total completed sessions: \(completedSessions.count)")
        
        // Only sync the latest session to avoid full sync overhead
        if let latestSession = completedSessions.last {
            print("📤 Syncing latest session: \(latestSession.id.uuidString)")
            print("📅 Session date: \(latestSession.date)")
            print("⏱️ Session duration: \(latestSession.duration)s")
            print("✅ Session completed: \(latestSession.completed)")
            
            await supabase.syncMeditationSessions(userId: userId, sessions: [latestSession])
        } else {
            print("⚠️ No completed sessions to sync")
        }
    }
    
    /// Syncs mood sessions with Supabase
    @MainActor
    func syncMoodWithCloud(userId: String) async {
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
    
    func createMoodSession(mood: MoodState, userId: String? = nil, moodIntensity: Int? = nil, stressLevel: Int? = nil, energyLevel: Int? = nil, contextTags: [String] = [], notes: String? = nil) {
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
        
        // Debug logging
        print("🧠 Created mood session: \(mood.rawValue)")
        print("👤 User ID: \(userId ?? "nil")")
        print("💾 Local sessions count: \(moodSessions.count)")
        
        // Test basic network connectivity first
        print("🌐 Testing network connectivity...")
        Task {
            do {
                let url = URL(string: "https://httpbin.org/get")!
                let (_, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse {
                    print("✅ Network test successful: \(httpResponse.statusCode)")
                }
            } catch {
                print("❌ Network test failed: \(error)")
            }
        }
        
        // Sync to cloud if user ID provided
        if let userId = userId {
            print("☁️ Attempting cloud sync...")
            Task {
                await syncMoodWithCloud(userId: userId)
            }
        } else {
            print("⚠️ No user ID provided - skipping cloud sync")
        }
    }
    
    func updateMoodSession(_ updatedSession: MoodSession) {
        if let index = moodSessions.firstIndex(where: { $0.id == updatedSession.id }) {
            moodSessions[index] = updatedSession
            saveMoodSessions()
        }
    }
    
    func rateMoodSessionExperience(rating: Int) {
        guard var currentSession = currentMoodSession else { return }
        currentSession.postMoodRating = rating
        updateMoodSession(currentSession)
        currentMoodSession = nil // Clear after rating
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
    
    // Helper function to complete meditation and optionally sync mood data
    func completeMeditation(userId: String? = nil) {
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
    
    // Custom initializer for cloud data
    init(id: UUID, date: Date, duration: TimeInterval, completed: Bool) {
        self.id = id
        self.date = date
        self.duration = duration
        self.completed = completed
    }
} 