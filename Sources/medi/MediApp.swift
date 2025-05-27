import SwiftUI

@main
struct MediApp: App {
    @StateObject private var meditationManager = MeditationManager()
    @StateObject private var authManager = AuthManager()
    
    // Initialize our environment formatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isSignedIn {
                ContentView()
                    .environmentObject(meditationManager)
                    .environmentObject(authManager)
                    .environment(\.dateFormatter, dateFormatter)
                    .environment(\.timeFormatter, timeFormatter)
                    .preferredColorScheme(.light)
            } else {
                SignInView()
                    .environmentObject(authManager)
                    .preferredColorScheme(.light)
            }
        }
    }
}

// MARK: - Environment Values

private struct DateFormatterKey: EnvironmentKey {
    static let defaultValue: DateFormatter = DateFormatter()
}

private struct TimeFormatterKey: EnvironmentKey {
    static let defaultValue: DateComponentsFormatter = DateComponentsFormatter()
}

extension EnvironmentValues {
    var dateFormatter: DateFormatter {
        get { self[DateFormatterKey.self] }
        set { self[DateFormatterKey.self] = newValue }
    }
    
    var timeFormatter: DateComponentsFormatter {
        get { self[TimeFormatterKey.self] }
        set { self[TimeFormatterKey.self] = newValue }
    }
} 