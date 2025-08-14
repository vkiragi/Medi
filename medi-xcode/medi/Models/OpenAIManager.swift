import Foundation
import SwiftUI

struct AIMeditationPlan: Codable {
    struct Day: Codable, Identifiable {
        var id: UUID = UUID()
        let dayNumber: Int
        let title: String
        let focus: String
        let durationMinutes: Int
        let tip: String
        var completed: Bool = false
        
        enum CodingKeys: String, CodingKey { case dayNumber, title, focus, durationMinutes, tip, completed }
    }
    let goal: String
    let days: [Day]
}

enum OpenAIError: Error, LocalizedError {
    case missingAPIKey
    case badResponse
    case decodingFailed
    case network(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "Missing OpenAI API key"
        case .badResponse: return "OpenAI returned an unexpected response"
        case .decodingFailed: return "Failed to parse plan JSON"
        case .network(let err): return err.localizedDescription
        }
    }
}

class OpenAIManager {
    static let shared = OpenAIManager()
    private init() {}
    
    private var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String
    }
    
    func generatePlan(goal: String, days: Int, moodSummary: String?) async throws -> AIMeditationPlan {
        print("🧠 AI: starting plan generation — goal='\(goal)', days=\(days)")
        let keyLen = apiKey?.count ?? 0
        print("🔑 AI: OPENAI_API_KEY present=\(apiKey != nil) length=\(keyLen)")
        if apiKey?.isEmpty != false {
            print("🧠 AI: using local fallback (no OPENAI_API_KEY)")
            let plan = makeLocalFallbackPlan(goal: goal, days: days)
            print("✅ AI: fallback plan created — days=\(plan.days.count)")
            return plan
        }
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a meditation coach. Always output strict JSON only, with no extra commentary."],
            ["role": "user", "content": planPrompt(goal: goal, days: days, moodSummary: moodSummary)]
        ]
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "response_format": ["type": "json_object"],
            "temperature": 0.7,
            "max_tokens": 800
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { throw OpenAIError.badResponse }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey!)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse { print("🌐 AI: OpenAI status=\(http.statusCode) bytes=\(data.count)") }
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw OpenAIError.badResponse
            }
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let message = choices.first?["message"] as? [String: Any],
                let content = message["content"] as? String
            else { throw OpenAIError.badResponse }
            
            print("📦 AI: content length=\(content.count) preview=\(String(content.prefix(120)))…")
            let planData = Data(content.utf8)
            let decoder = JSONDecoder()
            var plan = try decoder.decode(AIMeditationPlan.self, from: planData)
            plan = AIMeditationPlan(goal: plan.goal, days: plan.days.enumerated().map { idx, day in
                var d = day
                d.id = UUID()
                return d
            })
            print("✅ AI: parsed plan — days=\(plan.days.count)")
            return plan
        } catch let err as OpenAIError {
            print("❌ AI: \(err.localizedDescription)")
            throw err
        } catch {
            print("❌ AI: network/unknown error — \(error.localizedDescription)")
            throw OpenAIError.network(error)
        }
    }
    
    private func planPrompt(goal: String, days: Int, moodSummary: String?) -> String {
        """
        Create a personalized meditation plan as strict JSON only, matching this schema:
        {
          "goal": String,
          "days": [
            { "dayNumber": Int(1..\(days)), "title": String, "focus": String, "durationMinutes": Int(3..30), "tip": String, "completed": false }
          ]
        }
        Constraints:
        - Exactly \(days) days
        - Keep titles short (2-4 words)
        - Balance durations with some variety; keep most within 5-10 minutes
        - Ensure content aligns with the goal: \(goal)
        - Mood context (optional): \(moodSummary ?? "none")
        - Output JSON only, no markdown, no comments.
        - Use only these focus values (match exactly): ["Breath Awareness", "Stress Relief", "Deep Sleep", "Focus & Clarity", "Gratitude"]
        - Use only these durations: [3, 5, 6, 10]
        - Make titles consistent with the chosen focus
        """
    }
    
    private func makeLocalFallbackPlan(goal: String, days: Int) -> AIMeditationPlan {
        let focuses = ["Focus & Clarity", "Breath Awareness", "Stress Relief", "Gratitude", "Deep Sleep"]
        var items: [AIMeditationPlan.Day] = []
        for i in 1...days {
            let f = focuses[(i - 1) % focuses.count]
            let dur = [3,5,6,10][(i - 1) % 4]
            items.append(.init(dayNumber: i, title: "Day \(i) \(f)", focus: f, durationMinutes: dur, tip: "Find a quiet spot and relax your shoulders.", completed: false))
        }
        return AIMeditationPlan(goal: goal, days: items)
    }
}

enum PlanStorage {
    private static let key = "ai_meditation_plan"
    
    static func save(_ plan: AIMeditationPlan) {
        if let data = try? JSONEncoder().encode(plan) {
            UserDefaults.standard.set(data, forKey: key)
            print("💾 PlanStorage: saved plan goal='\(plan.goal)' days=\(plan.days.count)")
        }
    }
    
    static func load() -> AIMeditationPlan? {
        if let data = UserDefaults.standard.data(forKey: key) {
            let plan = try? JSONDecoder().decode(AIMeditationPlan.self, from: data)
            if let plan { print("📥 PlanStorage: loaded plan goal='\(plan.goal)' days=\(plan.days.count)") }
            return plan
        }
        return nil
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        print("🗑️ PlanStorage: cleared current plan")
    }
}
