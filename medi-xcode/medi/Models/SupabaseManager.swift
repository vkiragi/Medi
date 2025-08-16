import Foundation
import Supabase
import Combine

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
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
        
        // Configure for better simulator compatibility
        // Note: URLSessionConfiguration is not used in this version
        
        print("🔗 Supabase client initialized for: \(supabaseUrl.absoluteString)")
        print("📅 Configured for ISO 8601 date handling")
        
        // Set the initial last sync date
        lastSyncDate = UserDefaults.standard.object(forKey: "lastSupabaseSync") as? Date
    }
    
    // MARK: - Profile Management
    
    /// Fetches the user profile from Supabase or creates one if it doesn't exist
    @MainActor
    func getOrCreateProfile(for userId: String, email: String?, name: String?) async {
        guard !userId.isEmpty else { return }
        
        print("👤 Getting or creating profile for user: \(userId)")
        
        do {
            isSyncing = true
            syncError = nil
            
            // Try to get existing profile (without .single() to avoid error on empty results)
            let response = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .execute()
            
            // Debug: Print raw response data
            if let rawString = String(data: response.data, encoding: .utf8) {
                print("🔍 Raw profile response: \(rawString)")
            }
            
            // Check if profile exists by parsing the response data
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Configure decoder to handle ISO date strings
            
            // Try flexible date decoding if ISO8601 fails
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try different date formats
                let iso8601Formatter = ISO8601DateFormatter()
                
                let postgresFormatter1 = DateFormatter()
                postgresFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS+00"
                
                let postgresFormatter2 = DateFormatter()
                postgresFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss+00"
                
                let isoFormatter = DateFormatter()
                isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                
                // Add the exact Supabase format we saw in debug
                let supabaseFormatter = DateFormatter()
                supabaseFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'+00:00'"
                
                // Try ISO8601 first
                if let date = iso8601Formatter.date(from: dateString) {
                    return date
                }
                
                // Try DateFormatter options
                let dateFormatters = [supabaseFormatter, postgresFormatter1, postgresFormatter2, isoFormatter]
                for formatter in dateFormatters {
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot decode date from: \(dateString)")
                )
            }
            
            let existingProfiles = try decoder.decode([ProfileData].self, from: response.data)
            
            if existingProfiles.isEmpty {
                // No profile exists, create one
                print("📝 Creating new profile for user: \(userId)")
                try await client
                    .from("profiles")
                    .insert(ProfileData(
                        id: userId,
                        email: email,
                        name: name,
                        created_at: Date(),
                        last_sign_in: Date()
                    ))
                    .execute()
                
                print("✅ Created new profile for user: \(userId)")
            } else {
                // Profile exists, update last sign in date
                print("🔄 Updating existing profile for user: \(userId)")
                try await client
                    .from("profiles")
                    .update(["last_sign_in": Date()])
                    .eq("id", value: userId)
                    .execute()
                
                print("✅ Updated existing profile for user: \(userId)")
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
    
    /// Updates the user profile in Supabase
    @MainActor
    func updateProfile(userId: String, email: String?, name: String?) async {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { return }
        
        print("🔄 Updating profile for user: \(userId)")
        
        do {
            isSyncing = true
            syncError = nil
            
            var updateData: [String: String] = [:]
            if let email = email {
                updateData["email"] = email
            }
            if let name = name {
                updateData["name"] = name
            }
            
            // Update the profile
            try await client
                .from("profiles")
                .update(updateData)
                .eq("id", value: userId)
                .execute()
            
            print("✅ Updated profile for user: \(userId)")
            
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSupabaseSync")
        } catch {
            isSyncing = false
            syncError = "Failed to update profile: \(error.localizedDescription)"
            print("Supabase profile update error: \(error)")
        }
    }
    
    // MARK: - Meditation Sessions
    
    /// Syncs local meditation sessions to Supabase
    @MainActor
    func syncMeditationSessions(userId: String, sessions: [MeditationSession]) async {
        print("🔄 Starting meditation session sync...")
        print("👤 User ID: \(userId)")
        print("📊 Local sessions count: \(sessions.count)")
        
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { 
            print("❌ Skipping sync - invalid user ID")
            return 
        }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get the sessions that are already synced
            print("🔍 Checking existing sessions in cloud...")
            let response = try await client
                .from("meditation_sessions")
                .select("session_id")
                .eq("user_id", value: userId)
                .execute()
            
            // Parse the response to get existing session IDs
            let decoder = JSONDecoder()
            let existingSessions = try decoder.decode([SessionIdOnly].self, from: response.data)
            let existingIds = Set(existingSessions.map { $0.session_id })
            
            print("☁️ Existing sessions in cloud: \(existingIds.count)")
            
            // Find sessions that need to be synced (not already in the cloud)
            let sessionsToSync = sessions.filter { !existingIds.contains($0.id.uuidString) }
            
            print("📤 Sessions to sync: \(sessionsToSync.count)")
            
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
                
                print("📋 Cloud sessions to insert:")
                for (index, session) in cloudSessions.enumerated() {
                    print("  \(index + 1). ID: \(session.session_id), Date: \(session.date), Duration: \(session.duration)s, Completed: \(session.completed)")
                }
                
                // Upload new sessions
                print("🚀 Inserting sessions into cloud...")
                let insertResponse = try await client
                    .from("meditation_sessions")
                    .insert(cloudSessions)
                    .execute()
                
                print("📡 Insert response received")
                print("📄 Response data: \(String(data: insertResponse.data, encoding: .utf8) ?? "Unable to decode")")
                
                // Check if the insert was successful
                if let responseData = String(data: insertResponse.data, encoding: .utf8) {
                    print("✅ Insert response: \(responseData)")
                }
                
                print("✅ Successfully synced \(sessionsToSync.count) new meditation sessions")
            } else {
                print("ℹ️ No new sessions to sync")
            }
            
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSupabaseSync")
        } catch {
            isSyncing = false
            syncError = "Failed to sync sessions: \(error.localizedDescription)"
            print("❌ Supabase session sync error: \(error)")
            print("🔍 Error details: \(error)")
        }
    }
    
    /// Fetches all meditation sessions from Supabase for the current user
    @MainActor
    func fetchMeditationSessions(userId: String) async -> [MeditationSession]? {
        print("📥 SupabaseManager: Starting fetch for user: \(userId)")
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { 
            print("❌ SupabaseManager: Invalid user ID for fetch")
            return nil 
        }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get all sessions for this user
            print("🔍 SupabaseManager: Querying meditation_sessions table...")
            let response = try await client
                .from("meditation_sessions")
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            print("📡 SupabaseManager: Fetch response received")
            print("📄 SupabaseManager: Response data: \(String(data: response.data, encoding: .utf8) ?? "Unable to decode")")
            
            // Parse the response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try different date formats
                let iso8601Formatter = ISO8601DateFormatter()
                
                let supabaseFormatter = DateFormatter()
                supabaseFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'+00:00'"
                
                let postgresFormatter = DateFormatter()
                postgresFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
                
                // Try parsing with different formatters
                if let date = iso8601Formatter.date(from: dateString) {
                    return date
                } else if let date = supabaseFormatter.date(from: dateString) {
                    return date
                } else if let date = postgresFormatter.date(from: dateString) {
                    return date
                } else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Unable to parse date string: \(dateString)"
                    )
                }
            }
            
            let cloudSessions = try decoder.decode([CloudSession].self, from: response.data)
            
            print("✅ SupabaseManager: Successfully decoded \(cloudSessions.count) sessions from cloud")
            
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
    func syncMoodSessions(userId: String, moodSessions: [MoodSession]) async {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { 
            print("🚫 Skipping sync - anonymous user")
            return 
        }
        
        print("🔄 Starting mood sync for user: \(userId)")
        print("📊 Syncing \(moodSessions.count) mood sessions")
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get existing mood sessions with detailed debugging
            print("🔍 Checking existing mood sessions...")
            print("🌐 About to make Supabase request...")
            
            // Try a simpler approach first - let's see if we can even connect
            let startTime = Date()
            print("⏱️ Request started at: \(startTime)")
            
            // Manual timeout approach - race between request and timeout
            let response = try await withTimeout(seconds: 15) {
                try await self.client
                    .from("mood_sessions")
                    .select("id")
                    .eq("user_id", value: userId)
                    .execute()
            }
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            print("✅ Supabase request completed in \(String(format: "%.2f", duration)) seconds")
            
            // Debug: Print raw response data
            if let rawString = String(data: response.data, encoding: .utf8) {
                print("🔍 Raw Supabase response: \(rawString)")
            }
            
            // Simple struct for ID-only query
            struct SimpleMoodSessionId: Codable {
                let id: String
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Configure decoder to handle ISO date strings
            let existingMoodSessions = try decoder.decode([SimpleMoodSessionId].self, from: response.data)
            let existingIds = Set(existingMoodSessions.map { $0.id.lowercased() })
            
            print("✅ Found \(existingIds.count) existing mood sessions")
            
            // Find sessions that need to be synced (case-insensitive comparison)
            let sessionsToSync = moodSessions.filter { !existingIds.contains($0.id.uuidString.lowercased()) }
            
            if !sessionsToSync.isEmpty {
                print("⬆️ Uploading \(sessionsToSync.count) new mood sessions...")
                let cloudMoodSessions = sessionsToSync.map { CloudMoodSession(from: $0, userId: userId) }
                
                // Debug: Print what we're trying to insert
                print("📝 Sample mood session data:")
                if let firstSession = cloudMoodSessions.first {
                    print("   - ID: \(firstSession.id)")
                    print("   - User ID: \(firstSession.user_id)")
                    print("   - Mood: \(firstSession.mood_state)")
                }
                
                let uploadStartTime = Date()
                try await client
                    .from("mood_sessions")
                    .insert(cloudMoodSessions)
                    .execute()
                
                let uploadEndTime = Date()
                let uploadDuration = uploadEndTime.timeIntervalSince(uploadStartTime)
                print("🎉 Successfully synced \(sessionsToSync.count) mood sessions in \(String(format: "%.2f", uploadDuration)) seconds")
            } else {
                print("✨ All mood sessions already synced")
            }
            
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSupabaseSync")
        } catch {
            isSyncing = false
            syncError = "Failed to sync mood sessions: \(error.localizedDescription)"
            print("❌ Supabase mood sync error: \(error)")
            print("🔧 Error details: \(error)")
            
            // Check if this is a network timeout
            if error.localizedDescription.contains("timeout") || error.localizedDescription.contains("network") {
                print("🌐 This appears to be a network connectivity issue")
                print("💡 Suggestion: Try running on a real device instead of simulator")
            }
        }
    }
    
    /// Fetches mood sessions from Supabase
    @MainActor
    func fetchMoodSessions(userId: String) async -> [MoodSession]? {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { return nil }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get all mood sessions for this user
            let response = try await client
                .from("mood_sessions")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
            
            let decoder = JSONDecoder()
            
            // Use the same flexible date decoding strategy as profiles
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try exact Supabase format first
                let supabaseFormatter = DateFormatter()
                supabaseFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'+00:00'"
                if let date = supabaseFormatter.date(from: dateString) {
                    return date
                }
                
                // Fallback to ISO8601
                let iso8601Formatter = ISO8601DateFormatter()
                if let date = iso8601Formatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot decode date from: \(dateString)")
                )
            }
            
            let cloudMoodSessions = try decoder.decode([CloudMoodSession].self, from: response.data)
            
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

