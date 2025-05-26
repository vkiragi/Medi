import SwiftUI

@main
struct MediApp: App {
    @StateObject private var meditationManager = MeditationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView_Main()
                .environmentObject(meditationManager)
                .preferredColorScheme(.light)
        }
    }
}
