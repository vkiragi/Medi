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
        // Initialize with your Supabase URL and anon key
        let supabaseUrl = URL(string: "YOUR_SUPABASE_URL")!
        let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
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