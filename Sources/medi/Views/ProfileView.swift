import SwiftUI

public struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var showingEditProfile = false
    @State private var showingDataExport = false
    @State private var showingDeleteAccount = false
    
    public init() {}
    
    public var body: some View {
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
                .ignoresSafeArea(.all, edges: .all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Compact App Header
                        AppHeader(title: "Profile")
                        
                        // Profile Header
                        VStack(spacing: 15) {
                            // Avatar with edit button
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                
                                // Edit button
                                Button(action: {
                                    showingEditProfile = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .background(Color.white.opacity(0.12))
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
                                    .foregroundColor(.white.opacity(0.8))
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
                                    Image(systemName: authManager.userID?.starts(with: "anonymous") == true ? "person.crop.circle.badge.exclamationmark" : "checkmark.seal.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(authManager.userID?.starts(with: "anonymous") == true ? .white.opacity(0.8) : .white)
                                    
                                    Text(authManager.userID?.starts(with: "anonymous") == true ? "Anonymous Account" : "Apple ID Connected")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(authManager.userID?.starts(with: "anonymous") == true ? .white.opacity(0.8) : .white)
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Meditation Stats
                        VStack(spacing: 20) {
                            Text("Meditation Journey")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
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
                        }
                        .padding(.horizontal, 20)
                        
                        // Account & Data Management
                        VStack(spacing: 15) {
                            Text("Account & Data")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
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
                                    .background(Color.white.opacity(0.12))
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
                                    .background(Color.white.opacity(0.12))
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: Text("Notifications Settings")) {
                                    SettingsRow(
                                        icon: "bell.fill",
                                        title: "Notifications",
                                        subtitle: "Daily meditation reminders"
                                    )
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.12))
                                    .padding(.leading, 60)
                                
                                NavigationLink(destination: Text("Help & Support")) {
                                    SettingsRow(
                                        icon: "questionmark.circle.fill",
                                        title: "Help & Support",
                                        subtitle: "Get help with the app"
                                    )
                                }
                            }
                            .background(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .cornerRadius(20)
                            .padding(.horizontal, 20)
                        }
                        
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
                                    .background(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
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
                                .background(Color.red.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(25)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 40) // ensure last content isn't jammed into the Tab Bar
                }
            }
            .navigationBarHidden(true) // Hide default navigation bar
            .onAppear {
                // No-op for now, AppTitle handles its own navigation
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
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
    
    private func shouldShowNamePrompt() -> Bool {
        // Show prompt if user is signed in but has no custom name and no Apple name
        let hasCustomName = UserDefaults.standard.string(forKey: "user_display_name")?.isEmpty == false
        let hasAppleName = authManager.userName?.isEmpty == false
        let isAnonymous = authManager.userID?.starts(with: "anonymous") == true
        
        return authManager.isSignedIn && !isAnonymous && !hasCustomName && !hasAppleName
    }
    
    private func getDisplayName() -> String {
        // Priority order for display name:
        // 1. Custom display name set by user
        // 2. Apple Sign-In name
        // 3. Fallback for anonymous users
        
        // Check for custom display name first
        if let customName = UserDefaults.standard.string(forKey: "user_display_name"), !customName.isEmpty {
            return customName
        }
        
        // Check for Apple Sign-In name
        if let appleName = authManager.userName, !appleName.isEmpty {
            return appleName
        }
        
        // Check if user is anonymous
        if authManager.userID?.starts(with: "anonymous") == true {
            return "Anonymous Meditator"
        }
        
        // User is signed in with Apple ID but no name available
        if authManager.isSignedIn && authManager.userID != nil {
            return "Mindful Friend"
        }
        
        // Final fallback
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
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(20)
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
                .foregroundColor(.white)
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
                .ignoresSafeArea(.all, edges: .all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Compact App Header
                        AppHeader(title: "Edit Profile")
                        
                        // Profile Picture Section
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            Button("Change Photo") {
                                // Photo picker would go here
                            }
                            .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
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
                                    .foregroundColor(.white)
                                
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
                                    .foregroundColor(.white)
                                
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
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true) // Hide default navigation bar
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                trailing: Button(isSaving ? "Saving..." : "Save") {
                    isSaving = true
                    saveProfile()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
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
                .ignoresSafeArea(.all, edges: .all)
                
                VStack(spacing: 30) {
                    // Compact App Header
                    AppHeader(title: "Export Data")
                    
                    // Data Summary
                    VStack(spacing: 20) {
                        Text("Data Summary")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
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
                            .foregroundColor(.white)
                        
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
                        .background(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .cornerRadius(25)
                        .disabled(isExporting)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide default navigation bar
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.white))
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
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.15))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(20)
    }
} 