import SwiftUI

struct ContentView_Main: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var selectedTab = 0
    
    var body: some View {
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
        }
        .accentColor(.purple)
    }
}
