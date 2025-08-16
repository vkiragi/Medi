import SwiftUI
import medi

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var meditationManager: MeditationManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var showingEditProfile = false
    @State private var showingDataExport = false
    @State private var showingDeleteAccount = false
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Quyo-style purple gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.2, blue: 0.8),  // Deep purple
                        Color(red: 0.6, green: 0.3, blue: 0.9),  // Medium purple
                        Color(red: 0.8, green: 0.4, blue: 1.0)   // Light purple
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Header
                        VStack(spacing: 15) {
                            // Avatar with edit button
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                
                                // Edit button
                                Button(action: {
                                    showingEditProfile = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                                        .clipShape(Circle())
                                }
                                .offset(x: 35, y: 35)
                            }
                            
                            VStack(spacing: 5) {
                                Text(getDisplayName())
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                                
                                // Show prompt to set custom name if using fallback
                                if shouldShowNamePrompt() {
                                    Button("Set your name") {
                                        showingEditProfile = true
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                    .padding(.top, 5)
                                }
                                
                                if let email = authManager.userEmail {
                                    Text(email)
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(.white.opacity(0.8))
                                } else if authManager.userID?.starts(with: "anonymous") == true {
                                    Text("Anonymous User")
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                // Account status
                                HStack(spacing: 8) {
                                    if subscriptionManager.isSubscribed {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.yellow)
                                        Text("Premium Active")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.yellow)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.yellow.opacity(0.15))
                                            .cornerRadius(8)
                                    } else {
                                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                                            .font(.system(size: 14))
                                            .foregroundColor(.orange)
                                        Text("Free Tier")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.orange)
                                    }
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Meditation Stats
                        VStack(spacing: 20) {
                            HStack {
                                Text("Meditation Journey")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Sync status indicator
                                if let userId = authManager.userID, !userId.hasPrefix("anonymous_") {
                                    HStack(spacing: 6) {
                                        if meditationManager.isSyncing {
                                            ProgressView()
                                                .scaleEffect(0.6)
                                                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                        } else {
                                            Image(systemName: "icloud.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                        }
                                        
                                        Text(meditationManager.isSyncing ? "Syncing..." : "Cloud")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                }
                            }
                            
                            HStack(spacing: 15) {
                                StatCard(
                                    value: "\(meditationManager.completedSessions.count)",
                                    label: "Sessions",
                                    icon: "leaf.fill"
                                )
                                
                                StatCard(
                                    value: "\(Int(meditationManager.completedSessions.reduce(0) { $0 + $1.duration } / 60))",
                                    label: "Minutes",
                                    icon: "clock.fill"
                                )
                                
                                StatCard(
                                    value: "\(calculateStreak())",
                                    label: "Day Streak",
                                    icon: "flame.fill"
                                )
                            }
                            
                            // Last sync info
                            if let userId = authManager.userID, !userId.hasPrefix("anonymous_"),
                               let lastSync = SupabaseManager.shared.lastSyncDate {
                                HStack {
                                    Text("Last synced: \(formatLastSync(lastSync))")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Spacer()
                                    
                                    Button("Sync Now") {
                                        Task {
                                            await meditationManager.syncWithCloud(userId: userId)
                                        }
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                                    .disabled(meditationManager.isSyncing)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Mood Tracking Stats
                        if !meditationManager.moodSessions.isEmpty {
                            VStack(spacing: 20) {
                                Text("Mood Tracking")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 15) {
                                    HStack(spacing: 15) {
                                        StatCard(
                                            value: "\(meditationManager.moodSessions.count)",
                                            label: "Check-ins",
                                            icon: "brain.head.profile"
                                        )
                                        
                                        StatCard(
                                            value: "\(calculateMoodImprovementRate())%",
                                            label: "Improvement",
                                            icon: "chart.line.uptrend.xyaxis"
                                        )
                                    }
                                    
                                    // Most common mood
                                    if let mostCommonMood = getMostCommonMood() {
                                        HStack {
                                            Text("Most Common Mood:")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 8) {
                                                Text(mostCommonMood.emoji)
                                                    .font(.system(size: 20))
                                                Text(mostCommonMood.rawValue)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(mostCommonMood.color)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Account & Data Management
                        VStack(spacing: 15) {
                            Text("Account & Data")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                // Sign in/out option
                                if authManager.userID?.starts(with: "anonymous") == true {
                                    NavigationLink(destination: SignInView()) {
                                        SettingsRow(
                                            icon: "person.crop.circle.badge.plus",
                                            title: "Sign In",
                                            subtitle: "Connect your Apple ID to sync data"
                                        )
                                    }
                                } else {
                                    NavigationLink(destination: SyncSettingsView()) {
                                        SettingsRow(
                                            icon: "icloud.fill",
                                            title: "Data Sync",
                                            subtitle: "Manage cloud synchronization"
                                        )
                                    }
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Button(action: {
                                    showingDataExport = true
                                }) {
                                    SettingsRow(
                                        icon: "square.and.arrow.up",
                                        title: "Export Data",
                                        subtitle: "Download your meditation and mood data"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: Text("Notifications Settings")) {
                                    SettingsRow(
                                        icon: "bell.fill",
                                        title: "Notifications",
                                        subtitle: "Daily meditation reminders"
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: Text("Help & Support")) {
                                    SettingsRow(
                                        icon: "questionmark.circle.fill",
                                        title: "Help & Support",
                                        subtitle: "Get help with the app"
                                    )
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                        }
                        
                        // Settings
                        VStack(spacing: 12) {
                            if !subscriptionManager.isSubscribed {
                                // Subscription
                                Button(action: { showingPaywall = true }) {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.yellow)
                                        Text("Get medi Premium")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                }
                            }
                            
                            // AI Plan - View/Create
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Plan")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                NavigationLink(destination: PlanDetailView()) {
                                    HStack {
                                        Image(systemName: "list.bullet.rectangle.portrait")
                                        Text("View Saved Plan")
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(.secondary)
                                    }
                                }
                                if subscriptionManager.isSubscribed {
                                    NavigationLink(destination: PlanCreationView()) {
                                        HStack {
                                            Image(systemName: "wand.and.stars")
                                            Text("Create New Plan")
                                            Spacer()
                                            Image(systemName: "chevron.right").foregroundColor(.secondary)
                                        }
                                    }
                                } else {
                                    Button(action: { showingPaywall = true }) {
                                        HStack {
                                            Image(systemName: "wand.and.stars")
                                                .foregroundColor(.yellow)
                                            Text("Create New Plan (Premium)")
                                            Spacer()
                                            Image(systemName: "chevron.right").foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                            
                            // Developer tools (DEBUG only)
                            #if DEBUG
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Developer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Toggle(isOn: Binding(
                                    get: { subscriptionManager.isDevForced },
                                    set: { subscriptionManager.setDevForcePremium($0) }
                                )) {
                                    Text("Force Premium")
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                            #endif
                        }
                        .padding(.horizontal, 20)
                        
                        // Sign Out / Delete Account
                        VStack(spacing: 15) {
                            if authManager.userID?.starts(with: "anonymous") == false {
                                Button(action: {
                                    authManager.signOut()
                                }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.system(size: 16))
                                        Text("Sign Out")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(red: 0.9, green: 0.5, blue: 0.5))
                                    .cornerRadius(25)
                                }
                            }
                            
                            Button(action: {
                                showingDeleteAccount = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                    Text("Delete Account & Data")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(25)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .alert("Delete Account", isPresented: $showingDeleteAccount) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccountAndData()
            }
        } message: {
            Text("This will permanently delete all your meditation and mood data. This action cannot be undone.")
        }
    }
    
    private func calculateStreak() -> Int {
        guard !meditationManager.completedSessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedSessions = meditationManager.completedSessions.sorted { $0.date > $1.date }
        var streak = 1
        var lastDate = sortedSessions.first!.date
        
        for i in 1..<sortedSessions.count {
            let date = sortedSessions[i].date
            if calendar.isDate(date, inSameDayAs: lastDate) {
                continue
            } else if let daysBetween = calendar.dateComponents([.day], from: date, to: lastDate).day,
                      daysBetween == 1 {
                streak += 1
                lastDate = date
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateMoodImprovementRate() -> Int {
        let ratedSessions = meditationManager.moodSessions.filter { $0.postMoodRating != nil }
        guard !ratedSessions.isEmpty else { return 0 }
        
        let improvedSessions = ratedSessions.filter { ($0.postMoodRating ?? 0) >= 4 }
        return Int(Double(improvedSessions.count) / Double(ratedSessions.count) * 100)
    }
    
    private func getMostCommonMood() -> MoodState? {
        let moodCounts = Dictionary(grouping: meditationManager.moodSessions, by: { $0.mood })
            .mapValues { $0.count }
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func shouldShowNamePrompt() -> Bool {
        // Show prompt if user is signed in but has no custom name and no Apple name
        let hasCustomName = UserDefaults.standard.string(forKey: "user_display_name")?.isEmpty == false
        let hasAppleName = authManager.userName?.isEmpty == false
        let isAnonymous = authManager.userID?.starts(with: "anonymous") == true
        
        return authManager.isSignedIn && !isAnonymous && !hasCustomName && !hasAppleName
    }
    
    private func formatLastSync(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func getDisplayName() -> String {
        // Priority order for display name:
        // 1. Custom display name set by user
        // 2. Apple Sign-In name
        // 3. Fallback for signed-in users without name
        // 4. Fallback for anonymous users
        
        print("🔍 DEBUG: getDisplayName() called")
        print("🔍 DEBUG: authManager.userID = \(authManager.userID ?? "nil")")
        print("🔍 DEBUG: authManager.userName = \(authManager.userName ?? "nil")")
        print("🔍 DEBUG: authManager.isSignedIn = \(authManager.isSignedIn)")
        
        // Check for custom display name first
        if let customName = UserDefaults.standard.string(forKey: "user_display_name"), !customName.isEmpty {
            print("🔍 DEBUG: Using custom display name: \(customName)")
            return customName
        }
        
        // Check for Apple Sign-In name
        if let appleName = authManager.userName, !appleName.isEmpty {
            print("🔍 DEBUG: Using Apple Sign-In name: \(appleName)")
            return appleName
        }
        
        // Check if user is anonymous
        if authManager.userID?.starts(with: "anonymous") == true {
            print("🔍 DEBUG: User is anonymous")
            return "Anonymous Meditator"
        }
        
        // User is signed in with Apple ID but no name available
        if authManager.isSignedIn && authManager.userID != nil {
            print("🔍 DEBUG: User signed in but no name available")
            return "Mindful Friend"
        }
        
        // Final fallback
        print("🔍 DEBUG: Using fallback name: Meditator")
        return "Meditator"
    }
    
    private func deleteAccountAndData() {
        // Clear all local data
        meditationManager.moodSessions.removeAll()
        meditationManager.completedSessions.removeAll()
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "mood_sessions")
        UserDefaults.standard.removeObject(forKey: "meditation_sessions")
        UserDefaults.standard.removeObject(forKey: "apple_user_id")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "user_name")
        UserDefaults.standard.removeObject(forKey: "user_display_name")
        UserDefaults.standard.removeObject(forKey: "user_bio")
        UserDefaults.standard.removeObject(forKey: "user_meditation_goal")
        
        // Sign out
        authManager.signOut()
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(value)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var meditationGoal: String = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Picture Section
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                            }
                            
                            Button("Change Photo") {
                                // Photo picker would go here
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                
                                TextField("Enter your name", text: $displayName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onAppear {
                                        // Load custom display name first, then fall back to Apple name
                                        if let customName = UserDefaults.standard.string(forKey: "user_display_name"), !customName.isEmpty {
                                            displayName = customName
                                        } else {
                                            displayName = authManager.userName ?? ""
                                        }
                                    }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                
                                TextField("Tell us about yourself", text: $bio, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...6)
                                    .onAppear {
                                        bio = UserDefaults.standard.string(forKey: "user_bio") ?? ""
                                    }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Meditation Goal")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                
                                TextField("e.g., Reduce stress, Improve focus", text: $meditationGoal)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onAppear {
                                        meditationGoal = UserDefaults.standard.string(forKey: "user_meditation_goal") ?? ""
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(isSaving ? "Saving..." : "Save") {
                    isSaving = true
                    saveProfile()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(isSaving)
            )
        }
    }
    
    private func saveProfile() {
        // Save to UserDefaults
        UserDefaults.standard.set(displayName, forKey: "user_display_name")
        UserDefaults.standard.set(bio, forKey: "user_bio")
        UserDefaults.standard.set(meditationGoal, forKey: "user_meditation_goal")
        
        // Update auth manager
        authManager.userName = displayName
        
        // Sync with Supabase if user is signed in
        if let userId = authManager.userID, !userId.hasPrefix("anonymous_") {
            Task {
                await SupabaseManager.shared.updateProfile(
                    userId: userId,
                    email: authManager.userEmail,
                    name: displayName.isEmpty ? nil : displayName
                )
                // Reset saving state after sync completes
                await MainActor.run {
                    isSaving = false
                }
            }
        } else {
            // Reset saving state immediately if no sync needed
            isSaving = false
        }
    }
}

// MARK: - Data Export View
struct DataExportView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @Environment(\.presentationMode) var presentationMode
    @State private var exportFormat: ExportFormat = .json
    @State private var isExporting = false
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        case pdf = "PDF"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                        
                        Text("Export Your Data")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                        
                        Text("Download your meditation and mood data for backup or analysis")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 40)
                    
                    // Data Summary
                    VStack(spacing: 20) {
                        Text("Data Summary")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                        
                        HStack(spacing: 30) {
                            DataSummaryCard(
                                value: "\(meditationManager.completedSessions.count)",
                                label: "Meditation Sessions"
                            )
                            
                            DataSummaryCard(
                                value: "\(meditationManager.moodSessions.count)",
                                label: "Mood Check-ins"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Export Format
                    VStack(spacing: 15) {
                        Text("Export Format")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                        
                        Picker("Format", selection: $exportFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                    }
                    
                    // Export Button
                    Button(action: {
                        exportData()
                    }) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16))
                            }
                            
                            Text(isExporting ? "Exporting..." : "Export Data")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.6, green: 0.7, blue: 0.9))
                        .cornerRadius(25)
                        .disabled(isExporting)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func exportData() {
        isExporting = true
        
        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isExporting = false
            // Here you would implement actual data export
            print("Exporting data in \(exportFormat.rawValue) format...")
        }
    }
}

struct DataSummaryCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
            
            Text(label)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
} 