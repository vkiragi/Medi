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
        // Initialize with your Supabase URL and anon key - replace with your actual values
        let supabaseUrl = URL(string: "https://abcdefghijklmn.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE2Mzk3MzY1ODMsImV4cCI6MTk1NTMxMjU4M30.YOUR_SUPABASE_KEY"
        self.client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
        
        // Set the initial last sync date
        lastSyncDate = UserDefaults.standard.object(forKey: "lastSupabaseSync") as? Date
    }
    
    // MARK: - Profile Management
    
    /// Fetches the user profile from Supabase or creates one if it doesn't exist
    @MainActor
    func getOrCreateProfile(for userId: String, email: String?, name: String?) async {
        guard !userId.isEmpty else { return }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Try to get existing profile
            let response = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
            
            // If no profile exists, create one
            if response.count == 0 {
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
                
                print("Created new profile for user: \(userId)")
            } else {
                // Update last sign in date
                try await client
                    .from("profiles")
                    .update(["last_sign_in": Date()])
                    .eq("id", value: userId)
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
    func syncMeditationSessions(userId: String, sessions: [MeditationSession]) async {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { return }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get the sessions that are already synced
            let response = try await client
                .from("meditation_sessions")
                .select("session_id")
                .eq("user_id", value: userId)
                .execute()
            
            // Parse the response to get existing session IDs
            let decoder = JSONDecoder()
            let existingSessions = try decoder.decode([CloudSession].self, from: response.data)
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
                try await client
                    .from("meditation_sessions")
                    .insert(cloudSessions)
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
    func fetchMeditationSessions(userId: String) async -> [MeditationSession]? {
        guard !userId.isEmpty, !userId.hasPrefix("anonymous_") else { return nil }
        
        do {
            isSyncing = true
            syncError = nil
            
            // Get all sessions for this user
            let response = try await client
                .from("meditation_sessions")
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            // Parse the response
            let decoder = JSONDecoder()
            let cloudSessions = try decoder.decode([CloudSession].self, from: response.data)
            
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
} 