// Helper function for timeouts
extension SupabaseManager {
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            
            group.cancelAll()
            return result
        }
    }
}

struct TimeoutError: Error {
    let description = "Operation timed out"
}

// MARK: - Data Models

/// Profile data for Supabase
struct ProfileData: Codable {
    let id: String
    let email: String?
    let name: String?
    let created_at: Date
    let last_sign_in: Date
}

/// Cloud session format for Supabase
struct CloudSession: Codable {
    let session_id: String
    let user_id: String
    let date: Date
    let duration: Int
    let completed: Bool
    
    // Custom initializer for manual creation
    init(session_id: String, user_id: String, date: Date, duration: Int, completed: Bool) {
        self.session_id = session_id
        self.user_id = user_id
        self.date = date
        self.duration = duration
        self.completed = completed
    }
    
    // Custom decoding to handle ISO 8601 date strings
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        session_id = try container.decode(String.self, forKey: .session_id)
        user_id = try container.decode(String.self, forKey: .user_id)
        duration = try container.decode(Int.self, forKey: .duration)
        completed = try container.decode(Bool.self, forKey: .completed)
        
        // Handle date as string and convert to Date
        let dateString = try container.decode(String.self, forKey: .date)
        
        // Try different date formats
        let iso8601Formatter = ISO8601DateFormatter()
        
