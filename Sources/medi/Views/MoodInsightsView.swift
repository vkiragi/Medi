import SwiftUI
import Charts

public struct MoodInsightsView: View {
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var insights: MoodInsights?
    @State private var selectedTimeframe: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case all = "All Time"
    }
    
    public init() {}
    
    public var body: some View {
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
                
                if let insights = insights {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Header
                            VStack(spacing: 10) {
                                Text("🧠 Mood Insights")
                                    .font(.system(size: 28, weight: .thin, design: .rounded))
                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                
                                Text("AI-powered analysis of your emotional patterns")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 20)
                            
                            // Timeframe selector
                            Picker("Timeframe", selection: $selectedTimeframe) {
                                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                                    Text(timeframe.rawValue).tag(timeframe)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal, 20)
                            
                            // Mood trend card
                            InsightCard(
                                title: "Mood Trend",
                                icon: "chart.line.uptrend.xyaxis",
                                content: AnyView(
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(insights.moodTrend)
                                            .font(.system(size: 16, weight: .light))
                                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                                        
                                        if insights.improvementRate > 0 {
                                            HStack {
                                                Text("Success Rate:")
                                                    .font(.system(size: 14, weight: .light))
                                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                                                
                                                Text("\(Int(insights.improvementRate))%")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(
                                                        insights.improvementRate >= 70 ? 
                                                        Color(red: 0.4, green: 0.8, blue: 0.4) :
                                                        Color(red: 0.9, green: 0.7, blue: 0.4)
                                                    )
                                                
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                            )
                            
                            // Most common mood
                            if let commonMood = insights.mostCommonMood {
                                InsightCard(
                                    title: "Most Common Mood",
                                    icon: "heart.fill",
                                    content: AnyView(
                                        HStack(spacing: 15) {
                                            Text(commonMood.emoji)
                                                .font(.system(size: 40))
                                            
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(commonMood.rawValue)
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                                
                                                Text(commonMood.description)
                                                    .font(.system(size: 14, weight: .light))
                                                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                                            }
                                            
                                            Spacer()
                                        }
                                    )
                                )
                            }
                            
                            // Mood distribution
                            if !insights.moodDistribution.isEmpty {
                                InsightCard(
                                    title: "Mood Distribution",
                                    icon: "chart.pie.fill",
                                    content: AnyView(
                                        VStack(spacing: 15) {
                                            ForEach(Array(insights.moodDistribution.sorted(by: { $0.value > $1.value })), id: \.key) { mood, count in
                                                MoodDistributionRow(mood: mood, count: count, total: insights.moodDistribution.values.reduce(0, +))
                                            }
                                        }
                                    )
                                )
                            }
                            
                            // AI Recommendations
                            if !insights.recommendedActions.isEmpty {
                                InsightCard(
                                    title: "🤖 AI Recommendations",
                                    icon: "lightbulb.fill",
                                    content: AnyView(
                                        VStack(alignment: .leading, spacing: 12) {
                                            ForEach(insights.recommendedActions, id: \.self) { action in
                                                HStack(alignment: .top, spacing: 10) {
                                                    Circle()
                                                        .fill(Color(red: 0.6, green: 0.7, blue: 0.9))
                                                        .frame(width: 6, height: 6)
                                                        .padding(.top, 6)
                                                    
                                                    Text(action)
                                                        .font(.system(size: 14, weight: .light))
                                                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                    )
                                )
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    // Empty state
                    VStack(spacing: 20) {
                        Text("📊")
                            .font(.system(size: 60))
                        
                        Text("Not enough data yet")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        Text("Complete a few mood check-ins to see your insights")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 60)
                    }
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadInsights()
        }
        .onChange(of: selectedTimeframe) { _ in
            loadInsights()
        }
    }
    
    private func loadInsights() {
        let filteredSessions = filterSessionsBy(timeframe: selectedTimeframe)
        if !filteredSessions.isEmpty {
            insights = MoodInsights(moodSessions: filteredSessions)
        } else {
            insights = nil
        }
    }
    
    private func filterSessionsBy(timeframe: TimeFrame) -> [MoodSession] {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeframe {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return meditationManager.moodSessions.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return meditationManager.moodSessions.filter { $0.timestamp >= monthAgo }
        case .all:
            return meditationManager.moodSessions
        }
    }
}

struct InsightCard: View {
    let title: String
    let icon: String
    let content: AnyView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct MoodDistributionRow: View {
    let mood: MoodState
    let count: Int
    let total: Int
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) * 100 : 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(mood.emoji)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(mood.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                    
                    Spacer()
                    
                    Text("\(count) times")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.9, green: 0.9, blue: 0.95))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(mood.color)
                            .frame(width: geometry.size.width * (percentage / 100), height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            Text("\(Int(percentage))%")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(mood.color)
                .frame(width: 35, alignment: .trailing)
        }
    }
} 