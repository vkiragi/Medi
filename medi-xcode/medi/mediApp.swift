import SwiftUI

@main
struct MediApp: App {
    @StateObject private var meditationManager = MeditationManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    init() {
        // Configure tab bar appearance globally
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 1.0) // More visible purple background
        
        // Selected tab styling
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]
        
        // Unselected tab styling
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Also try setting the background color directly
        UITabBar.appearance().backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 1.0)
        UITabBar.appearance().barTintColor = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 1.0)
        
        // Force the appearance to be applied
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barStyle = .default
    }
    
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
