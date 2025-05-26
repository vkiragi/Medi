import SwiftUI

@main
struct MediApp: App {
    @StateObject private var meditationManager = MeditationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(meditationManager)
                .preferredColorScheme(.light)
        }
    }
} 