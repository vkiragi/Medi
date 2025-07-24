import Foundation
import Supabase
import Combine

public class SupabaseManager: ObservableObject {
    public static let shared = SupabaseManager()
    
    public let client: SupabaseClient
    
    @Published public var isSyncing = false
    @Published public var lastSyncDate: Date?
    @Published public var syncError: String?
    
    private init() {
        // ⚠️ REPLACE THESE WITH YOUR ACTUAL SUPABASE CREDENTIALS ⚠️
        // Get these from: https://supabase.com/dashboard → Your Project → Settings → API
        
        let supabaseUrl = URL(string: "https://ynrrhthrjpztqluhbhfj.supabase.co")! // e.g., "https://yourproject.supabase.co"
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucnJodGhyanB6dHFsdWhiaGZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMTUwNTMsImV4cCI6MjA2MDc5MTA1M30.GvZNoCDvjY6rLCHy4-Twi5iWtqk8T7ZR7XqaLnaOsgE" // Your anon/public key from dashboard
        
        // Validate credentials are set
        if supabaseUrl.absoluteString.contains("YOUR_SUPABASE") || supabaseKey.contains("YOUR_SUPABASE") {
            print("❌ SUPABASE ERROR: Please update your Supabase credentials in SupabaseManager.swift")
            print("📖 Instructions: https://supabase.com/dashboard → Settings → API")
        }
        
        self.client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
        
        // Set the initial last sync date
        lastSyncDate = UserDefaults.standard.object(forKey: "lastSupabaseSync") as? Date
    }
    
    // MARK: - Profile Management
    
    /// Fetches the user profile from Supabase or creates one if it doesn't exist
    @MainActor
    public func getOrCreateProfile(for userId: String, email: String?, name: String?) async {
        guard !userId.isEmpty else { return }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Try to get existing profile
            let response = try await client.database
                .from("profiles")
                .select()
                .eq(column: "id", value: userId)
                .single()
                .execute()
            
            // If no profile exists, create one
            if response.count == 0 {
                try await client.database
                    .from("profiles")
                    .insert(values: ProfileData(
                        id: userId,
                        email: email,
                        name: name,
                        created_at: Date(),
                        last_sign_in: Date()
                    ))
                    .execute()
                
                print("Created new profile for user: \(userId)")
            } else {
                // Update last sign in date
                try await client.database
                    .from("profiles")
                    .update(values: ["last_sign_in": Date()])
                    .eq(column: "id", value: userId)
                    .execute()
                
                print("Updated existing profile for user: \(userId)")
            }
            
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSupabaseSync")
        } catch {
            isSyncing = false
            syncError = "Failed to sync profile: \(error.localizedDescription)"
            print("Supabase profile sync error: \(error)")
        }
    }
    
    // MARK: - Meditation Sessions
    
    /// Syncs local meditation sessions to Supabase
    @MainActor
    public func syncMeditationSessions(userId: String, sessions: [MeditationSession]) async {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { return }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get the sessions that are already synced
            let existingSessions: [CloudSession] = try await client.database
                .from("meditation_sessions")
                .select(columns: "session_id")
                .eq(column: "user_id", value: userId)
                .execute()
                .value
            let existingIds = Set(existingSessions.map { $0.session_id })
            
            // Find sessions that need to be synced (not already in the cloud)
            let sessionsToSync = sessions.filter { !existingIds.contains($0.id.uuidString) }
            
            if !sessionsToSync.isEmpty {
                // Convert local sessions to cloud format
                let cloudSessions = sessionsToSync.map { session in
                    CloudSession(
                        session_id: session.id.uuidString,
                        user_id: userId,
                        date: session.date,
                        duration: Int(session.duration),
                        completed: session.completed
                    )
                }
                
                // Upload new sessions
                try await client.database
                    .from("meditation_sessions")
                    .insert(values: cloudSessions)
                    .execute()
                
                print("Synced \(sessionsToSync.count) new meditation sessions")
            }
            
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSupabaseSync")
        } catch {
            isSyncing = false
            syncError = "Failed to sync sessions: \(error.localizedDescription)"
            print("Supabase session sync error: \(error)")
        }
    }
    
    /// Fetches all meditation sessions from Supabase for the current user
    @MainActor
    public func fetchMeditationSessions(userId: String) async -> [MeditationSession]? {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { return nil }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get all sessions for this user
            let cloudSessions: [CloudSession] = try await client.database
                .from("meditation_sessions")
                .select()
                .eq(column: "user_id", value: userId)
                .execute()
                .value
            
            // Convert to local format
            let sessions = cloudSessions.map { cloudSession in
                MeditationSession(
                    id: UUID(uuidString: cloudSession.session_id) ?? UUID(),
                    date: cloudSession.date,
                    duration: TimeInterval(cloudSession.duration),
                    completed: cloudSession.completed
                )
            }
            
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSupabaseSync")
            
            return sessions
        } catch {
            isSyncing = false
            syncError = "Failed to fetch sessions: \(error.localizedDescription)"
            print("Supabase fetch error: \(error)")
            return nil
        }
    }
    
    // MARK: - Mood Sessions
    
    /// Syncs local mood sessions to Supabase
    @MainActor
    public func syncMoodSessions(userId: String, moodSessions: [MoodSession]) async {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { return }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get existing mood sessions
            let existingMoodSessions: [CloudMoodSession] = try await client.database
                .from("mood_sessions")
                .select(columns: "id")
                .eq(column: "user_id", value: userId)
                .execute()
                .value
            let existingIds = Set(existingMoodSessions.map { $0.id })
            
            // Find sessions that need to be synced
            let sessionsToSync = moodSessions.filter { !existingIds.contains($0.id.uuidString) }
            
            if !sessionsToSync.isEmpty {
                let cloudMoodSessions = sessionsToSync.map { CloudMoodSession(from: $0, userId: userId) }
                
                try await client.database
                    .from("mood_sessions")
                    .insert(values: cloudMoodSessions)
                    .execute()
                
                print("Synced \(sessionsToSync.count) mood sessions to Supabase")
            }
            
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSupabaseSync")
        } catch {
            isSyncing = false
            syncError = "Failed to sync mood sessions: \(error.localizedDescription)"
            print("Supabase mood sync error: \(error)")
        }
    }
    
    /// Fetches mood sessions from Supabase
    @MainActor
    public func fetchMoodSessions(userId: String) async -> [MoodSession]? {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { return nil }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get all mood sessions for this user
            let cloudMoodSessions: [CloudMoodSession] = try await client.database
                .from("mood_sessions")
                .select()
                .eq(column: "user_id", value: userId)
                .order(column: "created_at", ascending: false)
                .execute()
                .value
            
            // Convert to local format
            let moodSessions = cloudMoodSessions.compactMap { cloudSession -> MoodSession? in
                guard let moodState = MoodState(rawValue: cloudSession.mood_state) else { return nil }
                
                return MoodSession(
                    id: UUID(uuidString: cloudSession.id) ?? UUID(),
                    mood: moodState,
                    timestamp: cloudSession.created_at,
                    meditationSessionId: cloudSession.meditation_session_id.flatMap { UUID(uuidString: $0) },
                    postMoodRating: nil, // This would need to be added to schema if we want to sync it
                    moodIntensity: cloudSession.mood_intensity,
                    stressLevel: cloudSession.stress_level,
                    energyLevel: cloudSession.energy_level,
                    postMeditationMood: cloudSession.post_meditation_mood,
                    meditationType: cloudSession.meditation_type,
                    meditationDurationMinutes: cloudSession.meditation_duration_minutes,
                    completedMeditation: cloudSession.completed_meditation,
                    contextTags: cloudSession.context_tags ?? [],
                    notes: cloudSession.notes,
                    meditationCompletedAt: cloudSession.meditation_completed_at
                )
            }
            
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSupabaseSync")
            
            return moodSessions
        } catch {
            isSyncing = false
            syncError = "Failed to fetch mood sessions: \(error.localizedDescription)"
            print("Supabase mood fetch error: \(error)")
            return nil
        }
    }
}

