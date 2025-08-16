import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @EnvironmentObject var authManager: AuthManager
    @State private var isRefreshing = false
    @State private var showingSyncStatus = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Quyo-style purple gradient background (identical to HomeView)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.2, blue: 0.8),  // Deep purple
                        Color(red: 0.6, green: 0.3, blue: 0.9),  // Medium purple
                        Color(red: 0.8, green: 0.4, blue: 1.0)   // Light purple
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all, edges: .all) // Ensure gradient covers all edges including bottom
                
                VStack(spacing: 0) {
                    // Custom App Title
                    AppTitle("History")
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                    
                    if meditationManager.completedSessions.isEmpty && !meditationManager.isSyncing {
                        // Empty state (matching HomeView card style)
                        VStack(spacing: 20) {
                            Image(systemName: "leaf.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("No sessions yet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Complete your first meditation to see it here")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            // Sync button for signed-in users (HomeView card style)
                            if let userId = authManager.userID, !userId.hasPrefix("anonymous_") {
                                Button("Sync from Cloud") {
                                    Task {
                                        await refreshData()
                                    }
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(minHeight: 44)
                                .padding(.horizontal, 20)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(20)
                                .padding(.top, 20)
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 100) // Add bottom padding for tab bar
                    } else {
                        // Content with sessions
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // Sync status header (HomeView card style)
                                if let userId = authManager.userID, !userId.hasPrefix("anonymous_") {
                                    HStack {
                                        if meditationManager.isSyncing {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .foregroundColor(.white.opacity(0.8))
                                        } else {
                                            Image(systemName: "icloud.fill")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(meditationManager.isSyncing ? "Syncing..." : "Cloud Sync")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            if let status = meditationManager.syncStatus {
                                                Text(status)
                                                    .font(.system(size: 12, weight: .light))
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .lineLimit(2)
                                            }
                                            
                                            // Debug info
                                            Text("Local: \(meditationManager.completedSessions.count) sessions")
                                                .font(.system(size: 10, weight: .light))
                                                .foregroundColor(.white.opacity(0.6))
                                            
                                            Text("User: \(String(userId.prefix(8)))...")
                                                .font(.system(size: 10, weight: .light))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            if meditationManager.isSyncing {
                                                // Show reset button if syncing for too long
                                                Button("Reset") {
                                                    meditationManager.resetSyncState()
                                                }
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.white.opacity(0.6))
                                                .frame(minHeight: 32)
                                                .padding(.horizontal, 8)
                                                .background(Color.white.opacity(0.1))
                                                .cornerRadius(8)
                                            }
                                            
                                            Button("Refresh") {
                                                Task {
                                                    await refreshData()
                                                }
                                            }
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                            .frame(minHeight: 44)
                                            .disabled(meditationManager.isSyncing)
                                        }
                                    }
                                    .padding(20)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(20)
                                    .padding(.horizontal, 20)
                                }
                                
                                // Group by month
                                ForEach(groupedSessions.keys.sorted(by: >), id: \.self) { month in
                                    VStack(alignment: .leading, spacing: 16) {
                                        // Section header (matching HomeView style)
                                        Text(month)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                        
                                        // Sessions for this month
                                        ForEach(groupedSessions[month]!) { session in
                                            SessionCard(session: session)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 40)
                            .padding(.bottom, 100) // Add bottom padding for tab bar
                        }
                        .refreshable {
                            await refreshData()
                        }
                    }
                }
            }
            .navigationBarHidden(true) // Hide default navigation bar
            .onAppear {
                // Auto-load data when view appears
                Task {
                    await loadData()
                }
                
                // Check for stuck sync and reset if needed
                meditationManager.checkAndResetStuckSync()
            }
        }
    }
    
    private func loadData() async {
        guard let userId = authManager.userID, !userId.hasPrefix("anonymous_") else { return }
        
        // Load data from cloud if user is signed in
        await meditationManager.syncWithCloud(userId: userId)
    }
    
    private func refreshData() async {
        guard let userId = authManager.userID, !userId.hasPrefix("anonymous_") else { return }
        
        isRefreshing = true
        await meditationManager.syncWithCloud(userId: userId)
        isRefreshing = false
    }
    
    // Group sessions by month
    private var groupedSessions: [String: [MeditationSession]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        var result = [String: [MeditationSession]]()
        let sortedSessions = meditationManager.completedSessions.sorted(by: { $0.date > $1.date })
        
        for session in sortedSessions {
            let monthKey = dateFormatter.string(from: session.date)
            if result[monthKey] == nil {
                result[monthKey] = []
            }
            result[monthKey]?.append(session)
        }
        
        return result
    }
}

struct SessionCard: View {
    let session: MeditationSession
    
    var body: some View {
        HStack {
            // Icon - different for completed vs partial (HomeView translucent style)
            Image(systemName: session.completed ? "leaf.fill" : "leaf")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())
            
            // Session details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if !session.completed {
                        Text("(partial)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Text("\(Int(session.duration / 60)) minutes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Completion status
            if session.completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "clock.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.15))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
}

// MARK: - Previews
#Preview("History View - Empty") {
    HistoryView()
        .environmentObject(MeditationManager())
        .environmentObject(AuthManager())
}

#Preview("History View - With Sessions") {
    let manager = MeditationManager()
    // Add some sample sessions for preview
    return HistoryView()
        .environmentObject(manager)
        .environmentObject(AuthManager())
}

#Preview("History View - Dark Mode") {
    HistoryView()
        .environmentObject(MeditationManager())
        .environmentObject(AuthManager())
        .preferredColorScheme(.dark)
}

#Preview("History View - Large Text") {
    HistoryView()
        .environmentObject(MeditationManager())
        .environmentObject(AuthManager())
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
} 