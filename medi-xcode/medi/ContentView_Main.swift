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
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(2)
            
            MoodInsightsView()
                .tabItem {
                    Label("Insights", systemImage: "lightbulb.fill")
                }
                .tag(3)
        }
        .accentColor(Color.white) // White for selected tabs
        .onAppear {
            // Force tab bar background color after view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    if let tabBarController = window.rootViewController?.children.first as? UITabBarController {
                        // Try a more visible color for testing
                        let purpleColor = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 1.0)
                        tabBarController.tabBar.backgroundColor = purpleColor
                        tabBarController.tabBar.barTintColor = purpleColor
                        
                        // Also try setting the appearance directly on the tab bar
                        let appearance = UITabBarAppearance()
                        appearance.configureWithOpaqueBackground()
                        appearance.backgroundColor = purpleColor
                        tabBarController.tabBar.standardAppearance = appearance
                        tabBarController.tabBar.scrollEdgeAppearance = appearance
                        
                        // Force layout update
                        tabBarController.tabBar.setNeedsLayout()
                        tabBarController.tabBar.layoutIfNeeded()
                    }
                }
            }
        }

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


