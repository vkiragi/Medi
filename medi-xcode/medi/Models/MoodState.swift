import Foundation
import SwiftUI

// MARK: - Mood State
enum MoodState: String, CaseIterable, Codable {
    case stressed = "Stressed"
    case anxious = "Anxious"
    case tired = "Tired"
    case energetic = "Energetic"
    case calm = "Calm"
    case sad = "Sad"
    case excited = "Excited"
    case overwhelmed = "Overwhelmed"
    
    var emoji: String {
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
    
    var color: Color {
        switch self {
        case .stressed: return Color(red: 0.9, green: 0.4, blue: 0.4)
        case .anxious: return Color(red: 0.8, green: 0.6, blue: 0.2)
        case .tired: return Color(red: 0.5, green: 0.5, blue: 0.7)
        case .energetic: return Color(red: 0.2, green: 0.8, blue: 0.3)
        case .calm: return Color(red: 0.4, green: 0.7, blue: 0.9)
        case .sad: return Color(red: 0.6, green: 0.6, blue: 0.8)
        case .excited: return Color(red: 0.9, green: 0.6, blue: 0.2)
        case .overwhelmed: return Color(red: 0.8, green: 0.3, blue: 0.6)
        }
    }
    
    var description: String {
        switch self {
        case .stressed: return "Feeling tense or under pressure"
        case .anxious: return "Worried or uneasy"
        case .tired: return "Low energy, need rest"
        case .energetic: return "Full of energy and vitality"
        case .calm: return "Peaceful and relaxed"
        case .sad: return "Feeling down or melancholy"
        case .excited: return "Enthusiastic and eager"
        case .overwhelmed: return "Too much to handle"
        }
    }
}

// MARK: - Mood Session
struct MoodSession: Codable, Identifiable {
    let id: UUID
    let mood: MoodState
    let timestamp: Date
    var selectedMeditation: String?
    var postMoodRating: Int? // 1-5 rating of how they feel after meditation
    
    init(mood: MoodState) {
        self.id = UUID()
        self.mood = mood
        self.timestamp = Date()
    }
}

// MARK: - AI Recommendation Engine
struct MoodRecommendationEngine {
    static func getRecommendations(for mood: MoodState) -> [GuidedMeditation] {
        let allMeditations = Self.getAllMeditations()
        
        switch mood {
        case .stressed:
            return [
                allMeditations.first { $0.title == "Stress Relief" }!,
                allMeditations.first { $0.title == "Deep Sleep" }!
            ]
        case .anxious:
            return [
                allMeditations.first { $0.title == "Morning Calm" }!,
                allMeditations.first { $0.title == "Stress Relief" }!
            ]
        case .tired:
            return [
                allMeditations.first { $0.title == "Morning Calm" }!,
                allMeditations.first { $0.title == "Focus & Clarity" }!
            ]
        case .energetic:
            return [
                allMeditations.first { $0.title == "Focus & Clarity" }!,
                allMeditations.first { $0.title == "Gratitude Practice" }!
            ]
        case .calm:
            return [
                allMeditations.first { $0.title == "Gratitude Practice" }!,
                allMeditations.first { $0.title == "Deep Sleep" }!
            ]
        case .sad:
            return [
                allMeditations.first { $0.title == "Gratitude Practice" }!,
                allMeditations.first { $0.title == "Morning Calm" }!
            ]
        case .excited:
            return [
                allMeditations.first { $0.title == "Focus & Clarity" }!,
                allMeditations.first { $0.title == "Deep Sleep" }!
            ]
        case .overwhelmed:
            return [
                allMeditations.first { $0.title == "Stress Relief" }!,
                allMeditations.first { $0.title == "Deep Sleep" }!
            ]
        }
    }
    
    static func getPersonalizedMessage(for mood: MoodState) -> String {
        switch mood {
        case .stressed:
            return "I understand you're feeling stressed. These meditations focus on releasing tension and finding your center. Take a deep breath - you've got this! 🌸"
        case .anxious:
            return "Anxiety can feel overwhelming, but meditation is a powerful tool for finding calm. These practices will help ground you in the present moment. 🕊️"
        case .tired:
            return "When we're tired, gentle meditation can be more refreshing than caffeine. These sessions will help restore your energy naturally. 🌅"
        case .energetic:
            return "I love that you're feeling energetic! Let's channel that positive energy into focused meditation to enhance your clarity and joy. ⚡"
        case .calm:
            return "Beautiful! You're already in a peaceful state. These meditations will help you deepen that serenity and maintain it throughout your day. 🧘‍♀️"
        case .sad:
            return "It's okay to feel sad sometimes. These gentle meditations offer comfort and help you reconnect with hope and gratitude. You're not alone. 💙"
        case .excited:
            return "Your excitement is wonderful! These meditations will help you channel that energy mindfully while maintaining your joyful spirit. 🎉"
        case .overwhelmed:
            return "Feeling overwhelmed is a sign you're carrying too much. These meditations will help you step back, breathe, and find clarity in the chaos. 🌊"
        }
    }
    
