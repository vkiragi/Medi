import Foundation

struct GuidedMeditation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let duration: String
    let fileName: String
    let description: String
    
    static let meditations = [
        GuidedMeditation(
            title: "3-Minute Breathing",
            duration: "3 min",
            fileName: "breathing_meditation",
            description: "A gentle introduction to mindful breathing"
        ),
        GuidedMeditation(
            title: "Life Happens Breathing",
            duration: "5 min",
            fileName: "meditation_5min_life_happens",
            description: "Breathing meditation for stressful moments"
        ),
        GuidedMeditation(
            title: "MARC Breathing",
            duration: "5 min",
            fileName: "meditation_5min_marc",
            description: "Mindfulness-based breathing practice"
        ),
        GuidedMeditation(
            title: "Still Mind Breath Awareness",
            duration: "6 min",
            fileName: "meditation_6min_stillmind",
            description: "Cultivating awareness through breath"
        ),
        GuidedMeditation(
            title: "10-Minute Breathing",
            duration: "10 min",
            fileName: "meditation_10min_breathing",
            description: "Extended mindful breathing session"
        ),
        GuidedMeditation(
            title: "Padraig's Mindfulness",
            duration: "10 min",
            fileName: "meditation_10min_padraig",
            description: "Mindfulness of breathing meditation"
        )
    ]
} 