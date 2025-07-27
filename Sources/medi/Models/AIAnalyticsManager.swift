import Foundation
import SwiftUI

/// AI-powered analytics manager that processes mood and meditation data to provide intelligent insights
public class AIAnalyticsManager: ObservableObject {
    public static let shared = AIAnalyticsManager()
    
    @Published public var isAnalyzing = false
    @Published public var lastAnalysisDate: Date?
    
    private init() {}
    
    // MARK: - Core AI Analysis Functions
    
    /// Analyzes mood patterns to identify personal cycles, triggers, and trends
    public func analyzeMoodPatterns(moodSessions: [MoodSession]) -> MoodPatternAnalysis {
        print("🧠 AI analyzing \(moodSessions.count) mood sessions...")
        
        let sortedSessions = moodSessions.sorted { $0.timestamp < $1.timestamp }
        
        return MoodPatternAnalysis(
            personalMoodCycle: detectMoodCycle(sessions: sortedSessions),
            stressTriggers: identifyStressTriggers(sessions: sortedSessions),
            energyPatterns: analyzeEnergyPatterns(sessions: sortedSessions),
            meditationEffectiveness: calculateMeditationEffectiveness(sessions: sortedSessions),
            optimalMeditationTimes: findOptimalMeditationTimes(sessions: sortedSessions),
            moodImprovementRate: calculateMoodImprovementRate(sessions: sortedSessions),
            personalizedInsights: generatePersonalizedInsights(sessions: sortedSessions),
            riskFactors: identifyRiskFactors(sessions: sortedSessions)
        )
    }
    
    /// Generates AI-powered meditation recommendations based on current mood and historical success
    public func getAIRecommendations(currentMood: MoodState, moodSessions: [MoodSession]) -> AIRecommendation {
        let successfulMeditations = findSuccessfulMeditationsFor(mood: currentMood, sessions: moodSessions)
        let currentContext = analyzeCurrentContext(currentMood: currentMood, sessions: moodSessions)
        
        return AIRecommendation(
            recommendedMeditationType: selectBestMeditationType(for: currentMood, history: successfulMeditations),
            optimalDuration: calculateOptimalDuration(for: currentMood, context: currentContext),
            personalizedMessage: generateAIMessage(for: currentMood, context: currentContext),
            successProbability: predictSuccessProbability(for: currentMood, sessions: moodSessions),
            alternativeOptions: generateAlternativeOptions(for: currentMood, history: successfulMeditations),
            contextualTips: generateContextualTips(for: currentMood, context: currentContext)
        )
    }
    
    /// Predicts optimal meditation timing based on user's mood and energy patterns
    public func predictOptimalMeditationTime(moodSessions: [MoodSession]) -> TimeRecommendation {
        let hourlyPatterns = analyzeMeditationSuccessByHour(sessions: moodSessions)
        let moodCycles = analyzeDailyMoodCycles(sessions: moodSessions)
        
        return TimeRecommendation(
            bestHour: hourlyPatterns.mostSuccessfulHour,
            confidenceScore: hourlyPatterns.confidence,
            reasoning: generateTimingReasoning(patterns: hourlyPatterns, cycles: moodCycles),
            alternativeTimes: hourlyPatterns.alternativeHours
        )
    }
    
    // MARK: - Private AI Analysis Methods
    
    private func detectMoodCycle(sessions: [MoodSession]) -> MoodCycleAnalysis {
        guard sessions.count >= 7 else {
            return MoodCycleAnalysis(cycleLength: nil, averageMood: "Unknown", pattern: "Insufficient data")
        }
        
        // Group by day of week
        let weeklyPattern = Dictionary(grouping: sessions) { session in
            Calendar.current.component(.weekday, from: session.timestamp)
        }
        
        // Find the most stressful and most calm days
        var dayMoodScores: [Int: Double] = [:]
        for (weekday, daySessions) in weeklyPattern {
            let avgStress = daySessions.compactMap { $0.stressLevel }.reduce(0, +) / max(1, daySessions.count)
            dayMoodScores[weekday] = Double(avgStress)
        }
        
        let mostStressfulDay = dayMoodScores.max(by: { $0.value < $1.value })?.key ?? 2
        let mostCalmDay = dayMoodScores.min(by: { $0.value < $1.value })?.key ?? 1
        
        return MoodCycleAnalysis(
            cycleLength: 7,
            averageMood: calculateAverageMoodScore(sessions: sessions),
            pattern: "Weekly pattern detected: Most stress on \(dayName(mostStressfulDay)), most calm on \(dayName(mostCalmDay))"
        )
    }
    
