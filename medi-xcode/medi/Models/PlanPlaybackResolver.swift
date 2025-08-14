import Foundation
import SwiftUI

enum PlaybackTarget {
	case guided(GuidedMeditation)
}

enum PlanPlaybackResolver {
	static func resolve(for day: AIMeditationPlan.Day) -> PlaybackTarget {
		let f = day.focus.lowercased()
		// Focus & Clarity
		if f.contains("focus") || f.contains("clarity") || f.contains("concentrat") || f.contains("productiv") {
			return .guided(GuidedMeditation(
				id: "focus",
				title: "Focus & Clarity",
				description: "Sharpen your mind for better concentration",
				duration: 6,
				imageColor: Color(red: 0.5, green: 0.8, blue: 0.7),
				audioFileName: "meditation_6min_stillmind"
			))
		}
		// Gratitude
		if f.contains("gratitude") || f.contains("appreciation") || f.contains("thanks") {
			return .guided(GuidedMeditation(
				id: "gratitude",
				title: "Gratitude Practice",
				description: "Cultivate appreciation and positivity",
				duration: 10,
				imageColor: Color(red: 0.9, green: 0.7, blue: 0.5),
				audioFileName: "meditation_10min_breathing"
			))
		}
		// Breath / Morning Calm
		if f.contains("breath") || f.contains("breathing") || f.contains("morning") || f.contains("grounding") {
			return .guided(GuidedMeditation(
				id: "morning_calm",
				title: "Morning Calm",
				description: "Start your day with a peaceful meditation",
				duration: 3,
				imageColor: Color(red: 0.4, green: 0.7, blue: 0.9),
				audioFileName: "breathing_meditation"
			))
		}
		// Deep Sleep / Calm / Relax
		if f.contains("sleep") || f.contains("calm") || f.contains("relax") || f.contains("unwind") || f.contains("evening") {
			return .guided(GuidedMeditation(
				id: "sleep",
				title: "Deep Sleep",
				description: "Prepare your mind and body for restful sleep",
				duration: 5,
				imageColor: Color(red: 0.4, green: 0.5, blue: 0.8),
				audioFileName: "meditation_5min_life_happens"
			))
		}
		// Stress Relief / Body Scan
		if f.contains("stress") || f.contains("tension") || f.contains("body scan") || f.contains("scan") || f.contains("release") {
			return .guided(GuidedMeditation(
				id: "stress_relief",
				title: "Stress Relief",
				description: "Release tension and find your center",
				duration: 5,
				imageColor: Color(red: 0.8, green: 0.6, blue: 0.9),
				audioFileName: "meditation_5min_marc"
			))
		}
		// Default guided if nothing matched — choose Focus & Clarity as a safe default
		return .guided(GuidedMeditation(
			id: "focus_default",
			title: "Focus & Clarity",
			description: "Sharpen your mind for better concentration",
			duration: 6,
			imageColor: Color(red: 0.5, green: 0.8, blue: 0.7),
			audioFileName: "meditation_6min_stillmind"
		))
	}
}
