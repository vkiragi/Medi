import SwiftUI

struct ContentView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MeditationView()
                .tabItem {
                    Label("Meditate", systemImage: "leaf.fill")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)
        }
        .accentColor(Color("AccentColor"))
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar) // matches the blur
        .toolbarColorScheme(.light, for: .tabBar)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MeditationManager())
    }
} 