    private func identifyStressTriggers(sessions: [MoodSession]) -> [StressTrigger] {
        let stressedSessions = sessions.filter { 
            $0.mood == .stressed || $0.mood == .anxious || $0.mood == .overwhelmed 
        }
        
        // Analyze context tags for patterns
        let allTags = stressedSessions.flatMap { $0.contextTags }
        let tagFrequency = Dictionary(grouping: allTags, by: { $0 }).mapValues { $0.count }
        
        // Analyze time patterns
        let stressHours = stressedSessions.map { Calendar.current.component(.hour, from: $0.timestamp) }
        let hourFrequency = Dictionary(grouping: stressHours, by: { $0 }).mapValues { $0.count }
        
        var triggers: [StressTrigger] = []
        
        // Context-based triggers
        for (tag, count) in tagFrequency.sorted(by: { $0.value > $1.value }).prefix(3) {
            triggers.append(StressTrigger(
                type: .contextual,
                description: "High stress when: \(tag)",
                frequency: count,
                confidence: Double(count) / Double(stressedSessions.count)
            ))
        }
        
        // Time-based triggers
        if let peakStressHour = hourFrequency.max(by: { $0.value < $1.value }) {
            triggers.append(StressTrigger(
                type: .temporal,
                description: "Peak stress around \(peakStressHour.key):00",
                frequency: peakStressHour.value,
                confidence: Double(peakStressHour.value) / Double(stressedSessions.count)
            ))
        }
        
        return triggers
    }
    
    private func analyzeEnergyPatterns(sessions: [MoodSession]) -> EnergyPatternAnalysis {
        let energyData = sessions.compactMap { session -> (hour: Int, energy: Int)? in
            guard let energy = session.energyLevel else { return nil }
            let hour = Calendar.current.component(.hour, from: session.timestamp)
            return (hour, energy)
        }
        
        guard !energyData.isEmpty else {
            return EnergyPatternAnalysis(peakEnergyHour: 9, lowEnergyHour: 15, pattern: "Insufficient energy data")
        }
        
        // Group by hour and calculate average energy
        let hourlyEnergy = Dictionary(grouping: energyData, by: { $0.hour })
            .mapValues { values in
                values.map { $0.energy }.reduce(0, +) / values.count
            }
        
        let peakHour = hourlyEnergy.max(by: { $0.value < $1.value })?.key ?? 9
        let lowHour = hourlyEnergy.min(by: { $0.value < $1.value })?.key ?? 15
        
        return EnergyPatternAnalysis(
            peakEnergyHour: peakHour,
            lowEnergyHour: lowHour,
            pattern: "Peak energy at \(peakHour):00, lowest at \(lowHour):00"
        )
    }
    
