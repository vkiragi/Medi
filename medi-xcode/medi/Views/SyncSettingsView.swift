import SwiftUI

struct SyncSettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var meditationManager: MeditationManager
    @ObservedObject var supabaseManager = SupabaseManager.shared
    
    @State private var isSyncing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Cloud Sync")
                .font(.system(size: 24, weight: .medium))
                .padding(.top, 20)
            
            // Info section
            VStack(alignment: .leading, spacing: 8) {
                if let userId = authManager.userID {
                    if userId.hasPrefix("anonymous_") {
                        InfoBox(
                            iconName: "exclamationmark.triangle",
                            title: "Sign in required",
                            description: "Cloud sync is only available when signed in with your Apple ID.",
                            isPrimary: false
                        )
                    } else {
                        InfoBox(
                            iconName: "checkmark.circle",
                            title: "Account connected",
                            description: "Your data will sync automatically across your devices.",
                            isPrimary: true
                        )
                    }
                }
            }
            .padding(.vertical, 10)
            
            // Sync status
            if let syncError = supabaseManager.syncError {
                InfoBox(
                    iconName: "xmark.circle",
                    title: "Sync Error",
                    description: syncError,
                    isPrimary: false
                )
            }
            
            // Last sync time
            if let lastSync = supabaseManager.lastSyncDate, !isAnonymous(userId: authManager.userID) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("Last synced: \(lastSync.timeAgoDisplay())")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 5)
            }
            
            // Sync button
            if !isAnonymous(userId: authManager.userID) {
                Button {
                    Task {
                        isSyncing = true
                        if let userId = authManager.userID {
                            await meditationManager.syncWithCloud(userId: userId)
                        }
                        isSyncing = false
                    }
                } label: {
                    HStack {
                        Image(systemName: isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                        Text(isSyncing ? "Syncing..." : "Sync Now")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isSyncing || isAnonymous(userId: authManager.userID))
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sync Settings")
    }
    
    private func isAnonymous(userId: String?) -> Bool {
        guard let userId = userId else { return true }
        return userId.hasPrefix("anonymous_")
    }
}

struct InfoBox: View {
    let iconName: String
    let title: String
    let description: String
    let isPrimary: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: iconName)
                .font(.system(size: 22))
                .foregroundColor(isPrimary ? .blue : .orange)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
} 