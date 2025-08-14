import SwiftUI

@main
struct MediApp: App {
    @StateObject private var meditationManager = MeditationManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isSignedIn {
                ContentView_Main()
                    .environmentObject(meditationManager)
                    .environmentObject(authManager)
                    .environmentObject(subscriptionManager)
                    .preferredColorScheme(.light)
            } else {
                SignInView()
                    .environmentObject(authManager)
                    .environmentObject(subscriptionManager)
                    .preferredColorScheme(.light)
            }
        }
    }
}
