import SwiftUI

struct MoodInsightsView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var insights: MoodInsights?
    @State private var selectedTimeframe: TimeFrame = .all
    @State private var showingPaywall: Bool = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case all = "All Time"
    }
    
    init() {}
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.95, blue: 1.0),
                        Color(red: 0.85, green: 0.85, blue: 0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Text("🧠")
                                .font(.system(size: 50))
                            
                            Text("Mood Insights")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
                        }
                        .padding(.top, 20)
                        
                        if !subscriptionManager.isSubscribed {
                            Button(action: { showingPaywall = true }) {
                                HStack(alignment: .center, spacing: 12) {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Unlock AI tips and deeper insights")
                                            .font(.headline)
                                        Text("Get medi Premium for personalized analysis")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        if let insights = insights {
                            // Timeframe Picker
                            Picker("Timeframe", selection: $selectedTimeframe) {
                                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                                    Text(timeframe.rawValue).tag(timeframe)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal, 20)
                            
                            // Debug button (temporary)
                            Button("🔍 Debug: Show All Data") {
                                printAllMoodData()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            
                            // Summary Cards
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                InsightCard(
                                    title: "Most Common Mood",
                                    value: insights.mostCommonMood.emoji + " " + insights.mostCommonMood.rawValue,
                                    color: insights.mostCommonMood.color
                                )
                                
                                InsightCard(
                                    title: "Average Rating",
                                    value: String(format: "%.1f⭐", insights.averageRating),
                                    color: Color(red: 0.9, green: 0.7, blue: 0.4)
                                )
                                
                                InsightCard(
                                    title: "Total Sessions",
                                    value: "\(insights.totalSessions)",
                                    color: Color(red: 0.4, green: 0.7, blue: 0.9)
                                )
                                
                                InsightCard(
                                    title: "Weekly Trend",
                                    value: insights.weeklyTrend + " 📈",
                                    color: Color(red: 0.7, green: 0.9, blue: 0.5)
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            if subscriptionManager.isSubscribed {
                                // AI Personalized Tip (Premium)
                                VStack(spacing: 15) {
                                    HStack {
                                        Text("🤖 AI Personal Tip")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    
                                    Text(insights.personalizedTip)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .padding(15)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.8))
                                        )
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Mood Frequency Chart
                            if !insights.moodFrequency.isEmpty {
                                VStack(spacing: 15) {
                                    HStack {
                                        Text("📊 Mood Distribution")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    
                                    VStack(spacing: 10) {
                                        ForEach(Array(insights.moodFrequency.sorted(by: { $0.value > $1.value })), id: \.key) { mood, count in
                                            MoodFrequencyRow(mood: mood, count: count, total: insights.totalSessions)
                                        }
                                    }
                                    .padding(15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.8))
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                            
                        } else {
                            // Empty State
                            VStack(spacing: 20) {
                                Text("🌱")
                                    .font(.system(size: 60))
                                
                                Text("Start Your Mood Journey")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
                                
                                Text("Use the mood check-in feature to track your emotional wellness and get personalized insights.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, 50)
                        }
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            generateInsights()
        }
        .onChange(of: selectedTimeframe) { _ in
            generateInsights()
        }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }
    
    private func generateInsights() {
        let filteredSessions = getFilteredSessions()
        insights = MoodInsights.generateInsights(from: filteredSessions)
    }
    
    private func getFilteredSessions() -> [MoodSession] {
        let calendar = Calendar.current
        let now = Date()
        
        // Debug logging
        print("🔍 DEBUG: Timeframe selected: \(selectedTimeframe.rawValue)")
        print("🔍 DEBUG: Total mood sessions: \(meditationManager.moodSessions.count)")
        
        let filteredSessions: [MoodSession]
        
        switch selectedTimeframe {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            filteredSessions = meditationManager.moodSessions.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            filteredSessions = meditationManager.moodSessions.filter { $0.timestamp >= monthAgo }
        case .all:
            filteredSessions = meditationManager.moodSessions
        }
        
        print("🔍 DEBUG: Filtered sessions: \(filteredSessions.count)")
        
        if !filteredSessions.isEmpty {
            print("🔍 DEBUG: Session timestamps:")
            for (index, session) in filteredSessions.enumerated() {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                print("  \(index + 1). \(session.mood.rawValue) - \(formatter.string(from: session.timestamp))")
            }
        } else {
            print("🔍 DEBUG: No sessions found for timeframe")
        }
        
        return filteredSessions
    }
    
    private func printAllMoodData() {
        print("🔍 DEBUG: All Mood Sessions:")
        for (index, session) in meditationManager.moodSessions.enumerated() {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            print("  \(index + 1). \(session.mood.rawValue) - \(formatter.string(from: session.timestamp))")
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
}

struct MoodFrequencyRow: View {
    let mood: MoodState
    let count: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack {
            Text(mood.emoji)
                .font(.title3)
            
            Text(mood.rawValue)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(mood.color)
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 60, height: 6)
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .trailing)
        }
    }
}

#Preview {
    MoodInsightsView()
        .environmentObject(MeditationManager())
} 