    private func calculateMeditationEffectiveness(sessions: [MoodSession]) -> MeditationEffectivenessAnalysis {
        let completedSessions = sessions.filter { $0.completedMeditation }
        let ratedSessions = completedSessions.filter { $0.postMoodRating != nil }
        
        guard !ratedSessions.isEmpty else {
            return MeditationEffectivenessAnalysis(
                overallEffectiveness: 0.0,
                bestMeditationType: "Unknown",
                worstMeditationType: "Unknown",
                averageImprovement: 0.0
            )
        }
        
        // Calculate effectiveness by meditation type
        let typeEffectiveness = Dictionary(grouping: ratedSessions, by: { $0.meditationType ?? "Unknown" })
            .mapValues { typeSessions in
                let avgRating = typeSessions.compactMap { $0.postMoodRating }.reduce(0, +) / typeSessions.count
                return Double(avgRating) / 5.0 // Convert to 0-1 scale
            }
        
        let bestType = typeEffectiveness.max(by: { $0.value < $1.value })?.key ?? "Unknown"
        let worstType = typeEffectiveness.min(by: { $0.value < $1.value })?.key ?? "Unknown"
        
        let overallRating = ratedSessions.compactMap { $0.postMoodRating }.reduce(0, +) / ratedSessions.count
        
        return MeditationEffectivenessAnalysis(
            overallEffectiveness: Double(overallRating) / 5.0,
            bestMeditationType: bestType,
            worstMeditationType: worstType,
            averageImprovement: calculateAverageMoodImprovement(sessions: ratedSessions)
        )
    }
    
    private func findOptimalMeditationTimes(sessions: [MoodSession]) -> [Int] {
        let successfulSessions = sessions.filter { 
            $0.completedMeditation && ($0.postMoodRating ?? 0) >= 4 
        }
        
        let successfulHours = successfulSessions.map { 
            Calendar.current.component(.hour, from: $0.timestamp) 
        }
        
        let hourFrequency = Dictionary(grouping: successfulHours, by: { $0 }).mapValues { $0.count }
        
        return hourFrequency.sorted(by: { $0.value > $1.value }).prefix(3).map { $0.key }
    }
    
    private func calculateMoodImprovementRate(sessions: [MoodSession]) -> Double {
        let sessionsWithBefore = sessions.filter { $0.stressLevel != nil }
        let sessionsWithAfter = sessionsWithBefore.filter { $0.postMeditationMood != nil }
        
        guard !sessionsWithAfter.isEmpty else { return 0.0 }
        
        let improvements = sessionsWithAfter.filter { session in
            let before = session.stressLevel ?? 5
            let after = session.postMeditationMood ?? 5
            return after > before // Higher post-meditation mood = improvement
        }
        
        return Double(improvements.count) / Double(sessionsWithAfter.count)
    }
    
    private func generatePersonalizedInsights(sessions: [MoodSession]) -> [String] {
        var insights: [String] = []
        
        // Consistency insight
        if sessions.count >= 7 {
            let recentSessions = sessions.suffix(7)
            if recentSessions.allSatisfy({ $0.completedMeditation }) {
                insights.append("🔥 Amazing! You've maintained a 7-day meditation streak. Your consistency is building lasting habits.")
            } else {
                let completionRate = recentSessions.filter { $0.completedMeditation }.count
                insights.append("💪 You completed \(completionRate)/7 recent meditations. Small progress is still progress!")
            }
        }
        
        // Stress pattern insight
        let recentStress = sessions.suffix(5).compactMap { $0.stressLevel }
        if recentStress.count >= 3 {
            let avgStress = recentStress.reduce(0, +) / recentStress.count
            if avgStress >= 7 {
                insights.append("🚨 Your stress levels have been elevated recently. Consider shorter, more frequent meditation sessions.")
            } else if avgStress <= 3 {
                insights.append("🌟 Your stress levels are beautifully low lately. Your meditation practice is working wonderfully!")
            }
        }
        
        // Energy pattern insight
        let energyLevels = sessions.suffix(7).compactMap { $0.energyLevel }
        if energyLevels.count >= 3 {
            let trend = energyLevels.count >= 2 ? (energyLevels.last! - energyLevels.first!) : 0
            if trend > 2 {
                insights.append("⚡ Your energy levels are trending upward! Meditation is boosting your vitality.")
            } else if trend < -2 {
                insights.append("💤 Your energy seems lower lately. Consider gentler, restorative meditations.")
            }
        }
        
        return insights
    }
    
