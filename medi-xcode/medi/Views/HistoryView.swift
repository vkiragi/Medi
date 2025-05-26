import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                if meditationManager.completedSessions.isEmpty {
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
                    }
                } else {
                    // Sessions list
                    ScrollView {
                        VStack(spacing: 15) {
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
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
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