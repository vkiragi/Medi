import Foundation
import SwiftUI

enum PlaybackTarget {
	case guided(GuidedMeditation)
}

enum PlanPlaybackResolver {
	static func resolve(for day: AIMeditationPlan.Day) -> PlaybackTarget {
		let f = day.focus.lowercased()
		
		// Morning Calm / Breath / Grounding
		if f.contains("morning") || f.contains("breath") || f.contains("breathing") || f.contains("grounding") || f.contains("awakening") {
			return .guided(GuidedMeditation(
				id: "morning_calm_1",
				title: "Morning Calm",
				description: "Gentle ambient sounds to start your day peacefully",
				duration: 5,
				imageColor: Color(red: 0.4, green: 0.7, blue: 0.9),
				audioFileName: "morning-calm-236192"
			))
		}
		
		// Stress Relief / Tension / Anxiety
		if f.contains("stress") || f.contains("tension") || f.contains("anxiety") || f.contains("relax") || f.contains("calm") {
			return .guided(GuidedMeditation(
				id: "stress_relief_1",
				title: "Peace & Healing",
				description: "432Hz healing frequencies for deep relaxation",
				duration: 15,
				imageColor: Color(red: 0.8, green: 0.6, blue: 0.9),
				audioFileName: "meditation-peace-love-healing-432hz-music-prayer-aura-good-vibes-202323"
			))
		}
		
		// Deep Sleep / Sleep / Rest
		if f.contains("sleep") || f.contains("rest") || f.contains("bedtime") || f.contains("evening") || f.contains("night") {
			return .guided(GuidedMeditation(
				id: "deep_sleep_1",
				title: "Foetal Meditation",
				description: "Deep relaxation meditation for sleep",
				duration: 20,
				imageColor: Color(red: 0.4, green: 0.5, blue: 0.8),
				audioFileName: "foetal-meditation-for-sleep-amp-relaxation-22029"
			))
		}
		
		// Focus / Clarity / Concentration
		if f.contains("focus") || f.contains("clarity") || f.contains("concentrat") || f.contains("productiv") || f.contains("mental") {
			return .guided(GuidedMeditation(
				id: "focus_clarity_1",
				title: "Electronic Ambient",
				description: "Electronic ambient music for relaxation and focus",
				duration: 14,
				imageColor: Color(red: 0.5, green: 0.8, blue: 0.7),
				audioFileName: "electronic-ambient-music-for-relaxation-and-meditation-9362"
			))
		}
		
		// Gratitude / Appreciation / Thanks
		if f.contains("gratitude") || f.contains("appreciation") || f.contains("thanks") || f.contains("love") || f.contains("kindness") {
			return .guided(GuidedMeditation(
				id: "gratitude_1",
				title: "Quiet Contemplation",
				description: "Peaceful meditation for gratitude practice",
				duration: 12,
				imageColor: Color(red: 0.9, green: 0.7, blue: 0.5),
				audioFileName: "quiet-contemplation-meditation-283536"
			))
		}
		
		// Default to Focus & Clarity
		return .guided(GuidedMeditation(
			id: "focus_clarity_1",
			title: "Electronic Ambient",
			description: "Electronic ambient music for relaxation and focus",
			duration: 14,
			imageColor: Color(red: 0.5, green: 0.8, blue: 0.7),
			audioFileName: "electronic-ambient-music-for-relaxation-and-meditation-9362"
		))
	}
}
