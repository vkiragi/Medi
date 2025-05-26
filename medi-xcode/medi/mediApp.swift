import SwiftUI

@main
struct MediApp: App {
    @StateObject private var meditationManager = MeditationManager()
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isSignedIn {
                ContentView_Main()
                    .environmentObject(meditationManager)
                    .environmentObject(authManager)
                    .preferredColorScheme(.light)
            } else {
                SignInView()
                    .environmentObject(authManager)
                    .preferredColorScheme(.light)
            }
        }
    }
}