        let supabaseFormatter = DateFormatter()
        supabaseFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'+00:00'"
        
        let postgresFormatter = DateFormatter()
        postgresFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
        
        // Try parsing with different formatters
        if let date = iso8601Formatter.date(from: dateString) {
            self.date = date
        } else if let date = supabaseFormatter.date(from: dateString) {
            self.date = date
        } else if let date = postgresFormatter.date(from: dateString) {
            self.date = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .date,
                in: container,
                debugDescription: "Unable to parse date string: \(dateString)"
            )
        }
    }
    
    // Custom encoding to output ISO 8601 strings
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(session_id, forKey: .session_id)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(duration, forKey: .duration)
        try container.encode(completed, forKey: .completed)
        
        // Encode date as ISO 8601 string
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        try container.encode(dateString, forKey: .date)
    }
    
    private enum CodingKeys: String, CodingKey {
        case session_id, user_id, date, duration, completed
    }
}

/// Lightweight struct for querying only session IDs
struct SessionIdOnly: Codable {
    let session_id: String
}

/// Cloud mood session format for Supabase
struct CloudMoodSession: Codable {
    let id: String
    let user_id: String
    let meditation_session_id: String?
    let mood_state: String
    let mood_intensity: Int?
    let stress_level: Int?
    let energy_level: Int?
    let post_meditation_mood: Int?
    let meditation_type: String?
    let meditation_duration_minutes: Int?
    let completed_meditation: Bool
    let context_tags: [String]?
    let notes: String?
    let created_at: Date
    let meditation_completed_at: Date?
    
    init(from moodSession: MoodSession, userId: String) {
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