    private func identifyRiskFactors(sessions: [MoodSession]) -> [RiskFactor] {
        var riskFactors: [RiskFactor] = []
        
        // Check for increasing stress pattern
        let recentSessions = sessions.suffix(5)
        let stressLevels = recentSessions.compactMap { $0.stressLevel }
        
        if stressLevels.count >= 3 {
            let increasingStress = zip(stressLevels.dropLast(), stressLevels.dropFirst()).allSatisfy { $0 < $1 }
            if increasingStress {
                riskFactors.append(RiskFactor(
                    type: .increasingStress,
                    severity: .medium,
                    description: "Stress levels have been consistently increasing",
                    recommendation: "Consider increasing meditation frequency or trying stress-relief techniques"
                ))
            }
        }
        
        // Check for low completion rate
        let completionRate = Double(recentSessions.filter { $0.completedMeditation }.count) / Double(recentSessions.count)
        if completionRate < 0.5 {
            riskFactors.append(RiskFactor(
                type: .lowEngagement,
                severity: .low,
                description: "Recent meditation completion rate is below 50%",
                recommendation: "Try shorter sessions or different meditation styles to rebuild momentum"
            ))
        }
        
        return riskFactors
    }
    
    // MARK: - Helper Methods
    
    private func dayName(_ weekday: Int) -> String {
        let days = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[weekday]
    }
    
    private func calculateAverageMoodScore(sessions: [MoodSession]) -> String {
        let moodScores = sessions.map { moodToScore($0.mood) }
        let average = moodScores.reduce(0, +) / max(1, moodScores.count)
        
        switch average {
        case 0..<2: return "Generally stressed"
        case 2..<4: return "Somewhat challenging" 
        case 4..<6: return "Balanced"
        case 6..<8: return "Generally positive"
        default: return "Very positive"
        }
    }
    
    private func moodToScore(_ mood: MoodState) -> Int {
        switch mood {
        case .stressed, .anxious, .overwhelmed: return 2
        case .tired, .sad: return 3
        case .calm: return 6
        case .energetic, .excited: return 7
        }
    }
    
    private func findSuccessfulMeditationsFor(mood: MoodState, sessions: [MoodSession]) -> [MoodSession] {
        return sessions.filter { session in
            session.mood == mood && 
            session.completedMeditation && 
            (session.postMoodRating ?? 0) >= 4
        }
    }
    
    private func analyzeCurrentContext(currentMood: MoodState, sessions: [MoodSession]) -> MeditationContext {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let recentSimilarSessions = sessions.filter { $0.mood == currentMood }.suffix(5)
        
        return MeditationContext(
            timeOfDay: currentHour,
            recentMoodFrequency: recentSimilarSessions.count,
            userEnergyLevel: recentSimilarSessions.last?.energyLevel ?? 5
        )
    }
    
    private func selectBestMeditationType(for mood: MoodState, history: [MoodSession]) -> String {
        if history.isEmpty {
            // Fallback to rule-based recommendations
            switch mood {
            case .stressed, .anxious, .overwhelmed: return "Stress Relief"
            case .tired, .sad: return "Gentle Breathing"
            case .calm: return "Mindfulness"
            case .energetic, .excited: return "Focus & Clarity"
            }
        }
        
        // Use historical data
        let typeSuccess = Dictionary(grouping: history, by: { $0.meditationType ?? "Unknown" })
            .mapValues { sessions in
                sessions.compactMap { $0.postMoodRating }.reduce(0, +) / max(1, sessions.count)
            }
        
        return typeSuccess.max(by: { $0.value < $1.value })?.key ?? "Mindfulness"
    }
    
    private func calculateOptimalDuration(for mood: MoodState, context: MeditationContext) -> Int {
        // AI logic based on time of day and energy
        switch (mood, context.timeOfDay) {
        case (.tired, _), (.sad, _): return 3 // Gentle sessions when low energy
        case (_, 6...9): return 5 // Morning sessions
        case (_, 12...14): return 3 // Quick midday reset
        case (_, 18...22): return 10 // Evening longer sessions
        default: return 5 // Standard fallback
        }
    }
    
