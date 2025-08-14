import SwiftUI
import medi

struct ContentView_Main: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    @State private var showingMoodCheckIn = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ZStack {
                MeditationView()
                
                // Top-right mood check-in button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingMoodCheckIn = true
                        }) {
                            HStack(spacing: 6) {
                                Text("🧠")
                                    .font(.system(size: 16))
                                Text("Check-in")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                    }
                    Spacer()
                }
            }
            .tabItem {
                Label("Meditate", systemImage: "leaf.fill")
            }
            .tag(0)
            
            GuidedMeditationListView()
                .tabItem {
                    Label("Meditations", systemImage: "waveform.circle.fill")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
            
            MoodInsightsView()
                .tabItem {
                    Label("Insights", systemImage: "brain.head.profile")
                }
                .tag(4)
        }
        .accentColor(.purple)
        .sheet(isPresented: $showingMoodCheckIn) {
            MoodCheckInView { mood in
                meditationManager.createMoodSession(mood: mood, userId: authManager.userID)
                // Don't dismiss here - let the MoodCheckInView handle the full flow
            } onDismiss: {
                showingMoodCheckIn = false
            }
        }
    }
}
