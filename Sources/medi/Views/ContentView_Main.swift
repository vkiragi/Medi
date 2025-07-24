import SwiftUI

public struct ContentView_Main: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    @State private var showingMoodCheckIn = false
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            ZStack {
                MeditationView()
                
                // Floating mood check-in button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingMoodCheckIn = true
                        }) {
                            HStack(spacing: 8) {
                                Text("🧠")
                                Text("How do you feel?")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100) // Above tab bar
                    }
                }
            }
            .tabItem {
                Label("Meditate", systemImage: "leaf.fill")
            }
            .tag(0)
            
            GuidedMeditationListView()
                .tabItem {
                    Label("Guided", systemImage: "waveform.circle.fill")
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
                meditationManager.createMoodSession(mood: mood)
                showingMoodCheckIn = false
            }
        }
    }
}

// Placeholder view for ProfileView (will implement next)
public struct ProfileView: View {
    public var body: some View {
        Text("Profile View")
    }
}