    private static func getAllMeditations() -> [GuidedMeditation] {
        return [
            GuidedMeditation(
                id: "1",
                title: "Morning Calm",
                description: "Start your day with a peaceful meditation",
                duration: 3,
                imageColor: Color(red: 0.4, green: 0.7, blue: 0.9),
                audioFileName: "breathing_meditation"
            ),
            GuidedMeditation(
                id: "2",
                title: "Stress Relief",
                description: "Release tension and find your center",
                duration: 5,
                imageColor: Color(red: 0.8, green: 0.6, blue: 0.9),
                audioFileName: "meditation_5min_marc"
            ),
            GuidedMeditation(
                id: "3",
                title: "Deep Sleep",
                description: "Prepare your mind for restful sleep",
                duration: 5,
                imageColor: Color(red: 0.5, green: 0.5, blue: 0.8),
                audioFileName: "meditation_5min_life_happens"
            ),
            GuidedMeditation(
                id: "4",
                title: "Focus & Clarity",
                description: "Sharpen your mind and enhance concentration",
                duration: 6,
                imageColor: Color(red: 0.9, green: 0.7, blue: 0.4),
                audioFileName: "meditation_6min_stillmind"
            ),
            GuidedMeditation(
                id: "5",
                title: "Gratitude Practice",
                description: "Cultivate appreciation and positive mindset",
                duration: 10,
                imageColor: Color(red: 0.7, green: 0.9, blue: 0.5),
                audioFileName: "meditation_10min_padraig"
            )
        ]
    }
}

// MARK: - Mood Insights
struct MoodInsights {
    let mostCommonMood: MoodState
    let moodFrequency: [MoodState: Int]
    let averageRating: Double
    let totalSessions: Int
    let weeklyTrend: String
    let personalizedTip: String
    
    static func generateInsights(from sessions: [MoodSession]) -> MoodInsights? {
        guard !sessions.isEmpty else { return nil }
        
        // Find most common mood
        let moodCounts = Dictionary(grouping: sessions, by: { $0.mood })
            .mapValues { $0.count }
        let mostCommon = moodCounts.max(by: { $0.value < $1.value })?.key ?? .calm
        
        // Calculate average rating
        let ratings = sessions.compactMap { $0.postMoodRating }
        let avgRating = ratings.isEmpty ? 0.0 : Double(ratings.reduce(0, +)) / Double(ratings.count)
        
        // Weekly trend analysis
        let recentSessions = sessions.filter { 
            $0.timestamp > Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date() 
        }
        let weeklyTrend = recentSessions.count > sessions.count / 2 ? "Increasing" : "Stable"
        
        // Personalized tip based on most common mood
        let tip = Self.getPersonalizedTip(for: mostCommon, totalSessions: sessions.count)
        
        return MoodInsights(
            mostCommonMood: mostCommon,
            moodFrequency: moodCounts,
            averageRating: avgRating,
            totalSessions: sessions.count,
            weeklyTrend: weeklyTrend,
            personalizedTip: tip
        )
    }
    
    private static func getPersonalizedTip(for mood: MoodState, totalSessions: Int) -> String {
        switch mood {
        case .stressed:
            return "You've been feeling stressed lately. Try incorporating 5-minute breathing exercises throughout your day."
        case .anxious:
            return "Consider setting a regular meditation schedule to help manage anxiety patterns."
        case .tired:
            return "Your energy levels suggest trying morning meditations to start the day refreshed."
        case .calm:
            return "Great job maintaining emotional balance! Keep up your consistent practice."
        case .sad:
            return "Gentle self-compassion and gratitude practices might be especially helpful right now."
        case .energetic:
            return "Channel your positive energy into longer, deeper meditation sessions."
        case .excited:
            return "Balance excitement with grounding practices to maintain sustainable energy."
        case .overwhelmed:
            return "Break your meditation into shorter, more frequent sessions when feeling overwhelmed."
        }
    }
} 