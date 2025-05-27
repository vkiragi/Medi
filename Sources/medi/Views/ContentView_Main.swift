import SwiftUI

public struct ContentView_Main: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            MeditationView()
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
        }
        .accentColor(.purple)
    }
}

// Placeholder views (you already have these implemented in your Xcode project)
public struct MeditationView: View {
    public var body: some View {
        Text("Meditation View")
    }
}

public struct GuidedMeditationListView: View {
    public var body: some View {
        Text("Guided Meditation View")
    }
}

public struct HistoryView: View {
    public var body: some View {
        Text("History View")
    }
}

public struct ProfileView: View {
    public var body: some View {
        Text("Profile View")
    }
} 