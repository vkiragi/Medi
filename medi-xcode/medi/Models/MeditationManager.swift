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
        print("🔄 MeditationManager: Starting cloud sync...")
        print("👤 User ID: \(userId)")
        
        guard !userId.isEmpty else { 
            print("❌ MeditationManager: Empty user ID, aborting sync")
            isSyncing = false
            syncStatus = "Invalid user ID"
            return 
        }
        
        // Skip sync for anonymous users
        if userId.hasPrefix("anonymous_") {
            print("ℹ️ MeditationManager: Anonymous user, skipping sync")
            syncStatus = "Cloud sync is only available when signed in"
            isSyncing = false
            return
        }
        
        print("✅ MeditationManager: Starting sync process")
        isSyncing = true
        syncStatus = "Syncing with cloud..."
        
        // Add timeout protection
        let syncTask = Task {
            do {
                // Upload local sessions to cloud
                print("📤 MeditationManager: Uploading \(completedSessions.count) local sessions to cloud")
                await supabase.syncMeditationSessions(userId: userId, sessions: completedSessions)
                
                // Get any sessions from the cloud that we don't have locally
                print("📥 MeditationManager: Fetching sessions from cloud")
                if let cloudSessions = await supabase.fetchMeditationSessions(userId: userId) {
                    print("☁️ MeditationManager: Received \(cloudSessions.count) sessions from cloud")
                    
                    // Find sessions that exist in the cloud but not locally
                    let localIds = Set(completedSessions.map { $0.id.uuidString })
                    let newSessions = cloudSessions.filter { !localIds.contains($0.id.uuidString) }
                    
                    print("🆕 MeditationManager: Found \(newSessions.count) new sessions to add locally")
                    
                    // Add new sessions to local storage
                    if !newSessions.isEmpty {
                        completedSessions.append(contentsOf: newSessions)
                        saveSessions()
                        syncStatus = "Synced \(newSessions.count) new sessions from cloud"
                        print("✅ MeditationManager: Successfully synced \(newSessions.count) new sessions")
                    } else {
                        syncStatus = "All sessions synced"
                        print("✅ MeditationManager: All sessions already synced")
                    }
                } else {
                    print("⚠️ MeditationManager: No sessions received from cloud")
                    syncStatus = "No cloud data available"
                }
                
                print("✅ MeditationManager: Sync completed successfully")
            } catch {
                print("❌ MeditationManager: Sync failed with error: \(error)")
                syncStatus = "Sync failed: \(error.localizedDescription)"
            }
        }
        
        // Wait for sync with timeout (30 seconds)
        do {
            try await withTimeout(seconds: 30) {
                await syncTask.value
            }
        } catch {
            print("⏰ MeditationManager: Sync timed out after 30 seconds")
            syncTask.cancel()
            syncStatus = "Sync timed out - please try again"
        }
        
        print("🏁 MeditationManager: Setting isSyncing = false")
        isSyncing = false
    }
    
    /// Helper function to add timeout to async operations
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    private struct TimeoutError: Error {}
    
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
    
    /// Manual reset function to force stop syncing if stuck
    @MainActor
    func resetSyncState() {
        print("🔄 MeditationManager: Manually resetting sync state")
        isSyncing = false
        syncStatus = "Sync reset - try again"
    }
    
    /// Check if sync is stuck and reset if needed
    @MainActor
    func checkAndResetStuckSync() {
        if isSyncing {
            // If syncing for more than 60 seconds, consider it stuck
            // This is a safety mechanism
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                if self.isSyncing {
                    print("⚠️ MeditationManager: Sync appears stuck, auto-resetting")
                    self.resetSyncState()
                }
            }
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
    
    // Custom initializer for cloud data
    init(id: UUID, date: Date, duration: TimeInterval, completed: Bool) {
        self.id = id
        self.date = date
        self.duration = duration
        self.completed = completed
    }
} 