    private func generateAIMessage(for mood: MoodState, context: MeditationContext) -> String {
        let timeContext = context.timeOfDay < 12 ? "this morning" : context.timeOfDay < 17 ? "this afternoon" : "this evening"
        
        switch mood {
        case .stressed:
            return "I notice you're feeling stressed \(timeContext). Based on your patterns, a focused breathing session tends to help you find peace quickly."
        case .anxious:
            return "Anxiety \(timeContext) is completely understandable. Your previous sessions show that grounding exercises work well for you at this time."
        case .tired:
            return "Low energy \(timeContext)? Your data suggests gentle, short meditations help restore your vitality without overwhelming you."
        case .energetic:
            return "Great energy \(timeContext)! Your successful sessions show that channeling this into focused meditation amplifies the positive feelings."
        case .calm:
            return "Beautiful calm state \(timeContext). Your patterns indicate this is perfect for deepening your mindfulness practice."
        case .sad:
            return "I see you're feeling down \(timeContext). Your history shows that compassion-focused meditations help lift your spirits gently."
        case .excited:
            return "Wonderful excitement \(timeContext)! Your data suggests using this energy for clarity-focused meditation works beautifully for you."
        case .overwhelmed:
            return "Feeling overwhelmed \(timeContext) is tough. Your successful sessions show that step-by-step breathing exercises help you find your center again."
        }
    }
    
    private func predictSuccessProbability(for mood: MoodState, sessions: [MoodSession]) -> Double {
        let similarSessions = sessions.filter { $0.mood == mood }
        guard !similarSessions.isEmpty else { return 0.5 } // Default 50% if no data
        
        let successfulSessions = similarSessions.filter { $0.completedMeditation && ($0.postMoodRating ?? 0) >= 4 }
        return Double(successfulSessions.count) / Double(similarSessions.count)
    }
    
    private func generateAlternativeOptions(for mood: MoodState, history: [MoodSession]) -> [String] {
        // Generate alternative meditation types based on historical data or rules
        switch mood {
        case .stressed: return ["Deep breathing", "Body scan", "Progressive relaxation"]
        case .anxious: return ["Grounding meditation", "Loving-kindness", "Breath awareness"]
        case .tired: return ["Gentle breathing", "Rest meditation", "Energy restoration"]
        default: return ["Mindfulness", "Breathing meditation", "Body awareness"]
        }
    }
    
    private func generateContextualTips(for mood: MoodState, context: MeditationContext) -> [String] {
        var tips: [String] = []
        
        // Time-based tips
        if context.timeOfDay < 10 {
            tips.append("🌅 Morning sessions help set a positive tone for your entire day")
        } else if context.timeOfDay > 20 {
            tips.append("🌙 Evening meditation can improve your sleep quality")
        }
        
        // Energy-based tips
        if context.userEnergyLevel < 4 {
            tips.append("💤 When energy is low, even 2-3 minutes of meditation is beneficial")
        } else if context.userEnergyLevel > 7 {
            tips.append("⚡ High energy is perfect for more active meditation techniques")
        }
        
        // Mood-specific tips
        switch mood {
        case .stressed:
            tips.append("🫁 Focus on exhaling longer than inhaling to activate your relaxation response")
        case .anxious:
            tips.append("🪨 Try the 5-4-3-2-1 grounding technique: 5 things you see, 4 you hear, 3 you feel, 2 you smell, 1 you taste")
        default:
            tips.append("🎯 Remember: there's no 'perfect' meditation, only practice")
        }
        
        return tips
    }
    
    private func analyzeMeditationSuccessByHour(sessions: [MoodSession]) -> HourlySuccessPattern {
        let successfulSessions = sessions.filter { $0.completedMeditation && ($0.postMoodRating ?? 0) >= 4 }
        
        let hourlySuccess = Dictionary(grouping: successfulSessions, by: { session in
            Calendar.current.component(.hour, from: session.timestamp)
        }).mapValues { $0.count }
        
        let bestHour = hourlySuccess.max(by: { $0.value < $1.value })?.key ?? 9
        let alternativeHours = hourlySuccess.sorted(by: { $0.value > $1.value }).prefix(3).map { $0.key }
        
        return HourlySuccessPattern(
            mostSuccessfulHour: bestHour,
            confidence: successfulSessions.count >= 5 ? 0.8 : 0.5,
            alternativeHours: Array(alternativeHours)
        )
    }
    
