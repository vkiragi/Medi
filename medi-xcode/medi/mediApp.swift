import SwiftUI
import UIKit

// MARK: - UI Appearance Configuration
enum TabBarStyle {
    static func apply() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial) // soft blur
        appearance.backgroundColor = .clear                                         // keep gradient visible
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.15)             // subtle top divider

        // Selected tab styling
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]
        
        // Unselected tab styling
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }
}

@main
struct MediApp: App {
    @StateObject private var meditationManager = MeditationManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    init() {
        // Configure blurred tab bar appearance globally
        TabBarStyle.apply() // ensure applied BEFORE any TabView is created
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
