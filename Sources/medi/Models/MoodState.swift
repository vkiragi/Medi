import Foundation
import SwiftUI

// MARK: - Mood State
public enum MoodState: String, CaseIterable, Codable {
    case stressed = "Stressed"
    case anxious = "Anxious"
    case tired = "Tired"
    case energetic = "Energetic"
    case calm = "Calm"
    case sad = "Sad"
    case excited = "Excited"
    case overwhelmed = "Overwhelmed"
    
    public var emoji: String {
        switch self {
        case .stressed: return "😰"
        case .anxious: return "😟"
        case .tired: return "😴"
        case .energetic: return "⚡"
        case .calm: return "😌"
        case .sad: return "😢"
        case .excited: return "🤩"
        case .overwhelmed: return "🤯"
        }
    }
    
    public var color: Color {
        switch self {
        case .stressed: return Color(red: 0.9, green: 0.5, blue: 0.5)
        case .anxious: return Color(red: 0.9, green: 0.7, blue: 0.4)
        case .tired: return Color(red: 0.6, green: 0.6, blue: 0.8)
        case .energetic: return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .calm: return Color(red: 0.5, green: 0.7, blue: 0.9)
        case .sad: return Color(red: 0.7, green: 0.6, blue: 0.8)
        case .excited: return Color(red: 0.9, green: 0.6, blue: 0.4)
        case .overwhelmed: return Color(red: 0.8, green: 0.4, blue: 0.6)
        }
    }
    
    public var description: String {
        switch self {
        case .stressed: return "Feeling tension or pressure"
        case .anxious: return "Worried or uneasy"
        case .tired: return "Low energy or sleepy"
        case .energetic: return "Full of energy and vitality"
        case .calm: return "Peaceful and relaxed"
        case .sad: return "Feeling down or melancholy"
        case .excited: return "Enthusiastic and eager"
        case .overwhelmed: return "Too much to handle"
        }
    }
}

// MARK: - Mood Session
public struct MoodSession: Codable, Identifiable {
    public let id: UUID
    public let mood: MoodState
    public let timestamp: Date
    public let meditationSessionId: UUID?
    public var postMoodRating: Int? // 1-5 scale: how helpful was the meditation
    
    public init(mood: MoodState, meditationSessionId: UUID? = nil) {
        self.id = UUID()
        self.mood = mood
        self.timestamp = Date()
        self.meditationSessionId = meditationSessionId
        self.postMoodRating = nil
    }
}

// MARK: - Mood-Based AI Recommendations
public class MoodBasedRecommendations {
    
    public static func getRecommendationsFor(mood: MoodState) -> [String] {
        // Returns meditation IDs that are best for this mood
        switch mood {
        case .stressed:
            return ["2", "3", "4"] // Stress Relief, Deep Sleep, Focus & Clarity
        case .anxious:
            return ["1", "2", "4"] // Morning Calm, Stress Relief, Focus & Clarity
        case .tired:
            return ["1", "5"] // Morning Calm, Gratitude Practice
        case .energetic:
            return ["4", "5"] // Focus & Clarity, Gratitude Practice
        case .calm:
            return ["5", "1"] // Gratitude Practice, Morning Calm
        case .sad:
            return ["5", "1", "2"] // Gratitude Practice, Morning Calm, Stress Relief
        case .excited:
            return ["4", "3"] // Focus & Clarity, Deep Sleep
        case .overwhelmed:
            return ["2", "3", "1"] // Stress Relief, Deep Sleep, Morning Calm
        }
    }
    
    public static func getPersonalizedMessage(for mood: MoodState) -> String {
        switch mood {
        case .stressed:
            return "I can help you release that tension. Let's find some peace together."
        case .anxious:
            return "Anxiety is temporary. Let's ground yourself with some mindful breathing."
        case .tired:
            return "Sometimes the mind needs rest as much as the body. Let's restore your energy."
        case .energetic:
            return "Great energy! Let's channel it into focused mindfulness."
        case .calm:
            return "Beautiful! Let's deepen this sense of peace you're already feeling."
        case .sad:
            return "It's okay to feel this way. Let's nurture yourself with some gentle compassion."
        case .excited:
            return "Wonderful energy! Let's harness this excitement mindfully."
        case .overwhelmed:
            return "Take a breath. Let's break through the noise and find your center."
        }
    }
    
    public static func getOptimalDuration(for mood: MoodState) -> Int {
        // Returns recommended meditation duration in minutes
        switch mood {
        case .stressed, .anxious, .overwhelmed:
            return 5 // Quick relief for acute states
        case .tired, .sad:
            return 3 // Gentle, shorter sessions when energy is low
        case .energetic, .excited:
            return 10 // Longer sessions to channel high energy
        case .calm:
            return 6 // Medium session to maintain the state
        }
    }
}

// MARK: - Mood Insights
public struct MoodInsights {
    public let mostCommonMood: MoodState?
    public let moodTrend: String
    public let improvementRate: Double // Percentage of sessions that helped mood
    public let recommendedActions: [String]
    public let moodDistribution: [MoodState: Int]
    
    public init(moodSessions: [MoodSession]) {
        // Calculate most common mood
        let moodCounts = Dictionary(grouping: moodSessions, by: { $0.mood })
            .mapValues { $0.count }
        self.mostCommonMood = moodCounts.max(by: { $0.value < $1.value })?.key
        
        // Calculate mood distribution
        self.moodDistribution = moodCounts
        
        // Calculate improvement rate
        let ratedSessions = moodSessions.filter { $0.postMoodRating != nil }
        let improvedSessions = ratedSessions.filter { ($0.postMoodRating ?? 0) >= 4 }
        self.improvementRate = ratedSessions.isEmpty ? 0 : 
            Double(improvedSessions.count) / Double(ratedSessions.count) * 100
        
        // Generate trend analysis
        let recentSessions = moodSessions.filter { 
            $0.timestamp > Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        }
        
        if recentSessions.isEmpty {
            self.moodTrend = "Not enough data yet"
        } else {
            let positiveMoods: Set<MoodState> = [.calm, .energetic, .excited]
            let positiveCount = recentSessions.filter { positiveMoods.contains($0.mood) }.count
            let positiveRatio = Double(positiveCount) / Double(recentSessions.count)
            
            if positiveRatio >= 0.7 {
                self.moodTrend = "Your mood has been largely positive this week! 🌟"
            } else if positiveRatio >= 0.4 {
                self.moodTrend = "You've had a balanced week with ups and downs"
            } else {
                self.moodTrend = "You've been facing some challenges. Remember to be kind to yourself 💙"
            }
        }
        
        // Generate recommendations
        var actions: [String] = []
        if let commonMood = mostCommonMood {
            switch commonMood {
            case .stressed, .anxious, .overwhelmed:
                actions.append("Consider shorter, more frequent meditation sessions")
                actions.append("Try breathing exercises throughout the day")
            case .tired:
                actions.append("Morning meditations might help boost your energy")
                actions.append("Consider checking your sleep schedule")
            case .sad:
                actions.append("Gratitude practice can help shift perspective")
                actions.append("Be patient and gentle with yourself")
            default:
                actions.append("Keep up your great meditation practice!")
            }
        }
        
        if improvementRate < 50 {
            actions.append("Try different meditation styles to find what works best")
        }
        
        self.recommendedActions = actions
    }
} 