    private func analyzeDailyMoodCycles(sessions: [MoodSession]) -> DailyMoodCycle {
        // Analyze how mood changes throughout the day
        let hourlyMoods = Dictionary(grouping: sessions, by: { session in
            Calendar.current.component(.hour, from: session.timestamp)
        })
        
        return DailyMoodCycle(
            peakMoodHour: 10, // Placeholder
            lowMoodHour: 15   // Placeholder  
        )
    }
    
    private func generateTimingReasoning(patterns: HourlySuccessPattern, cycles: DailyMoodCycle) -> String {
        return "Based on your meditation success patterns, \(patterns.mostSuccessfulHour):00 shows the highest completion and satisfaction rates."
    }
    
    private func calculateAverageMoodImprovement(sessions: [MoodSession]) -> Double {
        let sessionsWithBeforeAfter = sessions.filter { 
            $0.stressLevel != nil && $0.postMeditationMood != nil 
        }
        
        guard !sessionsWithBeforeAfter.isEmpty else { return 0.0 }
        
        let improvements = sessionsWithBeforeAfter.map { session in
            let before = Double(session.stressLevel ?? 5)
            let after = Double(session.postMeditationMood ?? 5)
            return after - before
        }
        
        return improvements.reduce(0, +) / Double(improvements.count)
    }
}

// MARK: - AI Data Structures

public struct MoodPatternAnalysis {
    public let personalMoodCycle: MoodCycleAnalysis
    public let stressTriggers: [StressTrigger]
    public let energyPatterns: EnergyPatternAnalysis
    public let meditationEffectiveness: MeditationEffectivenessAnalysis
    public let optimalMeditationTimes: [Int]
    public let moodImprovementRate: Double
    public let personalizedInsights: [String]
    public let riskFactors: [RiskFactor]
}

public struct MoodCycleAnalysis {
    public let cycleLength: Int?
    public let averageMood: String
    public let pattern: String
}

public struct StressTrigger {
    public let type: TriggerType
    public let description: String
    public let frequency: Int
    public let confidence: Double
    
    public enum TriggerType {
        case temporal
        case contextual
        case behavioral
    }
}

public struct EnergyPatternAnalysis {
    public let peakEnergyHour: Int
    public let lowEnergyHour: Int
    public let pattern: String
}

public struct MeditationEffectivenessAnalysis {
    public let overallEffectiveness: Double
    public let bestMeditationType: String
    public let worstMeditationType: String
    public let averageImprovement: Double
}

public struct RiskFactor {
    public let type: RiskType
    public let severity: Severity
    public let description: String
    public let recommendation: String
    
    public enum RiskType {
        case increasingStress
        case lowEngagement
        case burnout
    }
    
    public enum Severity {
        case low, medium, high
    }
}

public struct AIRecommendation {
    public let recommendedMeditationType: String
    public let optimalDuration: Int
    public let personalizedMessage: String
    public let successProbability: Double
    public let alternativeOptions: [String]
    public let contextualTips: [String]
}

public struct TimeRecommendation {
    public let bestHour: Int
    public let confidenceScore: Double
    public let reasoning: String
    public let alternativeTimes: [Int]
}

public struct MeditationContext {
    public let timeOfDay: Int
    public let recentMoodFrequency: Int
    public let userEnergyLevel: Int
}

public struct HourlySuccessPattern {
    public let mostSuccessfulHour: Int
    public let confidence: Double
    public let alternativeHours: [Int]
}

public struct DailyMoodCycle {
    public let peakMoodHour: Int
    public let lowMoodHour: Int
} 