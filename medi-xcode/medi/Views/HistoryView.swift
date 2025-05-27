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
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                        
                        Text("Complete your first meditation to see it here")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    // List of sessions
                    List {
                        // Group by month
                        ForEach(groupedSessions.keys.sorted(by: >), id: \.self) { month in
                            Section(header: Text(month)) {
                                ForEach(groupedSessions[month]!) { session in
                                    SessionCard(session: session)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
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
            // Icon
            Image(systemName: "leaf.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                .frame(width: 40, height: 40)
                .background(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.2))
                .clipShape(Circle())
            
            // Session details
            VStack(alignment: .leading, spacing: 4) {
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
        .padding(.vertical, 8)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
} 