// MARK: - Data Models

/// Profile data for Supabase
public struct ProfileData: Codable {
    public let id: String
    public let email: String?
    public let name: String?
    public let created_at: Date
    public let last_sign_in: Date
    
    public init(id: String, email: String?, name: String?, created_at: Date, last_sign_in: Date) {
        self.id = id
        self.email = email
        self.name = name
        self.created_at = created_at
        self.last_sign_in = last_sign_in
    }
}

/// Cloud session format for Supabase
public struct CloudSession: Codable {
    public let session_id: String
    public let user_id: String
    public let date: Date
    public let duration: Int
    public let completed: Bool
    
    public init(session_id: String, user_id: String, date: Date, duration: Int, completed: Bool) {
        self.session_id = session_id
        self.user_id = user_id
        self.date = date
        self.duration = duration
        self.completed = completed
    }
}

/// Cloud mood session format for Supabase
public struct CloudMoodSession: Codable {
    public let id: String
    public let user_id: String
    public let meditation_session_id: String?
    public let mood_state: String
    public let mood_intensity: Int?
    public let stress_level: Int?
    public let energy_level: Int?
    public let post_meditation_mood: Int?
    public let meditation_type: String?
    public let meditation_duration_minutes: Int?
    public let completed_meditation: Bool
    public let context_tags: [String]?
    public let notes: String?
    public let created_at: Date
    public let meditation_completed_at: Date?
    
    public init(from moodSession: MoodSession, userId: String) {
        self.id = moodSession.id.uuidString
        self.user_id = userId
        self.meditation_session_id = moodSession.meditationSessionId?.uuidString
        self.mood_state = moodSession.mood.rawValue
        self.mood_intensity = moodSession.moodIntensity
        self.stress_level = moodSession.stressLevel
        self.energy_level = moodSession.energyLevel
        self.post_meditation_mood = moodSession.postMeditationMood
        self.meditation_type = moodSession.meditationType
        self.meditation_duration_minutes = moodSession.meditationDurationMinutes
        self.completed_meditation = moodSession.completedMeditation
        self.context_tags = moodSession.contextTags.isEmpty ? nil : moodSession.contextTags
        self.notes = moodSession.notes
        self.created_at = moodSession.timestamp
        self.meditation_completed_at = moodSession.meditationCompletedAt
    }
} 