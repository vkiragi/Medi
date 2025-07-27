import SwiftUI

/// AI-powered insights view that displays intelligent analysis of user's mood and meditation patterns
public struct AIInsightsView: View {
    @ObservedObject var meditationManager: MeditationManager
    @State private var analysis: MoodPatternAnalysis?
    @State private var isLoading = false
    
    public init(meditationManager: MeditationManager) {
        self.meditationManager = meditationManager
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                                .foregroundColor(.purple)
                            Text("AI Insights")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        Text("Personalized analysis based on your meditation journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    if isLoading {
                        // Loading state
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("🧠 Analyzing your patterns...")
                                .font(.headline)
                                .foregroundColor(.purple)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else if let analysis = analysis {
                        // AI Analysis Results
                        LazyVStack(spacing: 16) {
                            // Personalized Insights
                            if !analysis.personalizedInsights.isEmpty {
                                InsightSection(
                                    title: "🎯 Personal Insights",
                                    insights: analysis.personalizedInsights
                                )
                            }
                            
                            // Mood Cycle Analysis
                            MoodCycleCard(cycleAnalysis: analysis.personalMoodCycle)
                            
                            // Stress Triggers
                            if !analysis.stressTriggers.isEmpty {
                                StressTriggersCard(triggers: analysis.stressTriggers)
                            }
                            
                            // Energy Patterns
                            EnergyPatternsCard(energyAnalysis: analysis.energyPatterns)
                            
                            // Meditation Effectiveness
                            EffectivenessCard(effectiveness: analysis.meditationEffectiveness)
                            
                            // Optimal Times
                            if !analysis.optimalMeditationTimes.isEmpty {
                                OptimalTimesCard(optimalTimes: analysis.optimalMeditationTimes)
                            }
                            
                            // Risk Factors (if any)
                            if !analysis.riskFactors.isEmpty {
                                RiskFactorsCard(riskFactors: analysis.riskFactors)
                            }
                            
                            // Improvement Rate
                            ImprovementRateCard(improvementRate: analysis.moodImprovementRate)
                        }
                        .padding(.horizontal)
                    } else {
                        // No data state
                        VStack(spacing: 20) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("Building Your AI Profile")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Continue using mood check-ins and meditation sessions to unlock personalized AI insights about your patterns and progress.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            Button(action: {
                                analyzePatterns()
                            }) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                    Text("Analyze Available Data")
                                }
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                    }
                }
            }
            .refreshable {
                analyzePatterns()
            }
        }
        .onAppear {
            analyzePatterns()
        }
    }
    
    private func analyzePatterns() {
        guard !meditationManager.moodSessions.isEmpty else {
            analysis = nil
            return
        }
        
        isLoading = true
        
        // Simulate AI processing time for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            analysis = AIAnalyticsManager.shared.analyzeMoodPatterns(
                moodSessions: meditationManager.moodSessions
            )
            isLoading = false
        }
    }
}

// MARK: - Supporting Views

struct InsightSection: View {
    let title: String
    let insights: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(insights, id: \.self) { insight in
                HStack(alignment: .top) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                        .padding(.top, 2)
                    
                    Text(insight)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 2)
            }
        }
    }
}

struct MoodCycleCard: View {
    let cycleAnalysis: MoodCycleAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.blue)
                Text("Mood Cycle Analysis")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Average State:")
                        .fontWeight(.medium)
                    Text(cycleAnalysis.averageMood)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Text(cycleAnalysis.pattern)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct StressTriggersCard: View {
    let triggers: [StressTrigger]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Stress Triggers")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(triggers.indices, id: \.self) { index in
                let trigger = triggers[index]
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(trigger.description)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(trigger.confidence * 100))%")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Text("Frequency: \(trigger.frequency) times")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if index < triggers.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct EnergyPatternsCard: View {
    let energyAnalysis: EnergyPatternAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                Text("Energy Patterns")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Peak Energy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(energyAnalysis.peakEnergyHour):00")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Low Energy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(energyAnalysis.lowEnergyHour):00")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(energyAnalysis.pattern)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct EffectivenessCard: View {
    let effectiveness: MeditationEffectivenessAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.green)
                Text("Meditation Effectiveness")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Overall effectiveness
                HStack {
                    Text("Overall Success Rate")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(effectiveness.overallEffectiveness * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Divider()
                
                // Best meditation type
                if effectiveness.bestMeditationType != "Unknown" {
                    HStack {
                        Text("Most Effective Type")
                            .fontWeight(.medium)
                        Spacer()
                        Text(effectiveness.bestMeditationType)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Average improvement
                if effectiveness.averageImprovement > 0 {
                    HStack {
                        Text("Average Mood Improvement")
                            .fontWeight(.medium)
                        Spacer()
                        Text("+\(String(format: "%.1f", effectiveness.averageImprovement)) points")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct OptimalTimesCard: View {
    let optimalTimes: [Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("Optimal Meditation Times")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                ForEach(optimalTimes.prefix(3), id: \.self) { hour in
                    VStack {
                        Text("\(hour):00")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Success")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct RiskFactorsCard: View {
    let riskFactors: [RiskFactor]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(.red)
                Text("Wellness Alerts")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(riskFactors.indices, id: \.self) { index in
                let factor = riskFactors[index]
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: severityIcon(factor.severity))
                            .foregroundColor(severityColor(factor.severity))
                        Text(factor.description)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    Text("💡 \(factor.recommendation)")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                }
                
                if index < riskFactors.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
    
    private func severityIcon(_ severity: RiskFactor.Severity) -> String {
        switch severity {
        case .low: return "info.circle.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        }
    }
    
    private func severityColor(_ severity: RiskFactor.Severity) -> Color {
        switch severity {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct ImprovementRateCard: View {
    let improvementRate: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Mood Improvement Rate")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(improvementRate * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Sessions improved mood")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(improvementMessage(improvementRate))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(improvementColor(improvementRate))
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.green.opacity(0.6), .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * improvementRate, height: 8)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
    
    private func improvementMessage(_ rate: Double) -> String {
        switch rate {
        case 0.8...: return "Excellent!"
        case 0.6..<0.8: return "Very Good"
        case 0.4..<0.6: return "Good"
        case 0.2..<0.4: return "Room to grow"
        default: return "Keep practicing"
        }
    }
    
    private func improvementColor(_ rate: Double) -> Color {
        switch rate {
        case 0.6...: return .green
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
} 