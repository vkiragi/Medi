import SwiftUI

public struct HistoryView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @EnvironmentObject var authManager: AuthManager
    @State private var isRefreshing = false
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                if meditationManager.completedSessions.isEmpty && !meditationManager.isSyncing {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "leaf.circle")
                            .font(.system(size: 80))
                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.5))
                        
                        Text("No sessions yet")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        Text("Complete your first meditation")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                        
                        // Sync button for signed-in users
                        if let userId = authManager.userID, !userId.hasPrefix("anonymous_") {
                            Button("Sync from Cloud") {
                                Task {
                                    await refreshData()
                                }
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                            .cornerRadius(20)
                            .padding(.top, 20)
                        }
                    }
                } else {
                    // Sessions list
                    ScrollView {
                        VStack(spacing: 15) {
                            // Cloud sync status
                            if let userId = authManager.userID, !userId.hasPrefix("anonymous_") {
                                CloudSyncStatusView(
                                    isSyncing: meditationManager.isSyncing,
                                    syncStatus: meditationManager.syncStatus,
                                    onRefresh: {
                                        Task {
                                            await refreshData()
                                        }
                                    }
                                )
                                .padding(.horizontal)
                                .padding(.top)
                            }
                            
                            // Stats card
                            StatsCard(sessions: meditationManager.completedSessions)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // Sessions
                            ForEach(meditationManager.completedSessions.reversed()) { session in
                                SessionCard(session: session)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    .refreshable {
                        await refreshData()
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Auto-load data when view appears
                Task {
                    await loadData()
                }
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
}

struct StatsCard: View {
    let sessions: [MeditationSession]
    
    var totalMinutes: Int {
        Int(sessions.reduce(0) { $0 + $1.duration } / 60)
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    var currentStreak: Int {
        // Simple streak calculation - consecutive days
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedSessions = sessions.sorted { $0.date > $1.date }
        var streak = 1
        var lastDate = sortedSessions.first!.date
        
        for i in 1..<sortedSessions.count {
            let date = sortedSessions[i].date
            if calendar.isDate(date, inSameDayAs: lastDate) {
                continue
            } else if let daysBetween = calendar.dateComponents([.day], from: date, to: lastDate).day,
                      daysBetween == 1 {
                streak += 1
                lastDate = date
            } else {
                break
            }
        }
        
        return streak
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Progress")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
            
            HStack(spacing: 30) {
                StatItem(value: "\(totalSessions)", label: "Sessions")
                StatItem(value: "\(totalMinutes)", label: "Minutes")
                StatItem(value: "\(currentStreak)", label: "Day Streak")
            }
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct CloudSyncStatusView: View {
    let isSyncing: Bool
    let syncStatus: String?
    let onRefresh: () -> Void
    
    var body: some View {
        HStack {
            if isSyncing {
                ProgressView()
                    .scaleEffect(0.8)
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
            } else {
                Image(systemName: "icloud.fill")
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isSyncing ? "Syncing..." : "Cloud Sync")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                
                if let status = syncStatus {
                    Text(status)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
            }
            
            Spacer()
            
            Button("Refresh") {
                onRefresh()
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
            .disabled(isSyncing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
            
            Text(label)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
        }
    }
}

struct SessionCard: View {
    let session: MeditationSession
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: "leaf.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                .frame(width: 50, height: 50)
                .background(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(formattedDate)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                
                Text("\(Int(session.duration / 60)) minutes")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            }
            
            Spacer()
            
            if session.completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.4))
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
} 