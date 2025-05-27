import SwiftUI
import medi

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var meditationManager: MeditationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile Header
                        VStack(spacing: 15) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                            }
                            
                            VStack(spacing: 5) {
                                Text(authManager.userName ?? "Meditator")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                
                                if let email = authManager.userEmail {
                                    Text(email)
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                                } else if authManager.userID?.starts(with: "anonymous") == true {
                                    Text("Anonymous User")
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Stats Summary
                        VStack(spacing: 20) {
                            Text("Your Journey")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                            
                            HStack(spacing: 30) {
                                StatCard(
                                    value: "\(meditationManager.completedSessions.count)",
                                    label: "Sessions"
                                )
                                
                                StatCard(
                                    value: "\(Int(meditationManager.completedSessions.reduce(0) { $0 + $1.duration } / 60))",
                                    label: "Minutes"
                                )
                                
                                StatCard(
                                    value: "\(calculateStreak())",
                                    label: "Day Streak"
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Settings
                        VStack(spacing: 15) {
                            Text("Settings")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: Text("Notifications Settings")) {
                                    SettingsRow(
                                        icon: "bell.fill",
                                        title: "Notifications",
                                        subtitle: "Daily meditation reminders"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: SyncSettingsView()) {
                                    SettingsRow(
                                        icon: "icloud.fill",
                                        title: "Data Sync",
                                        subtitle: authManager.userID?.starts(with: "anonymous") == true ? "Sign in to sync data" : "Synced with Apple ID"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: Text("Help & Support")) {
                                    SettingsRow(
                                        icon: "questionmark.circle.fill",
                                        title: "Help & Support",
                                        subtitle: "Get help with the app"
                                    )
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                        }
                        
                        // Sign Out Button
                        Button(action: {
                            authManager.signOut()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.9, green: 0.5, blue: 0.5))
                            .cornerRadius(25)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func calculateStreak() -> Int {
        guard !meditationManager.completedSessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedSessions = meditationManager.completedSessions.sorted { $0.date > $1.date }
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
}

struct StatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
            
            Text(label)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
} 