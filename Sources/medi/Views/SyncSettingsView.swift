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
                            iconColor: .orange,
                            title: "Sync not available",
                            message: "Sign in with Apple to enable cloud sync."
                        )
                    } else {
                        InfoBox(
                            iconName: "checkmark.circle",
                            iconColor: .green,
                            title: "Sync enabled",
                            message: "Your sessions will sync across devices."
                        )
                    }
                } else {
                    InfoBox(
                        iconName: "exclamationmark.triangle",
                        iconColor: .orange,
                        title: "Not signed in",
                        message: "Sign in to enable cloud sync."
                    )
                }
            }
            
            // Last sync info
            if let lastSync = supabaseManager.lastSyncDate, !authManager.userID.isNilOrAnonymous {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("Last synced: \(lastSync.timeAgoDisplay())")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
            }
            
            // Sync button
            if !authManager.userID.isNilOrAnonymous {
                Button {
                    syncNow()
                } label: {
                    HStack {
                        Image(systemName: isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                        Text(isSyncing ? "Syncing..." : "Sync Now")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.2, green: 0.6, blue: 0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isSyncing)
                .padding(.top, 10)
                
                // Status message
                if let syncStatus = meditationManager.syncStatus {
                    Text(syncStatus)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sync Settings")
    }
    
    private func syncNow() {
        guard let userId = authManager.userID, !userId.hasPrefix("anonymous_") else { return }
        
        isSyncing = true
        
        Task {
            await meditationManager.syncWithCloud(userId: userId)
            isSyncing = false
        }
    }
}

// MARK: - Helper Views

struct InfoBox: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let message: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                
                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Extensions

extension Optional where Wrapped == String {
    var isNilOrAnonymous: Bool {
        if let value = self {
            return value.hasPrefix("anonymous_")
        }
        return true
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
} 