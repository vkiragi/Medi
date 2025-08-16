import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @EnvironmentObject var authManager: AuthManager
    @State private var isRefreshing = false
    @State private var showingSyncStatus = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Quyo-style purple gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.2, blue: 0.8),  // Deep purple
                        Color(red: 0.6, green: 0.3, blue: 0.9),  // Medium purple
                        Color(red: 0.8, green: 0.4, blue: 1.0)   // Light purple
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if meditationManager.completedSessions.isEmpty && !meditationManager.isSyncing {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "leaf.circle")
                            .font(.system(size: 80))
                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.5))
                        
                        Text("No sessions yet")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("Complete your first meditation to see it here")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
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
                    // List of sessions
                    List {
                        // Sync status header
                        if let userId = authManager.userID, !userId.hasPrefix("anonymous_") {
                            Section {
                                HStack {
                                    if meditationManager.isSyncing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                    } else {
                                        Image(systemName: "icloud.fill")
                                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(meditationManager.isSyncing ? "Syncing..." : "Cloud Sync")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        if let status = meditationManager.syncStatus {
                                            Text(status)
                                                .font(.system(size: 12, weight: .light))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Refresh") {
                                        Task {
                                            await refreshData()
                                        }
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                    .disabled(meditationManager.isSyncing)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        // Group by month
                        ForEach(groupedSessions.keys.sorted(by: >), id: \.self) { month in
                            Section(header: Text(month)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))) {
                                ForEach(groupedSessions[month]!) { session in
                                    SessionCard(session: session)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
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
            // Icon - different for completed vs partial
            Image(systemName: session.completed ? "leaf.fill" : "leaf")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
            
            // Session details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    if !session.completed {
                        Text("(partial)")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Text("\(Int(session.duration / 60)) minutes")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Completion status
            if session.completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "clock.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
} 